using Pkg
Pkg.activate("/Users/Borne007/Library/CloudStorage/OneDrive-UniversiteitUtrecht/Documents/work/research/synthesis/tipping_definitions/code/TippingTest.jl")
using TippingTest
using CairoMakie
using CriticalTransitions

# Define Stommel model
function stommel(u,p,t)
    x, y = u
    F, alpha, mu = p 
    dx = - alpha*(x - 1) - x*(1 + mu*(x - y)^2)
    dy = F - y*(1 + mu*(x - y)^2)
    return SVector{2}(dx, dy)
end

# Define forcing protocol
bump(t) = exp(-50*(t-0.5)^2) + 0.3*(0.5*tanh(5*(t-0.5))+0.5)
amoc(traj; mu=6.25) = 1 .+ mu .*(traj[1][:,1] .- traj[1][:,2]) .^2
fp = ForcingProfile(bump, (0.0,1.0))

# Generate model timeseries
p = [1.0, 360, 6.25]
fmax = [0.28, 0.20]
sys = CoupledODEs(stommel, [1.0,1.0], p)
rs1 = RateSystem(sys, fp, 1; forcing_start_time=0.0, forcing_duration=100.0, forcing_scale=fmax[1])
rs2 = RateSystem(sys, fp, 1; forcing_start_time=0.0, forcing_duration=100.0, forcing_scale=fmax[2])
eq = trajectory(sys, 10, [1.0, 0.25])[1][end,:]

tr1 = trajectory(rs1, 100.0, eq)
tr2 = trajectory(rs2, 100.0, eq)

f1 = parameter.(rs1, 0.0:0.1:100.0, 1)
f2 = parameter.(rs2, 0.0:0.1:100.0, 1)

begin
    f = Figure()
    ax1 = Axis(f[1,1])
    ax2 = Axis(f[2,1])
    lines!(ax1, 0.0:0.1:100.0, f1)
    lines!(ax1, 0.0:0.1:100.0, f2)
    lines!(ax2, tr1[2], amoc(tr1))
    lines!(ax2, tr2[2], amoc(tr2))
    f
end



using Statistics
using Interpolations
using Optim

fit1 = fit_nullmodel(amoc(tr1), f1, [-1.0, 1.0]; t_tr=(30, 75), fit_weights=[1,0,0], time=0:0.1:100)
fit2 = fit_nullmodel(amoc(tr2), f2, [-1.0, 1.0]; t_tr=(30, 75), fit_weights=[1,0,0], time=0:0.1:100)

begin
    f = Figure()
    ax1 = Axis(f[1,1])
    ax2 = Axis(f[1,2])
    lines!(ax1, tr1[2], amoc(tr1))
    lines!(ax2, tr2[2], amoc(tr2))
    lines!(ax1, 0:0.1:100, fit1[1])
    lines!(ax2, 0:0.1:100, fit2[1])
    f
end


y0 = amoc(tr1)[1]
nm = RelaxNullModel(y0, [-4.0, 1.5])

nsys = CoupledODEs(nm, [y0, 0.0], [0.0])
nrs1 = RateSystem(nsys, fp, 1, forcing_start_time=0.0, forcing_duration=100.0, forcing_scale=fmax[1])
ntr1 = trajectory(nrs1, 100, [y0, 0.3])

nrs2 = RateSystem(nsys, fp, 1, forcing_start_time=0.0, forcing_duration=100.0, forcing_scale=fmax[2])
ntr2 = trajectory(nrs2, 100, [y0, 0.0])

