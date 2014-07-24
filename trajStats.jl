#Calculate time series spatial statistics for the position array
#of the fishermen. Client's responsibility to pass the proper
#position array, first two-dimensions are x-y; third is for each time step


#Isn't yet working for multiple trips. 
function stats(pos::Array,states,w,timejump,wrapX,wrapY)

Fn = size(pos)[1] #Number of fishers
n = size(pos)[3]; 

TIMESTEP = 4; 
nSample = int(floor(n / TIMESTEP)); #sample statistics every TIMESTEP 
samplePos = zeros(Fn, 2, nSample); 
sampleStates = zeros(Fn, nSample); 
win = 10; #window length


println("number of fishers: $Fn"); 
println("n: $n"); 
speeds = Array(Float64,Fn,nSample); 
angles = Array(Float64,Fn,nSample); 
dists = Array(Float64,Fn,nSample); 

#For Sinuosity calculation (Benhamou 2004)
slidingC = Array(Float64,Fn,nSample); 
p = Array(Float64,Fn,nSample);
b = Array(Float64,Fn,nSample); 


MSSI = Array(Float64,Fn,nSample); 
laggedDist = Array(Float64,Fn,nSample); 
vect2,vect1 = Array(Float64,2); 
sumDist = 0; 
# g is time interval
println(size(pos));
dx = 0; dy = 0; 
#jank calculation of f1 
f1 = 0; 
for i = 1:n
	if states[i] == 2
		f1 = f1+1; 
	end
end
f1 = f1 / n; 
println("value f1: $f1"); 	

for i = 1:Fn #iterate thru fishers
	#unfold coordinates first
	for k = 1:n
		pos[i,1,k] = pos[i,1,k] + wrapX[i,k] * GRD_mx; 
		pos[i,2,k] = pos[i,2,k] + wrapY[i,k] * GRD_mx; 
	end

	for l = 1:nSample
		samplePos[i,1,l] = pos[i,1,l]
		samplePos[i,2,l] = pos[i,2,l*4];
		sampleStates[i,l] = states[i,l*4]; 
	end

	#seed the first calculation
	vect1 = [samplePos[i,1,(win+1)] - samplePos[i,1,win], samplePos[i,2,(win+1)] - samplePos[i,2,win] ];
	
	for j = (win+1):nSample-win
	# calculate a vector of the dist? 
	
	vect2 = [ (samplePos[i,1,(j+1)] - samplePos[i,1,j]), (samplePos[i,2,(j+1)] - samplePos[i,2,j])];


	# TODO: rewrite as list comprehensions

	# calculate speed	
	# midpoint? prev state?
	dists[i,j] = dist(samplePos[i,:,j],samplePos[i,:,(j-1)]);  
	speeds[i,j] = dists[i,j] / timejump;
	

	# calculate turning angle in radians ? Need to check for sign ? 
	# source for relative angle: 
	# http://www.euclideanspace.com/maths/algebra/vectors/angleBetween/issues/index.htm	
	angles[i,j] = angle(vect1,vect2); 
	slidingC[i,j] = mean(cos(angles[i,(j-win):j]));
	p[i,j] = mean(dists[i,(j-win):j]); 
	b[i,j] = std(dists[i, (j-win):j]) / p[i,j]; 


	laggedDist[i,j] = sum(dists[i,(j-win):j]) / dist(samplePos[i,:,j],samplePos[i,:,(j-win)]);
	#calculate MSSI
	#let's go with straightness index, unless you want to interpolate
	for k = 1:w
		sumDist = sumDist + dist(samplePos[i,:,j+k],samplePos[i,:,j+k-1]);		
	end
	
	MSSI[i,j] = dist(samplePos[i,:,j],samplePos[i,:,j+w]) / sumDist;
	if MSSI[i,j] == NaN 
		MSSI[i,j] = 1; 
	end
	
	sumDist = 0; 
	vect1 = vect2; 

	end
end
println(size(speeds)); 
println(size(angles)); 
println(size(MSSI)); 

sinuosity = zeros(PC_n,nSample); 
for i in 1:PC_n
	for k in (win+1):(nSample-win)
		ratio = (1+slidingC[i,k]) / (1-slidingC[i,k]); 
		sinuosity[i,k] = 2 / sqrt(p[i,k] * ratio + b[i,k]*b[i,k]); 
	end
end

 

npzwrite("Data_fishers_sampled.npz",samplePos); 
npzwrite("Data_states_sampled.npz",sampleStates); 


return speeds, angles, MSSI, slidingC, p, b, laggedDist, sinuosity, dists
end

function dist(a1, a2) 

	dx = (a2[1]-a1[1]);
	dy =  (a2[2]-a1[2]);
 
#	if abs(dx) > GRD_mx/2
#		dx = dx % GRD_mx/2
#	end
#	if abs(dy) > GRD_mx/2	
#		dy = dy % GRD_mx/2
#	end

	return sqrt(dx*dx + dy*dy); 
end

#handle boundary cases for arctan
function angle(vect1, vect2)

	a = atan(vect2[2]/vect2[1]) - atan(vect1[2]/vect1[1]); 
	if ((a < Inf) == false)
		println(vect1);
		println(vect2);
	end
	return a; 	
	
end

