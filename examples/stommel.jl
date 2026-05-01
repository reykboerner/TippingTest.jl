include("../src/TippingTest.jl")
using .TippingTest
using CairoMakie
using CriticalTransitions

function stommel(u,p,t)
    x, y = u
    F, alpha, mu = p 
    dx = - alpha*(x - 1) - x*(1 + mu*(x - y)^2)
    dy = F - y*(1 + mu*(x - y)^2)
    return SVector{2}(dx, dy)
end

bump(x) = exp(-50*(x-0.5)^2) + 0.3*(0.5*tanh(5*(x-0.5))+0.5)
amoc(traj; mu=6.25) = 1 .+ mu .*(traj[1][:,1] .- traj[1][:,2]) .^2

fp = ForcingProfile(bump, (0.0,1.0))

p = [1.0, 360, 6.25]
fmax = [0.26, 0.24]
sys = CoupledODEs(stommel, [1.0,1.0], p)
rs1 = RateSystem(sys, fp, 1; forcing_start_time=0.0, forcing_duration=100.0, forcing_scale=fmax[1])
rs2 = RateSystem(sys, fp, 1; forcing_start_time=0.0, forcing_duration=100.0, forcing_scale=fmax[2])
eq = trajectory(sys, 10, [1.0, 0.25])[1][end,:]

tr1 = trajectory(rs1, 100.0, eq)
tr2 = trajectory(rs2, 100.0, eq)

begin
    f = Figure()
    ax1 = Axis(f[1,1])
    ax2 = Axis(f[2,1])
    lines!(ax1, 0..1, bump)
    lines!(ax2, tr1[2], amoc(tr1))
    lines!(ax2, tr2[2], amoc(tr2))
    f
end

y0 = amoc(tr1)[1]
nm = RelaxNullModel(y0, 1.0, 0.2)
nsys = CoupledODEs(nm, [y0], [1.0])