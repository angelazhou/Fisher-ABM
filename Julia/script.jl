#Push module load path to julia pathenv
#push!(LOAD_PATH, "C:/Users/theplankt/Documents/Github/Fisher-ABM/")

using Devectorize #implement devectorizing optimizations
using NPZ
using Types, Constants

### Specify the specific argument for this particular 
argument = "randomNetwork"; 

include("sub_functions.jl");
include("sub_init.jl");
include("sub_routines.jl");
include("Experiments.jl");
println("Libraries loaded: working:")

fish,cons,OUT = init_equilibrium();
SN = ones(PC_n,PC_n) .* .01;
for j = 1:PC_n; SN[j,j] = 1; end;
#SN matrix for social network (diagonals 1, self-adjacent)

@time make_season(fish,cons,SN,1);



# @time CPUE,Tau = sim_simple()
#println(CPUE)
#println(Tau)


npzwrite("Data_fish_randomnetwork.npz", OUT.fish_xy)
npzwrite("Data_fishers_randomnetwork.npz", OUT.cons_xy)
npzwrite("Data_clusters_randomnetwork.npz", OUT.schl_xy)
npzwrite("Data_harvest_randomnetwork.npz", OUT.cons_H)
npzwrite("Data_contact_randomnetwork.npz", OUT.cons_CN)
#npzwrite("Data_simple_randomnetwork.npz", ["x"=>1, "CPUE"=>CPUE, "Tau"=>Tau])
