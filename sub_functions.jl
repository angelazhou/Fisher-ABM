######## Helper Functions
# Helper function for standard normal
# source: 
# http://www.johndcook.com/blog/2012/02/22/julia-random-number-generation/
 	
function rand_normal(mean, stdev)
    if stdev <= 0.0
        error("standard deviation must be positive")
    end
    u1 = rand()
    u2 = rand()
    r = sqrt( -2.0*log(u1) )
    theta = 2.0*pi*u2
    mean + stdev*r*sin(theta)
end

######## Functions for ABM

#### HAUL TIME
#! running time between hauls
#! and estimate the running mean time between schools
#! and estimate the difference in this running mean 
#! which is the switch for the while loop
function fnc_tau(H,Ts,ts,ns,dTs)
	#H=cons.H;Ts=cons.Ts;ts=cons.ts;sn=cons.sn;
	for I = 1:PC_n
		# if you caught fish
		# and the cumulative haul time (ts) is large 
		# then you've encountered a new school
		if H[I] == 1
			if ts[I] > (10*PF_sig/PC_v) 
				ns[I] += 1; # update school counter
				Ts_old = Ts[I]; # current mean
				Ts[I] = Ts_old + ((ts[I]-Ts_old)/ns[I]) # run mean calculation
				dTs[I] = abs(Ts[I]-Ts_old)/Ts[I]; # fractional change in estimate
				ts[I] = 1; # reset how long it took to find school
			else
				ts[I] = 1;
			end
		else # if you didn't catch anythin
			ts[I] += 1
		end
	end
	return Ts,ts,ns,dTs
end


#### FISH FINDER / DISTANCE
#!calculate distances between fish and fishermen? + search/steam switch
#! Returns Dx, the x-distances between fish and fishermen; Dy, y-distances;
#! D the Euclidean distances, MI which is a indicator for search steam switch (???)
function fnc_fishfinder(Fx,Sx,Si,Cx,grd,PC_f)

	# First, find fishers that are likely near fish
	# by gauging distance to all school centres
	II = cell(PC_n); # index of schools each fisher is near
	for i = 1:PC_n
		(dx,dy) = fnc_difference(Cx[i,:],Sx);
		D = sqrt(abs2(dx) .+ abs2(dy));
		JJ = find(D.<((2.5.*PF_sig).+PC_f));
		II[i] = JJ # index of nearby schools (empty if none)
	end

	##### HEREEEEEEEE
	# Output - index of nearest fish for all fishers (if any)
	Ni = fill(0,PC_n,1);

	# find for each fisher
	for i = 1:PC_n

		if isempty(II[i]) == 0 # if there is a school nearby fisher i

			# if so, get index k of fish in all schools, near fisher i
			k = Array(Float64,0)
			for j = 1:length(II[i])
				k = [k, find(Si .== II[i][j])];
			end

			# get dx and dy,
			Ci = round(Cx[i,:]) .+ 1;
			Fi = round(Fx[k,:]) .+ 1;
			(dx,dy) = fnc_difference(Ci,Fi)

			# get index of those fish, in schools k, near fisher i
			I  = find(((abs(dx) .< PC_f) + (abs(dy) .< PC_f)) .== 2);

			# find squared euclidean distance with these nearish fish
			if isempty(I)==0
				(dx,dy) = fnc_difference(Fx[k[I],:],Cx[i,:]);
				D   = abs2(dx) + abs2(dy);
				dmi = find(D.==minimum(D));

				# store nearest fish
				Ni[i] = int(k[I[dmi[1]]]); # Index of nearest fish in fishfinder
			end

		else 
				Ni[i] = 0;
		end
	end

    return Ni # Index of nearest fish for each fisher (in fishfinder)
end


#### spatial Difference function
#! x1 = first x,y location
#! x2 = second x,y location
#! dx,dy = difference in x,y accounting for periodic boundary
function fnc_difference(x1,x2)
	# difference
	dx = x1[:,1] .- x2[:,1]
	dy = x1[:,2] .- x2[:,2]
	# periodic boundary
	j = (abs(dy).>GRD_mx2) + (abs(dx).>GRD_mx2);
	dx[j.>1] = -sign(dx[j.>1]).*(GRD_mx .- abs(dx[j.>1]));
	dy[j.>1] = -sign(dy[j.>1]).*(GRD_mx .- abs(dy[j.>1]));

	return dx,dy
end



#### Search/steam switch
#! that is, is a fisher can't see any fish
#! they can either spin around or move in a straightish line
#! they switch between this probabilistically
function fnc_steam(MI)
	MI[rand(PC_n).<=PC_rp] .-= 1;
	MI = abs(MI);
end


