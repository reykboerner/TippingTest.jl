# API

![](assets/fig01.png)

Figure: Problem setting. During the time interval ``\tau = [t_0, t_1]``, is the system tipping in
``\psi`` under the forcing ``F``? From [Börner & Dijkstra (2026)](https://doi.org/10.5194/egusphere-2026-3507).

## Tipping test

The [`tipping_test`](@ref) method is the main function performing the tipping analysis for
a given timeseries pair of an observable ``\psi(t)`` and forcing ``F(t)``.

```@docs
tipping_test
```

The [`tipping_test`](@ref) function returns a [`TippingTestResult`](@ref):

```@docs
TippingTestResult
```

## Null models

All null models are a subtype of the general [`LinearNullModel`](@ref) type.

As elementary null models, a linear damping model ([`RelaxNullModel`](@ref)) and the damped,
driven harmonic oscillator ([`HarmonicOscillatorNullModel`](@ref)) are currently implemented.

```@docs
LinearNullModel
RelaxNullModel
HarmonicOscillatorNullModel
```

## Fitting a null model
The parameters of a given [`LinearNullModel`](@ref) can be optimized in the [`tipping_test`](@ref)
method by setting the keyword argument `fit = true`.

Alternatively, the fitting step can be performed independently using [`fit_nullmodel`](@ref).

```@docs
fit_nullmodel
```

## Package dependencies
TippingTest.jl uses the [`CriticalTransitions.jl`](https://juliadynamics.github.io/CriticalTransitions.jl/stable/) package, a subpackage of DynamicalSystems.jl, to solve the [`LinearNullModel`](@ref) in time. The null model is constructed as a `CoupledODEs` system and the forcing is applied using the `RateSystem` functionality.

Fitting the null model parameters is performed using the [`Optim.jl`](https://julianlsolvers.github.io/Optim.jl/stable/) package with the default `NelderMead` solver. The function to minimize is simply the sum of squared distances between the observable and the null model solution over time, using the relative weights specified by the `weights` keyword argument.