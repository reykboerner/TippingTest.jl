"""
    fit_nullmodel(observable, forcing, p_guess; kwargs...)

Fits a `LinearNullModel` to the `observable` time series given a `forcing` time series.

Starting from a parameter guess `p_guess`, fitting is performed as a weighted
least-squares fit using the Optim.jl package. Relative weights can be specified for the 
time intervals `t_A` (pre-transition phase), `t_tr` (transition phase) and `t_B`
(post-transition phase) using the `weights` keyword argument. The default is
`weights=[1,0,0]`, i.e. the fitting is only performed over `t_A`.

Returns the timeseries of the fitted null model and the optimal null model parameter vector.

## Keyword arguments
- `model = RelaxNullModel`: Type of `LinearNullModel`
- `time = 0:length(observable)-1`: Time range of observable (and forcing)
- `t_tr = (t_s, t_e)`: Tuple containing the start (`t_s`) and end (`t_e`) time of the transition phase `t_tr`
- `y0 = observable[1]`: Reference state of null model
- `weights = [1, 0, 0]`: Relative fitting weights within the time intervals `[t_A, t_tr, t_B]`
"""
function fit_nullmodel(observable, forcing, p_guess;
    model::Type{<:LinearNullModel} = RelaxNullModel,
    time=0.0:length(observable)-1,
    t_tr=(nothing, nothing),
    y0=observable[1],
    weights = [1,0,0]
    )

    # Time indices of t_s and t_e
    t_s = findfirst(time .>= t_tr[1])
    t_e = findfirst(time .>= t_tr[2])

    # Set up null model forcing
    domain = range(0.0, 1.0, length=length(forcing))
    F = linear_interpolation(domain, forcing .- forcing[1])
    fp = ForcingProfile(F, (0.0, 1.0))

    function score(p)
        m = model(y0, p)
        sys = CoupledODEs(m, [y0], [0.0])
        rsys = RateSystem(sys, fp, 1; forcing_duration=AbstractFloat(time[end]))
        sol = trajectory(rsys, time[end], [observable[1]]; Δt=time[end]-time[end-1])
        resi = (observable .- sol[1][:,1]) .^2
        return (weights[1]*sum(resi[1:t_s-1]) +
            weights[2]*sum(resi[t_s:t_e-1]) +
            weights[3]*sum(resi[t_e:end]))
    end

    res = optimize(score, p_guess)

    m = model(y0, Optim.minimizer(res))
    sys = CoupledODEs(m, [y0], [0.0])
    rsys = RateSystem(sys, fp, 1; forcing_duration=time[end])
    sol = trajectory(rsys, time[end], [observable[1]]; Δt=time[end]-time[end-1])

    return sol[1][:,1], Optim.minimizer(res)
end