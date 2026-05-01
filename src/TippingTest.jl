module TippingTest

using CriticalTransitions: RateSystem, ForcingProfile
using Interpolations: linear_interpolation
using Optim: optimize
using StaticArrays: SVector

include("null_model.jl")
include("trajectory.jl")
include("decompose_response.jl")

export LinearNullModel
export RelaxNullModel, HarmonicOscillatorNullModel
export params
export fit_nullmodel, decompose_response
export SVector # from StaticArrays

end
