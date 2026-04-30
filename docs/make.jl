using TippingTest
using Documenter

DocMeta.setdocmeta!(TippingTest, :DocTestSetup, :(using TippingTest); recursive=true)

makedocs(;
    modules=[TippingTest],
    authors="R. Boerner",
    sitename="TippingTest.jl",
    format=Documenter.HTML(;
        canonical="https://reykboerner.github.io/TippingTest.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/reykboerner/TippingTest.jl",
    devbranch="main",
)
