"""
    TippingTestResult

Output of the [`tipping_test`](@ref) method.

## Fields
- `nullmodel`: The fitted linear null model
- `linear_response`: The response time series predicted by the linear null model
- `residual`: The nonlinear residual response, i.e. the component of the observable not explainable by linear response
- `state_dependence`: Time series of the derivative dR/dx, where R is the residual and x the linear response
- `forcing_dependence`: Time series of the derivative dR/dF, where R is the residual and F the forcing
"""
struct TippingTestResult{S, T}
    nullmodel::S
    linear_response::Vector{T}
    residual::Vector{T}
    state_dependence::Vector{T}
    forcing_dependence::Vector{T}
end

"""
    tipping_test(observable, forcing, time, t_tr; kwargs...)

Runs the tipping analysis for a given `observable` timeseries and corresponding `forcing`
timeseries.

The `time` argument specifies the set of time points at which the `observable` and
`forcing` data are known (Note: both `observable` and `forcing` vectors must have the
same length and refer to the same time points).

With the Tuple `t_tr = (t_s, t_e)`, the user specifies the start (`t_s`) and end (`t_e`)
times of the transition phase `t_tr`. This phase should contain the majority of the 
shift from regime A to regime B.

The linear null model is specified via the `model` keyword argument. This model is either
used directly with the parameters set by the user (`fit=false`) or the `model.params` are
fitted to the observable timeseries using the given `weights` (`fit=true`).

## Keyword arguments
- `model`: Instance of a `LinearNullModel` with initial guess for its parameters `p`
- `weights`: Vector of fitting weights applied to the time intervals `[t_A, t_tr, t_B]`,
- `fit=true`: whether to optimize the parameters of `model` (true) or use `model` as given (false)
"""
function tipping_test(observable, forcing, time, t_tr::Tuple;
    model::LinearNullModel=RelaxNullModel(observable[1], [1.0, 1.0]),
    weights::Vector=[1,0,0],
    fit=true
    )

    model_type = typeof(model)

    if fit
        linear_response, params = fit_nullmodel(observable, forcing, model.params;
            time, t_tr, model.y0, weights)
    else
        params = model.params
        sys = CoupledODEs(model, [model.y0], [0.0])
        total_time = time[end] - time[1]
        Δt=time[end]-time[end-1]
        domain = range(0.0, 1.0, length=length(forcing))
        F = linear_interpolation(domain, forcing .- forcing[1])
        fp = ForcingProfile(F, (0.0, 1.0))
        rsys = RateSystem(sys, fp, 1; forcing_duration=AbstractFloat(total_time), t0=time[1], forcing_start_time=time[1])
        linear_response = trajectory(rsys, total_time, [observable[1]]; Δt)[1][:,1]
    end

    fitted_model = model_type(model.y0, params)
    residual = sign(params[1])*(observable .- linear_response)
    drdF = diff(residual) ./ diff(forcing)
    drdx = diff(residual) ./ diff(linear_response)

    return TippingTestResult(fitted_model, linear_response, residual, drdx, drdF)
end