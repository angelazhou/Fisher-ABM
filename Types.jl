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
    x::Array{Float64,2} # location
    H::Array{Float64,1} # harvest count
    S::Array{Int32,1} # make(1)/break(-1) friendships
    MI::Array{Int64,1} # index of steaming or searching
    CN::Array{Int64,2} # contact network
    Dmin::Array{Float64,1} # distance to nearest fish
    DXY::Array{Float64,2} # direction vector (unit)
    VR::Array{Float64,1} # speed
    JJ::Array{Int64,1} # index of nearest fish
    KK::Array{Int64,1} # 1/0 harvest index
    cs::Array{Float64,1} # cumulative harvest
    Dist::Array{Float64,1} # cumulative distance traveled 
end

#### Output variable for plotting
type Output
    fish_xy::Array{Float64}
    cons_xy::Array{Float64}
    schl_xy::Array{Float64}
    cons_H::Array{Float64}
end

end
