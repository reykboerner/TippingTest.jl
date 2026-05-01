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

## Keyword arguments
- `model`: Instance of a `LinearNullModel` with initial guess for its parameters `p`
- `weights`: Vector of fitting weights applied to the time intervals `[t_A, t_tr, t_B]`
"""
function tipping_test(observable, forcing, time, t_tr::Tuple;
    model::LinearNullModel=RelaxNullModel(observable[1], [1.0, 1.0]),
    weights::Vector=[1,0,0]
    )

    model_type = typeof(model)
    linear_response, params = fit_nullmodel(observable, forcing, model.params;
        time, t_tr, model.y0, weights)

    fitted_model = model_type(model.y0, params)
    residual = sign(params[1])*(observable .- linear_response)
    drdF = diff(residual) ./ diff(forcing)
    drdx = diff(residual) ./ diff(linear_response)

    return TippingTestResult(fitted_model, linear_response, residual, drdx, drdF)
end