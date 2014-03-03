module Types

export Fish, Fishers, Vars, Tau, Output

#### Define Fish type
type Fish
    xy::Array{Float64} # fish location in xy
    cl::Array{Float64} # cluster xy
end

#### Define Fisher type
type Fishers
    xy::Array{Float64}
    H::Array{Float64} # harvest count
    S::Array{Int} # make(1)/break(0) friendships
    CN::Array{Int} # contact network
    Dmin::Array{Float64} # distance to nearest fish
    DDx::Array{Float64} # x component
    DDy::Array{Float64} # y component
    ANG::Array{Float64} # angle
    VR::Array{Float64} # speed
    JJ::Array{Int} # index of nearest fish
    KK::Array{Int} # 1/0 harvest index
end

#### Define Variable type
type Tau
    n::Array{Int}
    t::Array{Int}
    s::Array{Float64}
    mu::Array{Float64}
    S::Array{Float64}
    M::Array{Float64}
    s2::Array{Float64}
    dmu::Array{Float64}
    ds2::Array{Float64}
end

#### Output variable for plotting
type Output
    fish_xy::Array{Float64}
    cons_xy::Array{Float64}
    clus_xy::Array{Float64}
    cons_H::Array{Float64}
end

end
