#Push module load path to julia pathenv
push!(LOAD_PATH, "C:/Users/theplankt/Documents/Github/Fisher-ABM/")

#using Devectorize #implement devectorizing optimizations
using Types, Constants

include("sub_functions.jl");
include("sub_init.jl");
include("sub_routines.jl");
include("Experiments.jl");
println("Libraries loaded: working:")

@time CPUE,Tau = sim_simple()
println(CPUE)
println(Tau)


npzwrite("./Data/Data_fish.npy", OUT.fish_xy)
npzwrite("./Data/Data_fishers.npy", OUT.cons_xy)
npzwrite("./Data/Data_clusters.npy", OUT.schl_xy)
npzwrite("./Data/Data_harvest.npy", OUT.cons_H)

npzwrite("./Data/Data_simple.npz", ["x"=>1, "CPUE"=>CPUE, "Tau"=>Tau])