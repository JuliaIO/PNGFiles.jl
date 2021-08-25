using Clang.Generators
using libpng_jll

cd(@__DIR__)

include_dir = joinpath(libpng_jll.artifact_dir, "include") |> normpath

# wrapper generator options
options = load_options(joinpath(@__DIR__, "generator.toml"))

args = get_default_args()
push!(args, "-I$include_dir", "-DPNG_FLOATING_POINT_SUPPORTED")

header_dir = include_dir
headers = [joinpath(header_dir, "png.h")]

# Skip time_t and jmp_buf
@add_def time_t
@add_def jmp_buf

# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx)