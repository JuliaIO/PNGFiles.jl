using Images: maxabsfinite
using ImageCore
using ImageMagick
using Logging
using Test

using Glob
using PNGFiles

const DEBUG_FILE = joinpath(@__DIR__, "_debugfile.jl")

logger = ConsoleLogger(stdout, Logging.Info)
global_logger(logger)


PNG_TEST_PATH = joinpath(@__DIR__, "temp")
isdir(PNG_TEST_PATH) && rm(PNG_TEST_PATH, recursive = true)
mkdir(PNG_TEST_PATH)

include("utils.jl")

open(DEBUG_FILE, "w") do f
    write(f, "include(\"utils.jl\")\n")
end
function _add_debugging_entry(fpath, case, imdiff_val=missing)
    apath = joinpath(@__DIR__, abspath(fpath))
    open(DEBUG_FILE, "a") do f
        write(f, "\n\n")
        write(f, "# $(case) ############################################################\n")
        write(f, "p = _standardize_grayness(load(\"$(apath)\"))\n")
        write(f, "i = _standardize_grayness(ImageMagick.load(\"$(apath)\"))\n")
        write(f, "plotdiffs(p, i)\n")
        write(f, "imdiff(i, p) # $(imdiff_val)\n")
        write(f, "_inspect_png_read(\"$(apath)\")\n")
        write(f, "i .≈ p\n")
    end
end


@testset "PNGFiles" begin
    include("test_invalid_inputs.jl")
    include("test_pngsuite.jl")
    include("test_synthetic_images.jl")
    include("test_testimages.jl")
end

# Cleanup
isdir(PNG_TEST_PATH) && rm(PNG_TEST_PATH, recursive = true)
