libname = "libpng"

using Pkg; Pkg.add("libpng_jll")

using libpng_jll
jllroot = dirname(dirname(libpng_jll.libpng_path))

using Clang
const LIB_INCLUDE = joinpath(jllroot, "include") |> normpath
#const HEADERS = filter(x->endswith(x, ".h"), readdir(LIB_INCLUDE))
const HEADERS = ["pngconf.h", "pnglibconf.h", "png.h"]
const LIB_HEADERS = [joinpath(LIB_INCLUDE, header) for header in HEADERS]

#Copy headers for easy reference
refdir = joinpath.(@__DIR__, "ref_headers")
!isdir(refdir) && mkdir(refdir)
refpaths = joinpath.(refdir, basename.(LIB_HEADERS))
cp.(LIB_HEADERS, refpaths, follow_symlinks=true, force=true)

wc = init(; headers = LIB_HEADERS,
            output_file = joinpath(@__DIR__, "$(libname)_api.jl"),
            common_file = joinpath(@__DIR__, "$(libname)_common.jl"),
            clang_includes = vcat(LIB_INCLUDE, CLANG_INCLUDE),
            clang_args = ["-I", joinpath(LIB_INCLUDE, ".."), "-DPNG_FLOATING_POINT_SUPPORTED"],
            header_wrapped = (root, current)->root == current,
            header_library = x->libname,
            clang_diagnostics = true,
            )

run(wc)
rm(joinpath(@__DIR__, "LibTemplate.jl"))

#Manual fixes

# Add to top of *_common.jl

# # Manually added
# const PNGCAPI = nothing
# const PNG_BYTES_TO_CHECK = 8
# const png_FILE_p = Ptr{Cvoid}
