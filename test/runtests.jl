using TippingTest
using Test

@testset "TippingTest.jl" begin
    @testset "Model definition" begin
        model = RelaxNullModel(0.0, [1.0, 1.0])
        @test typeof(model) <: LinearNullModel
        @test model.y0 == 0.0
        @test model.params[1] == 1.0
    end

    @testset "Proportional system" begin
        obs = range(1.0, 2.0, length=20)
        forcing = range(0.0, 10.0, length=20)
        guess = [0.3, 0.1]
        fit, params = fit_nullmodel(obs, forcing, guess; t_tr=(7,14))
        println(params)
        @test isapprox(params[1], 0.1; atol=1e-3)
        @test isapprox(params[2], 0.0; atol=1e-2)

        test = tipping_test(obs, forcing, 0.0:1.0:19.0, (7, 14))
        @test typeof(test.nullmodel) <: LinearNullModel
        println(test.residual)
        @test maximum(abs.(test.residual)) < 1e-3
    end
end
