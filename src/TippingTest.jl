module TippingTest

using CriticalTransitions: RateSystem, ForcingProfile
using StaticArrays: SVector

include("null_model.jl")
include("trajectory.jl")
include("decompose_response.jl")

export LinearNullModel
export RelaxNullModel, HarmonicOscillatorNullModel
export params
export SVector # from StaticArrays

end
