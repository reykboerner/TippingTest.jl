using Literate

const EXAMPLES_IN = joinpath(@__DIR__, "..", "examples")
const OUTPUT_DIR = joinpath(@__DIR__, "src", "examples")
const RUNNER = joinpath(@__DIR__, "build_md_example.jl")

get!(ENV, "GKSwstype", "100")

examples = filter(f -> endswith(f, ".jl"), readdir(EXAMPLES_IN; join=true))

mkpath(OUTPUT_DIR)

# Clean up previously generated files
for file in readdir(OUTPUT_DIR)
    rm(joinpath(OUTPUT_DIR, file); recursive=true, force=true)
end

# Generate documentation in separate Julia processes
for example in examples
    run(`$(Base.julia_cmd()) --startup-file=no --project=$(abspath(@__DIR__)) --threads=1 $(RUNNER) $(example) $(OUTPUT_DIR)`)
end