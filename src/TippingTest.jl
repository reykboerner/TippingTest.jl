module TippingTest

using CriticalTransitions: RateSystem, ForcingProfile, CoupledODEs, trajectory, parameters
using Interpolations: linear_interpolation
using Optim: optimize
using StaticArrays: SVector
using Statistics: mean

include("null_model.jl")
include("fit_model.jl")
include("utils.jl")

export LinearNullModel
export RelaxNullModel, HarmonicOscillatorNullModel
export fit_nullmodel
export parameter # from utils

export SVector # from StaticArrays

end
