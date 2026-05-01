function fit_nullmodel(observable, forcing, p_guess;
    model::Type{<:LinearNullModel} = RelaxNullModel,
    time=0:length(observable)-1,
    t_tr=(nothing, nothing),
    fit_weights = [1,0,1]
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
        sys = CoupledODEs(m, u0, [0.0])
        rsys = RateSystem(sys, fp, 1)
        sol = trajectory(rsys, time[end], u0; Δt=time[end]-time[end-1])
        resi = (observable .- sol) .^2
        return (fit_weights[1]*sum(resi[1:t_s-1]) +
            fit_weights[2]*sum(resi[t_s:t_e-1]) +
            fit_weights[3]*sum(resi[t_e:end]))
    end

    res = optimize(score, p_guess)
    return minimizer(res), minimum(res)
end


function decompose_response(observable, forcing, fit)
    residual = observable .- fit
    drdF = diff(residual) ./ diff(forcing)
    drdx = diff(residual) ./ diff(fit)
    return residual, drdF, drdx
end