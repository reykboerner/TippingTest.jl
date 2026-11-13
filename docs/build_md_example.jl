using Literate

input, output = abspath.(ARGS)
ENV["EXAMPLE_DIR"] = dirname(input)
repo_root = normpath(joinpath(@__DIR__, ".."))

preprocess(content) = replace(content, r"^#note # (.*)$"m => s"""
    # !!! note
    #     \1""")

Literate.markdown(
    input,
    output;
    flavor = Literate.DocumenterFlavor(),
    credit = false,
    execute = true,
    preprocess,
    config = isempty(get(ENV, "CI", "")) ?
        Dict("repo_root_path" => repo_root, "repo_root_url" => "file://" * repo_root) :
        Dict(),
)