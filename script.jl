## 6/30 commit: code is somewhat parallelized - calculates the mean CPUE 
## per fisherman, but OUT is no longer operational. 
## To run parallelized version: 
## start Julia with n processors using "julia -p n" on the command line
## use include("script.jl") which will call the requisite "require" statements
## to source files. 



@everywhere using Devectorize #implement devectorizing optimizations
@everywhere using NPZ
@everywhere using Types, Constants

### Specify the specific argument for this particular 
argument = "randomNetwork"; 

require("sub_functions.jl");
require("sub_init.jl");
require("sub_routines.jl");
require("ExperimentsP.jl");
println("Libraries loaded: working:")

##fish,cons,OUT = init_equilibrium();
#SN = ones(PC_n,PC_n) .* .01;
#for j = 1:PC_n; SN[j,j] = 1; end;
#SN matrix for social network (diagonals 1, self-adjacent)




@time CPUE,s_CPUE_int, CPUE_var, Tau, s_Tau_s_R = sim_simple()
println("new mean-CPUE array: $CPUE")
println("Intermediate CPUE array: $s_CPUE_int")
println("Average Tau: ", mean(Tau))
println("Average time to first school: ", (s_Tau_s_R))


#npzwrite("Data_fish_randomnetwork.npz", OUT.fish_xy)
#npzwrite("Data_fishers_randomnetwork.npz", OUT.cons_xy)
#npzwrite("Data_clusters_randomnetwork.npz", OUT.schl_xy)
#npzwrite("Data_harvest_randomnetwork.npz", OUT.cons_H)
#npzwrite("Data_contact_randomnetwork.npz", OUT.cons_CN)
#npzwrite("Data_simple_randomnetwork.npz", ["x"=>1, "CPUE"=>CPUE, "Tau"=>Tau])
