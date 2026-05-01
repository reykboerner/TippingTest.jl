"""
    LinearNullModel

Abstract supertype for a linear null model defined by a differential equation and a set of
parameters.
"""
abstract type LinearNullModel end

"""
    RelaxNullModel <: LinearNullModel

A simple linear dynamical system with inertia ``m`` that responds to the forcing ``F``
with sensitivity ``\alpha``, following the differential equation
```math
m \\dot y = -(y - y_0) + \\alpha F(t) \\.
```
Here ``y_0`` is the reference state at ``F=0``.

## Fields
- `y0`: Reference state
- `params`: Parameter vector `[alpha, m]`
"""
struct RelaxNullModel{T<:Real} <: LinearNullModel
    y0::T
    params::Vector{T}
end

function(nm::RelaxNullModel)(u, p, t)
    du = (-(u[1] - nm.y0) + nm.params[1]*p[1])/nm.params[2]
    return SVector{1}(du)
end

struct HarmonicOscillatorNullModel{T<:Real} <: LinearNullModel
    y0::T
    inertia::T
    sensitivity::T
    damping::T
end

function(nm::HarmonicOscillatorNullModel)(u, p, t)
    x, v = u
    dx = v
    dv = (-(x - nm.y0) - nm.damping*v + nm.sensitivity*p[1])/nm.inertia
    return SVector{2}(dx, dv)
end

params(nm::HarmonicOscillatorNullModel) = [nm.inertia, nm.sensitivity, nm.damping]
HarmonicOscillatorNullModel(y0, p::Vector) = RelaxNullModel(y0, p[1], p[2], p[3])

struct GeneralNullModel{T<:Real, G} <: LinearNullModel
    y0::T
    greens_function::G
end

function (nm::GeneralNullModel)(u, p, t)
    error("GeneralNullModel not implemented.")
end