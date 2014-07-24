## Parallel version of script.jl that accommodates shared arrays. 
## UNIX only

## 6/30 commit: code is somewhat parallelized - calculates the mean CPUE 
## per fisherman, but OUT is no longer operational. 
## To run parallelized version: 
## start Julia with n processors using "julia -p n" on the command line
## use include("script.jl") which will call the requisite "require" statements
## to source files. 



@everywhere using Devectorize #implement devectorizing optimizations
@everywhere using NPZ
@everywhere using Types, Constants
@everywhere using Distance
### Specify the specific argument for this particular 
argument = "randomNetwork"; 

require("sub_functions.jl");
require("sub_init.jl");
require("sub_routines.jl");
require("Experiments.jl");
require("trajStats.jl");
println("Libraries loaded: working:")

##fish,cons,OUT = init_equilibrium();
#SN = ones(PC_n,PC_n) .* .01;
#for j = 1:PC_n; SN[j,j] = 1; end;
#SN matrix for social network (diagonals 1, self-adjacent)


#Write to file

@time wrapX, wrapY, OUT = simple()

npzwrite("Data_fish_classify2.npz", OUT.fish_xy)
npzwrite("Data_clusters_classify2.npz", OUT.schl_xy )
npzwrite("Data_harvest_classify2.npz", OUT.cons_H )
#npzwrite("Data_contact_classify2.npz", OUT.cons_CN )
#npzwrite("Data_states2.npz", OUT.states )
#npzwrite("Data_simple_randomnetwork.npz", ["x"=>1, "CPUE"=>CPUE, "Tau"=>Tau])


#println("new mean-CPUE array: $CPUE")
#println("Intermediate CPUE array: $s_CPUE_int")
#println("Average Tau: ", mean(Tau))
#println("Average time to first school: ", (s_Tau_s_R))

@time speeds, angles, MSSI, c, p, b, lag, sinuosity, dists = stats(OUT.cons_xy,OUT.states,3,1, wrapX, wrapY); 

for i = 1:size(speeds)[1]

	f = open("ss-speeds-$i", "w"); 
	fa = open("ss-angles-$i", "w"); 
	fm = open("ss-MSSI-$i", "w"); 
	fp = open("ss-p-$i","w"); 
	fb = open("ss-b-$i","w"); 
	fc = open("ss-c-$i","w"); 
	flag = open("ss-lagDist-$i","w"); 
	fsin = open("ss-sinuosity-$i","w"); 


	writedlm(f,speeds[i,:],'\n');
	writedlm(fa,angles[i,:],'\n'); 
	writedlm(fm,MSSI[i,:],'\n'); 

	writedlm(fp,p[i,:],'\n'); 
	writedlm(fb,b[i,:],'\n'); 
	writedlm(fc,c[i,:],'\n'); 
	writedlm(flag,lag[i,:],'\n'); 
	writedlm(fsin,sinuosity[i,:],'\n'); 

	close(f); 
	close(fa); 
	close(fm); 

	close(fp); 
	close(fb); 
	close(fc); 
	close(flag); 
	close(fsin); 


end


