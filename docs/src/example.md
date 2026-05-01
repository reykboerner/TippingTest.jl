# Example

## Linear system, linear forcing
As a very boring example, consider an observable timeseries `obs` and a forcing timeseries `forcing` that both increase linearly in time.

```@example 1
obs = range(1.0, 3.0, length=100)
forcing = range(0.0, 10.0, length=100)
time = 0.0:99.0

using CairoMakie # hide
f = Figure(size=(600, 300)); ax = Axis(f[1,1],
    xlabel="Time") # hide
lines!(ax, time, obs, label="Observable") #hide
lines!(ax, time, forcing, label="Forcing") #hide
axislegend(ax, position=:lt) #hide
f #hide
```

Here, the relationship between the observable and the forcing is $x(t) = 1 + 0.2 F(t)$, so the response is perfectly linear and a simple [`RelaxNullModel`](@ref) can explain the response.

```@example 1
using TippingTest
using Suppressor # hide

t_tr = (30, 70) # Transition phase limits (arbitrarily chosen)
guess = [1.0, 1.0] # Initial guess for the null model parameters

@suppress_err begin #hide
test = tipping_test(obs, forcing, time, t_tr;
    model=RelaxNullModel(obs[1], guess))

println("Fitted parameters: $(test.nullmodel.params)")
end # hide
```

As expected, the fitted parameters are $\alpha=0.2$ for the sensitivity and $m \approx 0$ for the inertia.

The residual is close to zero for all times, meaning that linear response can fully explain the time evolution of the observable and hence no tipping occurs.

```@example 1
@suppress_err begin #hide
test = tipping_test(obs, forcing, time, t_tr; # hide
    model=RelaxNullModel(1.0, guess)) # hide

f = Figure(size=(600, 300)); ax = Axis(f[1,1],
    xlabel="Time") # hide
lines!(ax, time, test.residual, label="Residual")
ylims!(ax, -1e-3, 1e-3)
axislegend(ax, position=:lt) #hide
f #hide
end # hide
```

## Ocean circulation box model

Consider **Stommel's ocean box model** ([Stommel, 1961](https://doi.org/10.1111/j.2153-3490.1961.tb00079.x)) of the thermohaline circulation, given in non-dimensional
form as a 2-dimensional system of ODEs:

```math
\begin{align}
    \dot{x} &= -\alpha(x-1) - x(1+\mu(x-y)^2) \nonumber \\
    \dot{y} &= F_a - y(1+\mu(x-y)^2)
\end{align}
```

Here $x$ and $y$ represent the meridional temperature and salinity difference between the southern and northern box, respectively. The freshwater flux ``F_a`` is the main forcing parameter; typical values for the model parameters are
``\alpha=360`` and ``\mu=6.25``.

The relevant observable is the overturning strength ``q = 1 + \mu (x-y)^2``. We are interested in the response to the forcing parameter ``F_a``.

The model can be defined as a type of ODE system using [`CriticalTransitions.jl`](https://juliadynamics.github.io/CriticalTransitions.jl/latest/), which is based on the interface of `DynamicalSystems.jl`.

```@example 2
using CriticalTransitions
using TippingTest

function stommel(u,p,t)
    x, y = u
    F, alpha, mu = p 
    dx = - alpha*(x - 1) - x*(1 + mu*(x - y)^2)
    dy = F - y*(1 + mu*(x - y)^2)
    return SVector{2}(dx, dy)
end

p = [1.0, 360, 6.25] # Standard model parameters
u0 = [0.99, 0.21] # Initial state
base_system = CoupledODEs(stommel, u0, p)
```

Let us also write a function that computes the AMOC strength timeseries from simulation output:

```@example 2
amoc(traj; mu=6.25) = 1 .+ mu .*(traj[1][:,1] .- traj[1][:,2]) .^2
```

### Generate trajectory data
First, we need to generate trajectory data of the model under a given forcing timeseries. Systems with time-dependent forcing parameters can easily be constructed using the `RateSystem` type of `CriticalTransitions.jl`.

Suppose the freshwater forcing undergoes an increase followed by a decrease to a final level that is larger than its original value. An idealized protocol is given by the following function, combining a Gaussian bump with a hyperbolic tangent:

```@example 2
protocol(t) = exp(-50*(t-0.5)^2) + 0.3*(0.5*tanh(5*(t-0.5))+0.5)
fp = ForcingProfile(protocol, (0.0,1.0))
```

We consider two cases, differing only in the amplitude of the forcing `fmax`. For each case, we construct the `RateSystem` and run the trajectory:

```@example 2
fmax = [0.28, 0.20]

rs1 = RateSystem(base_system, fp, 1; forcing_duration=100.0, forcing_scale=fmax[1])
rs2 = RateSystem(base_system, fp, 1; forcing_duration=100.0, forcing_scale=fmax[2])

forcing1 = parameter.(rs1, 0.0:0.1:100.0, 1)
forcing2 = parameter.(rs2, 0.0:0.1:100.0, 1)

tr1 = trajectory(rs1, 100.0, u0)
tr2 = trajectory(rs2, 100.0, u0)

using CairoMakie # hide
f = Figure(size=(600, 400)) # hide
ax1 = Axis(f[1,1], xlabel="Time", ylabel=L"Forcing $F_a$") # hide
ax2 = Axis(f[2,1], xlabel="Time", ylabel=L"AMOC strength $q$") # hide
lines!(ax1, 0.0:0.1:100, forcing1, label="Fmax = 0.28") # hide
lines!(ax1, 0.0:0.1:100, forcing2, label="Fmax = 0.20") # hide
lines!(ax2, 0.0:0.1:100, amoc(tr1)) # hide
lines!(ax2, 0.0:0.1:100, amoc(tr2)) # hide
axislegend(ax1, position=:lt) #hide
f #hide
```

### Apply tipping test
```@example 2
time = 0.0:0.1:100
t_tr = (30, 70)

obs1 = amoc(tr1)
obs2 = amoc(tr2)

test1 = tipping_test(obs1, forcing1, time, t_tr;
    model=RelaxNullModel(obs1[1], [-1.0, 2.0]))
test2 = tipping_test(obs2, forcing2, time, t_tr;
    model=RelaxNullModel(obs2[1], [-1.0, 2.0]))

using CairoMakie # hide
f = Figure(size=(600, 300)) # hide
ax1 = Axis(f[1,1], xlabel="Time", ylabel=L"AMOC strength $q$") # hide
ax2 = Axis(f[1,2], xlabel="Time", ylabel="Residual") # hide
lines!(ax1, time, amoc(tr1)) # hide
lines!(ax1, time, amoc(tr2)) # hide
lines!(ax1, time, test1.linear_response) # hide
lines!(ax1, time, test2.linear_response) # hide
lines!(ax2, time, test1.residual) # hide
lines!(ax2, time, test2.residual) # hide
f #hide
```

The linear null model can approximately describe the evolution of the case with `Fmax=0.2`, but the residual grows continually in the case `Fmax=0.28`, indicative of a positive nonlinear feedback. We therefore classify the latter case as a tipping event.