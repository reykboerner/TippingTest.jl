function decompose_response(observable, forcing, fit)
    residual = observable .- fit
    drdF = diff(residual) ./ diff(forcing)
    drdx = diff(residual) ./ diff(fit)
    return residual, drdF, drdx
end