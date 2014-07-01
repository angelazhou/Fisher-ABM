Agent Based Model for the CNH project

7/1 --------------------------
Output is not working for parallelized runs (i.e. multiple trips); data is coarse grained
to write to output every other iteration for the first 20 and every 20 iterations thereafter.

sn series of experiments now supported again. 


6/30 --------------------------
Parallelized code. Incorporated initial extraction of tau_s_r. OUT temporarily not operational. 



6/13 --------------------------
**New Dependencies: Devectorize.jl (optimize devectorized code with minimal modifications) https://github.com/lindahua/Devectorize.jl 
Devectorize operates on: +,-,.+,.-,.*,./,.^,max,min,clamp,blend,.==,.!=,.<,.>, .<=, .>=, sqrt, cbrt, sqr, .... etc... 

Distance.jl implements faster Euclidean distance metrics 

Unfortunately some of the expressions appear to be too complex to be automatically unlooped. Cut down runtime by 10-15% by automatic devectorization. 

Fixed cross-platform issues and have a clean running version for Ubuntu 12.04 32-bit in Virtualbox. 
- Profiled runtime for one repeat: 
  Out of 1868 samples of sim_simple, approximately 56% found in fnc_distance in sub_functions.jl; 38% found in fnc_information. 



  Implementing Distance.jl should increase efficiency of calculating Euclidean distances. 
The periodic boundaries (lines 37-39 in fnc_distance) were particularly expensive as well. 
KDTree implementation of nearest neighbors should help find the nearest fish significantly faster. 
