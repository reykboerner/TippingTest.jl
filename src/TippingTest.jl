module TippingTest

using CriticalTransitions: RateSystem, ForcingProfile, CoupledODEs, trajectory, parameters
using Interpolations: linear_interpolation
using Optim: Optim, optimize, GradientDescent, LBFGS, Fminbox
using StaticArrays: SVector
using Statistics: mean

include("null_model.jl")
include("fit_model.jl")
include("result.jl")
include("utils.jl")

export LinearNullModel, TippingTestResult
export RelaxNullModel, HarmonicOscillatorNullModel
export fit_nullmodel
export tipping_test
export parameter # from utils

export SVector # from StaticArrays

end
