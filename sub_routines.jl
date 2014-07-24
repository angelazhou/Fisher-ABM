
#### Run a season
function make_season(fish,cons,ST)
 
global TIME = 0; 
TIME_SKIP = 4; 

 #while min of cumulative harvest is less than all fish in the region
 dTs = ones(PC_n);
 #! while difference in estimated Tau_s is greater that 1%
 #! and the minimum number of schools visited is 10 
 while maximum(dTs) > 0.01 || minimum(cons.ns) < 10
    ## Distances
    #D,Dx,Dy,cons.MI = fnc_distance(fish.fx,cons.x,cons.MI);
    cons.Ni = fnc_fishfinder(fish.fx,fish.sx,fish.fs,cons.x,GRD_mx2,PC_f);
    #(cons.Ni,cons.Dmin) = fnc_distance_3(fish.fx,cons.x,PC_f);
 
 	## Update steam/search switch
 	cons.MI = fnc_steam(cons.MI)
 
    ## Contact network from probabilistic social network
    CN = fnc_contact(cons.SN)
 
 	## Gather Information
 	#! return nearest distance, updated heading for nearest fish,
 	#! index of nearest fish, harvest success/failure index,
 	(cons.Dmin,cons.DXY,JJ,KK,cons.states,cons.V) = fnc_information(cons.DXY,cons.Ni,
 	   								fish.fx,cons.x,cons.MI,CN,cons.states);
 
    ## Harvest
    #! cons. => CC in function scope
    #! update te cumulative harvest and fish locations
    (cons.H,fish.fx) = fnc_harvest(KK,JJ,cons.H,fish.fx);
 
    ## Move
    #! update positions
    (fish.fx,fish.sx,cons.x,wrapX,wrapY) = fnc_move(fish.sx,fish.fx,fish.fs,
     									 cons.x,cons.Dmin,cons.DXY,cons.V);
	# Extract the index of the last column
	# Add the indicators to the previous wrap indices 
		## Estimate expected time searching for a school
	(cons.Ts,cons.ts,cons.ns,dTs) = fnc_tau(KK,cons.Ts,cons.ts,cons.ns,dTs);

 	## Save
     if ST == 1
	wrapX = cons.wrapX[:,end] + wrapX; 
	wrapY = cons.wrapY[:,end] + wrapY; 
 
	cons.wrapX = cat(2,cons.wrapX,wrapX); 
	cons.wrapY = cat(2,cons.wrapY,wrapY);  




	 OUT.states = cat(3,OUT.states,cons.states); 
         OUT.fish_xy = cat(3,OUT.fish_xy,fish.fx);
         OUT.cons_xy = cat(3,OUT.cons_xy,cons.x);
         OUT.schl_xy = cat(3,OUT.schl_xy,fish.sx);
         OUT.cons_H  = cat(2,OUT.cons_H,cons.H);
     end
       TIME = TIME + 1; 
 end
return cons.wrapX, cons.wrapY,OUT
end


#### Run a season
function make_trip(fish,cons,ST)
global TIME = 0;  
 #while min of cumulative harvest is less than all fish in the region
while minimum(cons.H) .< (PF_n*PS_n.*5)
#while TIME <= 200
	#! stops when every fisherman has caught the # fish in the system
     ## Distances
     #D,Dx,Dy,cons.MI = fnc_distance(fish.fx,cons.x,cons.MI);
     cons.Ni = fnc_fishfinder(fish.fx,fish.sx,fish.fs,cons.x,GRD_mx2,PC_f);
     #(cons.Ni,cons.Dmin) = fnc_distance_3(fish.fx,cons.x,PC_f);
 
 	 ## Update steam/search switch
 	 cons.MI = fnc_steam(cons.MI)
 
     ## Contact network from probabilistic social network
     CN = fnc_contact(cons.SN)
 
 	 ## Gather Information
 	 #! return nearest distance, updated heading for nearest fish,
 	 #! index of nearest fish, harvest success/failure index,
 	 (cons.Dmin,cons.DXY,JJ,KK,cons.states,cons.V) = fnc_information(cons.DXY,cons.Ni,
 										fish.fx,cons.x,cons.MI,CN,cons.states);
 
     ## Harvest
     #! cons. => CC in function scope
     #! update te cumulative harvest and fish locations
     (cons.H,fish.fx) = fnc_harvest(KK,JJ,cons.H,fish.fx);
 
     ## Move
     #! update positions
     (fish.fx,fish.sx,cons.x,wrapX,wrapY) = fnc_move(fish.sx,fish.fx,fish.fs,
     									 cons.x,cons.Dmin,cons.DXY,cons.V);
	# Add the indicators to the previous wrap indices 
	
#	wrapX = cons.wrapX[:,end] + wrapX; 
#	wrapY = cons.wrapY[:,end] + wrapY; 
 
#	cons.wrapX = cat(2,cons.wrapX,wrapX); 
#	cons.wrapY = cat(2,cons.wrapY,wrapY);  

	## Storage for plotting
     if ST == 1
	if TIME % TIME_SKIP == 0 
	wrapX = cons.wrapX[:,end] + wrapX; 
	wrapY = cons.wrapY[:,end] + wrapY; 
 
	cons.wrapX = cat(2,cons.wrapX,wrapX); 
	cons.wrapY = cat(2,cons.wrapY,wrapY);  

         OUT.fish_xy = cat(3,OUT.fish_xy,fish.fx);
         OUT.cons_xy = cat(3,OUT.cons_xy,cons.x);
         OUT.schl_xy = cat(3,OUT.schl_xy,fish.sx);
         OUT.cons_H  = cat(2,OUT.cons_H,cons.H);
	 OUT.states = cat(2,OUT.states,cons.states); 
     	end
      end
 	TIME += 1; 
 

end

	return cons.wrapX, cons.wrapY

end

