module Types

export Fish, Fishers, Output


#### Define Fish type
type Fish
    fx::Array{Float64} # fish location in xy
    fs::Array{Int} # index of school fish is associated with
    sx::Array{Float64} # school xy
end

#### Define Fisher type
type Fishers
    x::Array{Float64} # location
    H::Array{Float64} # harvest count
    S::Array{Int} # make(1)/break(-1) friendships
    MI::Array{Int} # index of steaming or searching
    CN::Array{Int} # contact network
    Dmin::Array{Float64} # distance to nearest fish
    DXY::Array{Float64} # direction vector (unit)
    VR::Array{Float64} # speed
    JJ::Array{Int} # index of nearest fish
    KK::Array{Int} # 1/0 harvest index
    cs::Array{Float64} # cumulative harvest
    Dist::Array{Float64} # cumulative distance traveled 
    Dist_s_R::Array{Float64} # record time of first school encounter
end

#### Output variable for plotting
type Output
    fish_xy::Array{Array}
    cons_xy::Array{Array}
    schl_xy::Array{Array}
    cons_H::Array{Array}
    cons_CN::Array{Array}
end

end
