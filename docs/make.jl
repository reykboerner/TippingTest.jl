using TippingTest
using Documenter

DocMeta.setdocmeta!(TippingTest, :DocTestSetup, :(using TippingTest); recursive=true)

include("make_md_examples.jl")
include("pages.jl")

makedocs(;
    modules=[TippingTest],
    authors="R. Boerner",
    sitename="TippingTest.jl",
    format=Documenter.HTML(;
        canonical="https://reykboerner.github.io/TippingTest.jl",
        edit_link="main",
        assets=String[],
        size_threshold=800*1024,
    ),
    pages,
    pagesonly = true,
)

deploydocs(;
    repo="github.com/reykboerner/TippingTest.jl",
    devbranch="main",
)
