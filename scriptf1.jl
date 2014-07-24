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
println("Libraries loaded: working:")


n = 10;  
f1 = SharedArray(Float64, n); 
@time sum_f1 = @parallel (+) for i = 1:n
	CPUE, Tau = sim_simple();
	#Kind of a hack to get f1 for the case of one fisherman
	f1[i] = length(find(OUT.states .==2)) / length(OUT.states); 

end

meanf = mean(f1); 
stdf = std(f1); 

println("mean of f1: ", meanf); 
println("stdev of f1: ", stdf ); 

f1 = fnc_f1pred(); 
println("original theory: $f1");
f1_rev = fnc_f1pred_revised(); 
println("revised theory: $f1_rev"); 
 
f = open("f1-estimate", "w"); 
write(f,meanf,'\n'); 
write(f,stdf,'\n'); 
write(f, f1, '\n'); 
writedlm(f,f1,'\n'); 
close(f); 

npzwrite("Data_fish_classify2.npz", OUT.fish_xy)
npzwrite("Data_fishers_classify2.npz", OUT.cons_xy )
npzwrite("Data_clusters_classify2.npz", OUT.schl_xy )
npzwrite("Data_harvest_classify2.npz", OUT.cons_H )
#npzwrite("Data_contact_classify2.npz", OUT.cons_CN )
npzwrite("Data_states2.npz", OUT.states )
#npzwrite("Data_simple_randomnetwork.npz", ["x"=>1, "CPUE"=>CPUE, "Tau"=>Tau])



