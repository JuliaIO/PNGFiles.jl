module PNG
# Started as a fork of https://github.com/FugroRoames/LibPNG.jl

using libpng_jll
using ColorTypes
using ImageCore
using FixedPointNumbers

libpng_wrap_dir = joinpath(@__DIR__, "..", "gen", "libpng")
using CEnum
include(joinpath(libpng_wrap_dir, "ctypes.jl"))
export Ctm, Ctime_t, Cclock_t
include(joinpath(libpng_wrap_dir, "libpng_common.jl"))
include(joinpath(libpng_wrap_dir, "libpng_api.jl"))

include("wraphelpers.jl")
include("io.jl")

end # module
