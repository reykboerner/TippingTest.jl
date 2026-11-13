"""
    LinearNullModel

Abstract supertype for a linear null model defined by a differential equation and a set of
parameters.
"""
abstract type LinearNullModel end

"""
    RelaxNullModel <: LinearNullModel

A simple linear dynamical system with inertia ``m`` that responds to the forcing ``F``
with sensitivity ``\\beta``, following the differential equation
```math
m \\dot y = -(x - x_0) + \\beta F(t) .
```
Here ``x_0`` is the reference state at ``F=0``.

## Fields
- `x0`: Reference state
- `params`: Parameter vector `[beta, m]`
"""
struct RelaxNullModel{T<:Real} <: LinearNullModel
    x0::T
    params::Vector{T}
end

function(nm::RelaxNullModel)(u, p, t)
    du = (-(u[1] - nm.x0) + nm.params[1]*p[1])/nm.params[2]
    return SVector{1}(du)
end

@doc raw"""
    HarmonicOscillatorNullModel <: LinearNullModel

A damped, driven harmonic oscillator that responds to forcing ``F`` according to
```math
\begin{aligned}
\dot x &= v , \\
\dot v &= -\frac{1}{m^2}[(x - x_0 - \beta F(t)) - \gamma v] .
\end{aligned}
```
Here ``x_0`` is the reference state at ``F=0``, ``\beta`` is the forcing
sensitivity, ``m`` is the inertia, and ``\gamma`` is the damping coefficient.

## Fields
- `x0`: Reference state
- `params`: Parameter vector `[beta, m, gamma]`
"""
struct HarmonicOscillatorNullModel{T<:Real} <: LinearNullModel
    x0::T
    params::Vector{T}
end

function(nm::HarmonicOscillatorNullModel)(u, p, t)
    x, v = u
    dx = v
    dv = (-(x - nm.x0 - nm.params[1]*p[1]) - nm.params[3]*v)/(nm.params[2])^2
    return SVector{2}(dx, dv)
end

struct GeneralNullModel{T<:Real, G} <: LinearNullModel
    x0::T
    greens_function::G
end

function (nm::GeneralNullModel)(u, p, t)
    error("GeneralNullModel not implemented.")
end