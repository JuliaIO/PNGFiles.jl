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
const png_error_fn_c = Ref{Ptr{Cvoid}}(C_NULL)
const png_warn_fn_c = Ref{Ptr{Cvoid}}(C_NULL)

include("wraphelpers.jl")
include("utils.jl")
include("io.jl")

function __init__()
    readcallback_c[] = @cfunction(_readcallback, Cvoid, (png_structp, png_bytep, png_size_t));
    writecallback_c[] = @cfunction(_writecallback, Csize_t, (png_structp, png_bytep, png_size_t));
    png_error_fn_c[] = @cfunction(png_error_handler, Cvoid, (Ptr{Cvoid}, Cstring))
    png_warn_fn_c[] = @cfunction(png_warn_handler, Cvoid, (Ptr{Cvoid}, Cstring))
end

function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    @assert precompile(load, (String,))
    # save is harder to usefully precompile because of the diversity of array types
end
VERSION >= v"1.4.2" && _precompile_() # https://github.com/JuliaLang/julia/pull/35378

end # module
