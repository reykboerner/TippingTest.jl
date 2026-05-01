# Example

## Box model of the ocean circulation

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

## Generate trajectory data

## Apply tipping test