#### CONTACT NETWORK from social network
#! Iterates through social network adjacency matrix, generates 2 random numbers.
#! If random numbers are less than adjacency measure (friendship) they both
#! contact; else both do not contact. Return the network 2D array.
function fnc_contact(SN)
	CN = Array(Int,PC_n,PC_n)
	for i = 1:PC_n
		for j = i:PC_n
			f1 = SN[i,j];
			f2 = SN[j,i];
			RN = rand(2,1);

			if RN[1] < f1 && RN[2] < f2
				CN[i,j] = 1;
				CN[j,i] = 1;
			else
				CN[i,j] = 0;
				CN[j,i] = 0;
			end
		end
	end
	return CN
end


#### INFORMATION and fisher direction
#! Iterate through the people you share information with and get the locations
#! of the fish within their view. Calculate the unit vector to the nearest fish
#! and if there's a fish in view, do a probabilistic catch. Otherwise roam around
#! randomly according to a self-correlated walk that approximates search behavior according to a Levy walk
#! Return the minimum distance, updated heading, JJ index of nearest fish
#! (KK) whether or not you caught something (?)
function fnc_information(dxy,Ni,Fx,Cx,MI,CN,states::Array{Int})
	#dxy=cons.DXY;Ni=cons.Ni;Fx=fish.fx;Cx=cons.x;MI=cons.MI;

	DXY  = Array(Float64,PC_n,2) # heading
	DMIN = Array(Float64,PC_n) # shortest distance
	V = Array(Float64,PC_n); 
	JJ   = fill(0,PC_n) # index of nearest fish
	KK   = fill(0,PC_n) # index of whether you caught fish

	for id = 1:PC_n
		# get the vector of people with whom you are currently in contact
		J  = find(CN[id,:].==1); # index of friends
		Jn = length(J); # number of friends 

		# calculate distances to all fish you have info on
		DD = fill(NaN,PC_n) # distance to your fish and friend's
		Dx = fill(NaN,PC_n) # dx
		Dy = fill(NaN,PC_n) # dy
		for i = 1:Jn # for each friend
			ii = J[i]; # get his/her index
			if Ni[ii] != 0 # if they see a fish
				(dx,dy) = fnc_difference(Fx[Ni[ii],:],Cx[id,:]);
				DD[i] = sqrt(abs2(dx) + abs2(dy))[1]; # and distance
				Dx[i] = dx[1]; Dy[i] = dy[1];
			end
		end
		Dmin = minimum(DD); # shortest distance to a fish

		# Action-decide heading, catch fish
		if isnan(Dmin) == 0 # if I see anything
			ii = find(DD .== Dmin); #!index of friend next to fish
			ii = ii[1]; # if more than one friend is next to the same fish
			jj = Ni[J[ii]]; #!index of nearest fish 

			# calculate unit vector DXY to nearest fish
			Dxy = [Dx[ii] Dy[ii]] ./ norm([Dx[ii] Dy[ii]]); 

			if Dmin <= PC_h #if there's a fish within view
				# probabilistic catch; if successful, then catch fish
				r =rand();if r < PC_q;kk = 1;else;kk = 0;end
				states[id] = 2; 
			
			else
				kk = 0; #index of whther harvest or not?
				states[id] = MI[id]; 
			end
			
			# slow speed
			V[id] = PC_v / 5
		else # else I roam around randomly 
			states[id] = MI[id]; 
			Dmin = 999; # flag, if you don't see anything
			jj = 0; kk = 0;

			#Steam or search pattern
			if MI[id] == 0  #
				#Dxy = dxy[id,:] + (randn(1,2).*PC_r1)
				#Dxy = Dxy ./ norm(Dxy)
				Dxy = dxy[id,:]; #straight line
				V[id] = PC_v
				
			else
				#Dxy = dxy[id,:] + (randn(1,2).*PC_r2)
				#Dxy = Dxy ./ norm(Dxy)
				Dxy = randn(1,2); 
				Dxy = Dxy ./ norm(Dxy)
				V[id] = PC_v / 3; 
			end
		end

		# Store
		DXY[id,:] = Dxy
		DMIN[id] = Dmin
		JJ[id] = jj[1];
		KK[id] = kk[1];
	end

    return DMIN,DXY,JJ,KK,states,V
end


#### HARVEST for a season
#! KK is the index of whether a given fisher has caught a fish
#! JJ is the index of the fish he's caught
#! CH is the cumulative catch
#! FF are the fish locations, which must be updated is fish are caught
function fnc_harvest(KK,JJ,CH,FF);
    II    = KK.*JJ
    IIu   = unique(II);

    for i in IIu
        j = find(II.==i);
        CH[j] = CH[j] + ((1 / length(j)) * KK[j]);
    end
    FF[IIu[IIu.>0],:] = NaN;
    return CH,FF
end






