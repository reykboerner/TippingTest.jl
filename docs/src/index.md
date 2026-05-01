```@meta
CurrentModule = TippingTest
```

# TippingTest.jl

A Julia implementation of the tipping classification test proposed by
[Börner & Dijsktra](https://doi.org/10.5194/egusphere-egu26-18498).

## To tip or not to tip
Given a timeseries of a system observable ``x(t)`` and corresponding forcing ``F(t)``
over a time interval ``\tau = [t_0, t_1]``, 
the test applies the tipping definition by [Börner & Dijsktra](https://doi.org/10.5194/egusphere-egu26-18498)
to determine whether the system tips during ``\tau``.

## Example

Consider **Stommel's ocean box model** ([Stommel, 1961](https://doi.org/10.1111/j.2153-3490.1961.tb00079.x)) of the thermohaline circulation, given in non-dimensional
form as a 2-dimensional system of ODEs:

```math
\begin{align}
    \dot{x} &= -\alpha(x-1) - x(1+\mu(x-y)^2) \nonumber \\
    \dot{y} &= F_a - y(1+\mu(x-y)^2)
\end{align}
```

Here $x$ and $y$ represent the meridional temperature and salinity difference between the southern and northern box, respectively. The freshwater flux ``F_a`` is the main forcing parameter; typical values for the model parameters are
``\alpha=360`` and ``\mu=6.25``.



The relevant observable is the overturning strength ``q = 1 + \mu (x-y)^2``. We are interested in the response to the forcing parameter ``F_a``.

## API

```@autodocs
Modules = [TippingTest]
```

## Reference

> Börner, R. and Dijkstra, H. A.: To tip or not to tip, EGU General Assembly 2026, Vienna, Austria, 3–8 May 2026, EGU26-18498, [https://doi.org/10.5194/egusphere-egu26-18498](https://doi.org/10.5194/egusphere-egu26-18498), 2026

This work is funded by the [ClimTip](https://climate-tipping-points.eu) project.

Package maintainer: Reyk Börner ([r.borner@uu.nl](mailto:r.borner@uu.nl))