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
    Ni::Array{Int} # index of nearest fish
    Dmin::Array{Float64} # distance to nearest fish
    DXY::Array{Float64} # direction unit vector
	H::Array{Float64} # harvest count (1=catch, 0=no_catch)
    S::Array{Int} # make(1)/break(-1) friendships
    MI::Array{Int} # index of steaming or searching
    SN::Array{Float64} # social network
    Ts::Array{Float64} # running mean time between schools for each fisher
    ts::Array{Float64} # current time between schools for each fisher
    ns::Array{Int} # number of schools visited
    states::Array{Int} #keep track of the current states of system
    f1::Array{Int} #keep track of amt time spent in school so far
    wrapX::Array{Int}
    wrapY::Array{Int}
    V::Array{Float64} # speed

end

#### Output variable for plotting
type Output
    fish_xy::Array{Float64}
    cons_xy::Array{Float64}
    schl_xy::Array{Float64}
    cons_H::Array{Float64}
    states::Array{Int}
end

end
