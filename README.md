# TippingTest.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://reykboerner.github.io/TippingTest.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://reykboerner.github.io/TippingTest.jl/dev/)
[![Build Status](https://github.com/reykboerner/TippingTest.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/reykboerner/TippingTest.jl/actions/workflows/CI.yml?query=branch%3Amain)

A Julia implementation of the tipping classification test proposed by
[Börner & Dijsktra](https://doi.org/10.5194/egusphere-2026-3507).

Basic usage:

```julia
test = tipping_test(observable, forcing, time, (t1, t2);
    model=LinearNullModel(...), ...)
```

More details in the [documentation](https://reykboerner.github.io/TippingTest.jl/stable/).

**Reference:**

> Börner, R. and Dijkstra, H. A.: To tip or not to tip (in review), [DOI: 10.5194/egusphere-2026-3507](https://doi.org/10.5194/egusphere-2026-3507).

This work is funded by the [ClimTip](https://climate-tipping-points.eu) project.