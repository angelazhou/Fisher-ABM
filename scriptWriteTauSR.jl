@everywhere using Devectorize
@everywhere using NPZ
@everywhere using Types, Constants

require("sub_functions.jl");
require("sub_init.jl"); 
require("sub_routines.jl"); 
require("ExperimentsP.jl");

println("Libraries loaded")
trials = 1; 

f = open("TauSR_out-7fish-40trip.txt","w");


for i = 1:trials

    	println(i)
	@time CPUE,s_CPUE_int, CPUE_var, Tau, s_Tau_s_R = sim_simple(0)
	write(f, "Trial number: ", i, "\n")
	writedlm(f, Tau, '\n')
	write(f, "tau_s_r: \n")
	writedlm(f, s_Tau_s_R, '\t'); 

end

close(f)
