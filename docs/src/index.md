```@meta
CurrentModule = TippingTest
```

# TippingTest.jl

A Julia implementation of the tipping classification test proposed by
[Börner & Dijsktra](https://doi.org/10.5194/egusphere-egu26-18498).

## To tip or not to tip
Given a timeseries of a system observable ``x(t)`` and corresponding forcing ``F(t)``
over a time interval ``\tau = [t_0, t_1]``, 
the test applies the proposed tipping definition to determine whether the system tips during ``\tau``.

## Installation

In Julia, add this line to install and load the package:

```julia
using Pkg; Pkg.add("https://github.com/reykboerner/TippingTest.jl.git")
```

## Usage

See the [Example](@ref) and [API](@ref) for an overview of the functionality.

The main method is the [`tipping_test`](@ref) function, which has the syntax

```julia
test = tipping_test(observable, forcing, time, (t1, t2);
    model=LinearNullModel(...), fit=true, ...)
```

and returns a [`TippingTestResult`](@ref) object.

## Citation

> Börner, R. and Dijkstra, H. A.: To tip or not to tip, EGU General Assembly 2026, Vienna, Austria, 3–8 May 2026, EGU26-18498, [https://doi.org/10.5194/egusphere-egu26-18498](https://doi.org/10.5194/egusphere-egu26-18498), 2026

This work is funded by the [ClimTip](https://climate-tipping-points.eu) project.

Package maintainer: Reyk Börner ([r.borner@uu.nl](mailto:r.borner@uu.nl))