#### MOVE
#! CL <- fish.sx (school location); FX <- fish location;
#! distance
#! Randomly move the fish schools. 
#! Return the locations of the fish, school locations,
#! updated fisher locations
function fnc_move(CL,FX,FS,CC,Dm,DXY,V)
	wrapX = zeros(PC_n); 
	wrapY = zeros(PC_n); 

 # schools and fish move
        for i = 1:PS_n
                j = find(FS.==i);
                k = FX[j,1];
                m = find(isnan(k).==0)
                if isempty(m) == 1# if no fish left in school
                        CL_x = rand() * GRD_mx;
                        CL_y = rand() * GRD_mx;
                        F_x  = mod(CL_x.+(randn(PF_n,1)*PF_sig),GRD_mx);
                        F_y  = mod(CL_y.+(randn(PF_n,1)*PF_sig),GRD_mx);
                        CL[i,:] = [CL_x CL_y];
                        FX[j,:] = [F_x F_y];
                elseif rand() < PS_p # else maybe jump
                        CL_x = rand() * GRD_mx;
                        CL_y = rand() * GRD_mx;
                        F_x  = mod(CL_x.+(randn(PF_n,1)*PF_sig),GRD_mx);
                        F_y  = mod(CL_y.+(randn(PF_n,1)*PF_sig),GRD_mx);


                        CL[i,:] = [CL_x CL_y];
                        FX[j,:] = [F_x F_y];
                end
        end

    # fishers move
    # slow down as you approach fish
    #v = Dm; v[v.<PC_h] = PC_h; v[v.>PC_f] = PC_f;
    #v = (v .- PC_h) ./ (PC_f-PC_h);
    #range2 = PC_v - PC_vmn;
        #V = (v*range2) .+ PC_vmn;

 #   CC_x = mod(CC[:,1] .+ (DXY[:,1].*V), GRD_mx);
 #   CC_y = mod(CC[:,2] .+ (DXY[:,2].*V), GRD_mx);

	#7/18 testing: "unfold" coordinates http://www.pages.drexel.edu/~cfa22/msim/node29.html
	CC_x = CC[:,1] .+ (DXY[:,1].*(V+rand_normal(0,PC_v_sig)));
	CC_y = CC[:,2] .+ (DXY[:,2].*(V+rand_normal(0,PC_v_sig)));
	
	CC_x, wrapX = wrap(CC_x, wrapX); 
	CC_y, wrapY = wrap(CC_y, wrapY); 

    return FX,CL,[CC_x CC_y],wrapX,wrapY
end

#Function wrap takes in coordinate vector x, wraps coordinates that have 
#exited the domain and records how many wrpas they have encountered. 
#Method of unfolding coordinates on periodic boundaries. 
#Vector x is as long as the number of fishermen
#Vector wraps that it returns is really an indicator function for whether
# or not the fisherman has exited the boundaries. 
# More efficient implementation forthcoming. 
function wrap(x, wraps)
	for i in 1:length(x)
		if (x[i] < 0.0) 
			x[i] = x[i] + GRD_mx;
			wraps[i] = -1; 
		elseif (x[i] > GRD_mx)
			x[i] = x[i] - GRD_mx; 
			wraps[i] = 1; 
		end
	end
	return x, wraps
end





function fnc_f1pred()
	tau_L = 1 / PS_p; 
	D = PC_v*PC_v / 2; #since timestep normalized
	# 7/17 i messed up and put sigma squared :( 
	xi = (PF_sig * sqrt(2*log(PC_n*sqrt(2*pi*PF_sig*PF_sig))) + PC_f); 
	first = (xi*xi) / (GRD_mx*GRD_mx)
	tau_s_R = 1 / ((PS_n / (GRD_mx*GRD_mx)) * D);

	coeff =  (GRD_mx*GRD_mx) / (tau_L * PF_sig*PF_sig * D)  
	second = coeff * (exp(-1/coeff) - 1); 

	f1 = first + 1 + (exp(-tau_L/tau_s_R) - 1) / (tau_L / tau_s_R);
	return f1;

end


function fnc_f1pred_revised()
	tau_L = 1 / PS_p; 
	D = PC_v*PC_v / 2; #since timestep normalized
	p = PS_n / (GRD_mx * GRD_mx); 
	xi = (PF_sig * sqrt(2*log(PC_n*sqrt(2*pi*PF_sig*PF_sig))) + PC_f);	
	

	first = p * D * tau_L / 2; 
	second = (4./3.) * xi * p * sqrt(D*tau_L);

	return first + second; 

end 

function fnc_f(pos::Array, schoolpos::Array, xij, xijstar)
ntrunc = (dim(pos)[1]-1)

	
if i > 1
	for i = 1:ntrunc
		if dist(pos[i,:],pos[i+1,:]) < xij
			fij = fij + 1; 
		end
		for j = 1:dim(schoolpos)[1]
		#if fisher is within school 
		if (dist(pos[i,:],fish_sx[j,:]) < PF_sig)
			#if other fisher is within school
			if (dist(pos[i+1,:],fish_sx[j,:]) < PF_sig)
				f2 = f2 + 1; 
				if (dist(pos[i,:],pos[i+1]) < xijstar)
					fijstar = fijstar + 1; 
				end
			end	
		end
		end
	end
end
return f1, f2, fij, fijstar
end
