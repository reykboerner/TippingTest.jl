module TippingTest

using CriticalTransitions: RateSystem, ForcingProfile
using StaticArrays: SVector

include("null_model.jl")

export LinearNullModel
export RelaxNullModel, HarmonicOscillatorNullModel

end
