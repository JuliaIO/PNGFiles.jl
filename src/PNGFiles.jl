module PNGFiles
# Started as a fork of https://github.com/FugroRoames/LibPNG.jl

using ImageCore
using IndirectArrays
using OffsetArrays
using libpng_jll

libpng_wrap_dir = joinpath(@__DIR__, "..", "gen", "libpng")
using CEnum
include(joinpath(libpng_wrap_dir, "ctypes.jl"))
include(joinpath(libpng_wrap_dir, "libpng_common.jl"))
include(joinpath(libpng_wrap_dir, "libpng_api.jl"))

const readcallback_c = Ref{Ptr{Cvoid}}(C_NULL)
const writecallback_c = Ref{Ptr{Cvoid}}(C_NULL)

include("wraphelpers.jl")
include("utils.jl")
include("io.jl")

function __init__()
    readcallback_c[] = @cfunction(_readcallback, Cvoid, (png_structp, png_bytep, png_size_t));
    writecallback_c[] = @cfunction(_writecallback, Csize_t, (png_structp, png_bytep, png_size_t));
end

end # module
