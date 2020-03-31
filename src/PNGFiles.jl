module PNGFiles
# Started as a fork of https://github.com/FugroRoames/LibPNG.jl

using libpng_jll
using ImageCore
using IndirectArrays

libpng_wrap_dir = joinpath(@__DIR__, "..", "gen", "libpng")
using CEnum
include(joinpath(libpng_wrap_dir, "ctypes.jl"))
include(joinpath(libpng_wrap_dir, "libpng_common.jl"))
include(joinpath(libpng_wrap_dir, "libpng_api.jl"))

include("wraphelpers.jl")
include("io.jl")
include("utils.jl")

end # module
