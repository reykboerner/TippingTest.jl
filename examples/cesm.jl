# # Tutorial
# ## Example: AMOC tipping under CO2 forcing

# > This example illustrates the main package functionality and reproduces the
# > results shown in Fig. 3 of [Börner & Dijkstra (2026)](https://doi.org/10.5194/egusphere-2026-3507).

# As a tipping system, we consider the Atlantic Meridional Overturning Circulation (AMOC),
# a key component of the global ocean circulation. A standard observable is the AMOC strength
# at 26°N, measured in units of Sverdrup (Sv). The forcing we consider here is the logarithm
# of the atmospheric CO2 concentration (normalized by preindustrial levels of 285 ppm).

# Our dataset contains simulations with the Community Earth System Model (CESM) under
# greenhouse gas emissions scenarios (see the [paper](https://doi.org/10.5194/egusphere-2026-3507) for details).
# Specifically, we here consider two scenarios: (a) RCP2.6, where the AMOC does not tip, and 
# (b) RCP4.5, where the AMOC tips (both with constant background freshwater flux of ``F_H=0.18`` Sv).

# First, let us load the `cesm_amoc_forcing_data.nc` file containing the dataset. It is stored in the package
# github repository and contains all forcing scenarios discussed in the paper.

using NCDatasets
path = get(ENV, "EXAMPLE_DIR", @__DIR__) #hide
data = NCDataset(joinpath(path, "cesm_amoc_forcing_data.nc"));

# Now, we extract the time, forcing, and observable data for the two cases of interest.

cases = ["fh18_rcp26", "fh18_rcp45"]

time = data["time_rcp"][:]
forcing = [log.(data["co2_"*c][:]/285) for c in cases]
amoc = [data["amoc_"*c][:] for c in cases];

# The forcing and observable timeseries look like this:

using CairoMakie # Plotting package
f = Figure(size=(800,400)); ax = Matrix{Axis}(undef, 2, 2)
for i in 1:2
    for (j, v) in enumerate(["log CO2", "AMOC (Sv)"])
        ax[j,i] = Axis(f[j,i])
        i > 1 ? ax[j, i].yticklabelsvisible = false : nothing
        ax[j,1].ylabel = v
    end
    lines!(ax[1,i], time, forcing[i]); lines!(ax[2,i], time, amoc[i])
    ax[2,i].xlabel = "Time (Year CE)"
    ax[1,i].title = ["RCP2.6 (F_H = 0.18 Sv)", "RCP4.5 (F_H = 0.18 Sv)"][i]
end
linkyaxes!(ax[1,:]); linkyaxes!(ax[2,:])
f

# ### Setup

# To apply the tipping test, we first choose the time interval
# ``\tau_{tr} = [t_s, t_e]``, which should roughly represent the transition phase of
# the suspected tipping event. We select the years from 2026 to 2200.

t_s = findfirst(data["time_rcp"][:] .>= 2026)
t_e = findfirst(data["time_rcp"][:] .>= 2200)
println(t_s, t_e)

# As the reference state ``x_*``, we set an AMOC strength of 17.5 Sv.

x_ref = 17.5;

# As a linear null model, we choose the damped, driven harmonic oscillator because of 
# the oscillatory AMOC dynamics observed in the RCP2.6 case. This null model is
# pre-defined in TippingTest.jl and has three parameters: the forcing sensitivity
# ``\beta``, inertia ``m``, and damping timescale ``\gamma``.

using TippingTest

## Initial parameter guess
p_guess = [-0.01, 30.0, 10.0] # [beta, m, gamma]
x_init = [16.5, 0.04] # Null model initial condition

model = HarmonicOscillatorNullModel(x_ref, p_guess)

# ### Run the tipping test

# We can now run the tipping test. We start with the RCP2.6 case and fit the null model
# parameters (`fit = true`) based on the data in the time intervals outside of
# ``\tau_{tr}`` (`weights = [1,0,1]`).

test_rcp26 = tipping_test(amoc[1], forcing[1], time, (t_s, t_e);
    model, init=x_init, weights=[1, 0, 1], fit=true, iterations=200)

## Print fit result
println("Fitted null model parameters: $(test_rcp26.nullmodel.params)")

# The fitted null model is stored as `test_rcp26.nullmodel`. We can now use this null
# model for the RCP4.5 case to see whether the same null model can explain the AMOC
# response under different CO2 forcing.

# Thus, we run the `tipping_test` for the second scenario, now without new fitting:

test_rcp45 = tipping_test(amoc[2], forcing[2], time, (t_s, t_e);
    model=test_rcp26.nullmodel, init=x_init, weights=[1, 0, 1], fit=false);

# Let us store both results and set a threshold for the nonlinear residual ``\eta_c``
# of 3 Sv.

result = [test_rcp26, test_rcp45]
eta_c = 3;

# We can now plot the results to see whether the linear response predicted by the null
# model can explain the AMOC behavior. As we see, the nonlinear residual remains mostly
# below ``\eta_c`` in the RCP2.6 case, whereas for RCP4.5 it increases significantly and 
# remains persistently above ``\eta_c`` until the end of the simulation.

f = Figure(size=(800,400))
ax = Matrix{Axis}(undef, 2, 2)
for i in 1:2
    for (j, v) in enumerate(["AMOC (Sv)", "Residual η (Sv)"])
        ax[j,i] = Axis(f[j,i])
        i > 1 ? ax[j, i].yticklabelsvisible = false : nothing
        ax[j,1].ylabel = v
        xlims!(ax[j,i], (1850,2500))
    end
    hlines!(ax[2,i], eta_c; color="black")
    lines!(ax[1,i], time, amoc[i], label="Observable")
    lines!(ax[1,i], time, result[i].linear_response, label="Null model prediction")
    lines!(ax[2,i], time, result[i].residual)
    ax[2,i].xlabel = "Time (Year CE)"
    ax[1,i].title = ["RCP2.6 (F_H = 0.18 Sv)", "RCP4.5 (F_H = 0.18 Sv)"][i]
    lower = fill(eta_c, length(time))
    upper = ifelse.(result[i].residual .> eta_c, result[i].residual, NaN)
    band!(ax[2,i], time, lower, upper, color = (:orange, 0.3))
end
linkyaxes!(ax[1,:])
linkyaxes!(ax[2,:])
axislegend(ax[1,1], position=:lb)
f

# ## Copy-paste code
# You can copy-paste the code below to run this example.
# Replace `path` by your local relative path where the data file
# `cesm_amoc_forcing_data.nc` is stored.

# ```julia
# using CairoMakie
# using NCDatasets
# using TippingTest
# 
# path = get(ENV, "EXAMPLE_DIR", @__DIR__) #hide
# data = NCDataset(joinpath(path, "cesm_amoc_forcing_data.nc"));
# cases = ["fh18_rcp26", "fh18_rcp45"]
# time = data["time_rcp"][:]
# forcing = [log.(data["co2_"*c][:]/285) for c in cases]
# amoc = [data["amoc_"*c][:] for c in cases]
# 
# t_s = findfirst(data["time_rcp"][:] .>= 2026)
# t_e = findfirst(data["time_rcp"][:] .>= 2200)
# x_ref = 17.5
# p_guess = [-0.01, 30.0, 10.0] # [beta, m, gamma]
# x_init = [16.5, 0.04] # Null model initial condition
# 
# model = HarmonicOscillatorNullModel(x_ref, p_guess)
# test_rcp26 = tipping_test(amoc[1], forcing[1], time, (t_s, t_e);
#     model, init=x_init, weights=[1, 0, 1], fit=true, iterations=200)
# println("Fitted null model parameters: $(test_rcp26.nullmodel.params)")
# 
# test_rcp45 = tipping_test(amoc[2], forcing[2], time, (t_s, t_e);
#     model=test_rcp26.nullmodel, init=x_init, weights=[1, 0, 1], fit=false)
# 
# result = [test_rcp26, test_rcp45]
# eta_c = 3
# 
# f = Figure(size=(800,400))
# ax = Matrix{Axis}(undef, 2, 2)
# for i in 1:2
#     for (j, v) in enumerate(["AMOC (Sv)", "Residual η (Sv)"])
#         ax[j,i] = Axis(f[j,i])
#         i > 1 ? ax[j, i].yticklabelsvisible = false : nothing
#         ax[j,1].ylabel = v
#         xlims!(ax[j,i], (1850,2500))
#     end
#     hlines!(ax[2,i], eta_c; color="black")
#     lines!(ax[1,i], time, amoc[i], label="Observable")
#     lines!(ax[1,i], time, result[i].linear_response, label="Null model prediction")
#     lines!(ax[2,i], time, result[i].residual)
#     ax[2,i].xlabel = "Time (Year CE)"
#     ax[1,i].title = ["RCP2.6 (F_H = 0.18 Sv)", "RCP4.5 (F_H = 0.18 Sv)"][i]
#     lower = fill(eta_c, length(time))
#     upper = ifelse.(result[i].residual .> eta_c, result[i].residual, NaN)
#     band!(ax[2,i], time, lower, upper, color = (:orange, 0.3))
# end
# linkyaxes!(ax[1,:])
# linkyaxes!(ax[2,:])
# axislegend(ax[1,1], position=:lb)
# f
# ```