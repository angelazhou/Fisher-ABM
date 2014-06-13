###### PRAMETERS / CONSTANTS for running the model to equilibrium
function init_equilibrium()

#### Initialize fish
Fish_cl = rand(Float64,PCL_n,2).*repmat([GRD_mx GRD_my],PCL_n,1);
Fish_xy = zeros(Float64,PF_n,2); # location of fish
#Fish_ci = zeros(Float64,PF_n); # index of cluster centre fishers are nearest
for i = 1:PF_n # place each fish
    j = ceil(rand(1)*PCL_n); # index of which cluster center
    #Fish_ci[i] = j[1];
    Fish_xy[i,:,1] = mod(Fish_cl[j,:,1] + randn(1,2).*PF_dx, [GRD_mx GRD_my]);
end
#fish = Fish(Fish_xy,Fish_ci,Fish_cl);
fish = Fish(Fish_xy,Fish_cl);

##### Initialize fishers
Cons_H     = zeros(Float64,PC_n); # catch at time t
Cons_xy    = zeros(Float64,PC_n,2); # Fisher locations through time
Cons_xy[:,:,1]=rand(Float64,PC_n,2).*repmat([GRD_mx GRD_my],PC_n,1);
Cons_s     = randn(PC_n); Cons_s[Cons_s.<0]=-1; Cons_s[Cons_s.>0]=1;
Cons_cn    = zeros(PC_n,PC_n);
Dmin       = zeros(Float64,PC_n); # distance to nearest fish
DXY         = [randn(PC_n) randn(PC_n)];
DXY         = DXY ./ sqrt(DXY[:,1].^2 + DXY[:,2].^2);
#DDx        = zeros(Float64,PC_n); # x vector compontent to nearest fish
#DDy        = zeros(Float64,PC_n); # y vector compontent to nearest fish
#ANG        = rand(PC_n) .* 360; # fisher direction angle
VR         = zeros(Float64,PC_n);  # speed modulator (proportional to distance to fish)
RN         = zeros(Float64,1,PC_n); # random communication (in fnc_information)
JJ         = zeros(Int,PC_n); # index of nearest fish (0 if nothing near)
KK         = zeros(Int,PC_n); # index of catch [0,1]
cs         = zeros(Float64,PC_n);
D          = ones(Float64,PC_n);
#M          = zeros(Float64,PC_n);
#S          = zeros(Float64,PC_n);
#s2         = zeros(Float64,PC_n);
#dmu        = zeros(Float64,PC_n);
#ds2        = zeros(Float64,PC_n);
#cons  = Fishers(Cons_xy,Cons_H,Cons_s,Cons_cn,Dmin,DXY,VR,JJ,KK,cs,D,M,S,s2,dmu,ds2);
cons       = Fishers(Cons_xy,Cons_H,Cons_s,Cons_cn,Dmin,DXY,VR,JJ,KK,cs,D);

##### Initialize output storage
OUT = Output(Fish_xy,Cons_xy,Fish_cl,Cons_H);

return fish,cons,OUT
end

#### REFS
# 1 - http://math.stackexchange.com/questions/52869/numerical-approximation-of-levy-flight/52870#52870
# 2 - http://www.johndcook.com/standard_deviation.html