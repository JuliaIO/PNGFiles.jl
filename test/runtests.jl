using Images: maxabsfinite
using ImageCore
using ImageMagick
using Logging
using Tar
using Test
using TestImages
using Glob
using PNGFiles

function imdiff(a, b)
    a_view = channelview(a)
    b_view = channelview(b)
    diffscale = max(maxabsfinite(a_view), maxabsfinite(b_view))
    d = sum(abs.(a_view - b_view))
    return d / (length(a) * diffscale)
end

logger = ConsoleLogger(stdout, Logging.Debug)
global_logger(logger)

PNG_TEST_PATH = joinpath(@__DIR__, "temp")
isdir(PNG_TEST_PATH) && rm(PNG_TEST_PATH, recursive = true)
mkdir(PNG_TEST_PATH)

PNG_SUITE_DIR = "PngSuite"
PNG_SUITE_PATH = joinpath(PNG_TEST_PATH, PNG_SUITE_DIR)
PNG_SUITE_FILE = joinpath(PNG_TEST_PATH, "PngSuite.tgz")

if !isdir(PNG_SUITE_PATH)
    mkdir(PNG_SUITE_PATH)
    download("https://github.com/JuliaIO/PNG.jl/releases/download/PngSuite-2017jul19/PngSuite-2017jul19.tar.gz", PNG_SUITE_FILE)
    Tar.extract(PNG_SUITE_FILE, PNG_SUITE_PATH)
    rm(PNG_SUITE_FILE)
end

_convert(C, T, xs::AbstractArray) =
    collect(colorview(C, map(i -> collect(reinterpret(T, collect(xs)[:, :, i])), 1:size(xs, 3))...))
_convert(C, T, xs::AbstractMatrix) = collect(colorview(C, collect(reinterpret(T, collect(xs)))))

_standardize_grayness(x) = x
_standardize_grayness(x::AbstractArray{<:Gray{Bool}}) = convert(Array{Gray{N0f8}}, x)
_standardize_grayness(x::AbstractArray{<:RGB}) = all(red.(x) .≈ green.(x) .≈ blue.(x)) ? Gray.(red.(x)) : x
_standardize_grayness(x::AbstractArray{<:RGBA}) = all(red.(x) .≈ green.(x) .≈ blue.(x)) ?
    convert(Array{GrayA}, colorview(GrayA, red.(x), alpha.(x))) :
    x

struct _Palleted; end
const pngsuite_colormap = Dict("0g" => Gray, "2c" => RGB, "3p" => _Palleted, "4a" => GrayA, "6a" => RGBA)

function parse_pngsuite(x::AbstractString)
    code = splitext(x)[1]
    return (
        case=code[1:end-5],
        is_interlaced=code[end-4]=='i',
        color_type=pngsuite_colormap[code[end-3:end-2]],
        bit_depth=parse(Int, code[end-1:end])
    )
end
parse_pngsuite(x::Symbol) = parse_pngsuite(String(x))

real_imgs = [
    splitext(img_name)[1] => testimage(img_name)
    for img_name
    in TestImages.remotefiles
    if endswith(img_name, ".png")
]

synth_imgs = [
    "Float64_0" => rand(127, 257),
    "Float64_1" => rand(127, 257, 1),
    "Float64_2" => rand(127, 257, 2),
    "Float64_3" => rand(127, 257, 3),
    "Float64_4" => rand(127, 257, 4),
    "Bool_0" => rand(Bool, 127, 257),
    "Bool_1" => rand(Bool, 127, 257, 1),
    "Bool_2" => rand(Bool, 127, 257, 2),
    "Bool_3" => rand(Bool, 127, 257, 3),
    "Bool_4" => rand(Bool, 127, 257, 4),
    "UInt8_0" => rand(UInt8, 127, 257),
    "UInt8_1" => rand(UInt8, 127, 257, 1),
    "UInt8_2" => rand(UInt8, 127, 257, 2),
    "UInt8_3" => rand(UInt8, 127, 257, 3),
    "UInt8_4" => rand(UInt8, 127, 257, 4),
    "UInt16_0" => rand(UInt16, 127, 257),
    "UInt16_1" => rand(UInt16, 127, 257, 1),
    "UInt16_2" => rand(UInt16, 127, 257, 2),
    "UInt16_3" => rand(UInt16, 127, 257, 3),
    "UInt16_4" => rand(UInt16, 127, 257, 4),
    "N0f8_0" => rand(N0f8, 127, 257),
    "N0f8_1" => rand(N0f8, 127, 257, 1),
    "N0f8_2" => rand(N0f8, 127, 257, 2),
    "N0f8_3" => rand(N0f8, 127, 257, 3),
    "N0f8_4" => rand(N0f8, 127, 257, 4),
    "N0f16_0" => rand(N0f16, 127, 257),
    "N0f16_1" => rand(N0f16, 127, 257, 1),
    "N0f16_2" => rand(N0f16, 127, 257, 2),
    "N0f16_3" => rand(N0f16, 127, 257, 3),
    "N0f16_4" => rand(N0f16, 127, 257, 4),
    "Gray" => rand(Gray, 127, 257),
    "GrayA" => rand(GrayA, 127, 257),
    "RGB" => rand(RGB, 127, 257),
    "RGBA" => rand(RGBA, 127, 257),
    "GrayN0f8" => rand(Gray{N0f8}, 127, 257),
    "GrayAN0f8" => rand(GrayA{N0f8}, 127, 257),
    "RGBN0f8" => rand(RGB{N0f8}, 127, 257),
    "RGBAN0f8" => rand(RGBA{N0f8}, 127, 257),
    "GrayN0f16" => rand(Gray{N0f16}, 127, 257),
    "GrayAN0f16" => rand(GrayA{N0f16}, 127, 257),
    "RGBN0f16" => rand(RGB{N0f16}, 127, 257),
    "RGBAN0f16" => rand(RGBA{N0f16}, 127, 257),
]

invalid_imgs = [
    ("too_few_dimensions", MethodError, rand(127)),
    ("too_many_channels", AssertionError, rand(127, 257, 5)),
    ("too_many_dimensions", MethodError, rand(127, 257, 3, 1)),
]

edge_case_imgs = [
    ("BitArray_0", x->_convert(Gray, N7f1, x), randn(127, 257) .> 0),
    ("BitArray_1", x->_convert(Gray, N7f1, x), randn(127, 257, 1) .> 0),
    ("BitArray_2", x->_convert(GrayA, N7f1, x), randn(127, 257, 2) .> 0),
    ("BitArray_3", x->_convert(RGB, N7f1, x), randn(127, 257, 3) .> 0),
    ("BitArray_4", x->_convert(RGBA, N7f1, x), randn(127, 257, 4) .> 0),
    ("N4f12_0", x->_convert(Gray, N0f16, x), rand(N4f12,127, 257)),
    ("N4f12_1", x->_convert(Gray, N0f16, x), rand(N4f12,127, 257, 1)),
    ("N4f12_2", x->_convert(GrayA, N0f16, x), rand(N4f12,127, 257, 2)),
    ("N4f12_3", x->_convert(RGB, N0f16, x), rand(N4f12,127, 257, 3)),
    ("N4f12_4", x->_convert(RGBA, N0f16, x), rand(N4f12,127, 257, 4)),
    ("BGRN0f8", identity, rand(BGR{N0f8}, 127, 257)),
    ("BGRAN0f8", identity, rand(BGRA{N0f8}, 127, 257)),
    ("BGRN0f16", identity, rand(BGR{N0f16}, 127, 257)),
    ("BGRAN0f16", identity, rand(BGRA{N0f16}, 127, 257)),
    ("ABGRN0f8", identity, rand(ABGR{N0f8}, 127, 257)),
    ("ABGRN0f16", identity, rand(ABGR{N0f16}, 127, 257)),
    ("ARGBN0f8", identity, rand(ARGB{N0f8}, 127, 257)),
    ("ARGBN0f16", identity, rand(ARGB{N0f16}, 127, 257)),
]

@testset "PNGFiles" begin
    for (case, image) in vcat(synth_imgs, real_imgs)
        @info case
        @testset "$(case)" begin
            expected = collect(PNGFiles._prepare_buffer(image))
            fpath = joinpath(PNG_TEST_PATH, "test_img_$(case).png")
            @testset "write" begin
                @test PNGFiles.save(fpath, image) == 0
            end
            @testset "read" begin
                global read_in_pngf = PNGFiles.load(fpath)
                @test read_in_pngf isa Matrix
            end
            @testset "compare" begin
                @test all(expected .≈ read_in_pngf)
            end
            global read_in_immag = _standardize_grayness(ImageMagick.load(fpath))
            @testset "$(case): ImageMagick read type equality" begin
                # The lena image is Grayscale saved as RGB...
                @test eltype(_standardize_grayness(read_in_pngf)) == eltype(read_in_immag)
            end
            @testset "$(case): ImageMagick read values equality" begin
                # The lena image is Grayscale saved as RGB...
                @test all(_standardize_grayness(read_in_pngf) .≈ read_in_immag)
            end
            path, ext = splitext(fpath)
            newpath = path * "_new" * ext
            PNGFiles.save(newpath, read_in_pngf)
            @testset "$(case): IO is idempotent" begin
                @test all(read_in_pngf .≈ PNGFiles.load(newpath))
            end
        end
    end

    for (case, exception, image) in invalid_imgs
        @info case
        @testset "$(case) throws" begin
            @test_throws exception PNGFiles.save(
                joinpath(PNG_TEST_PATH, "test_img_err_$(case).png"),
                image
            )
        end
    end

    for (case, func_in, image) in edge_case_imgs
        @info case
        @testset "$(case)" begin
            fpath = joinpath(PNG_TEST_PATH, "test_img_$(case).png")
            @testset "write" begin
                @test PNGFiles.save(fpath, image) == 0
            end
            @testset "read" begin
                global read_in_pngf = PNGFiles.load(fpath)
                @test read_in_pngf isa Matrix
            end
            @testset "compare" begin
                @test all(read_in_pngf .== func_in(image))
            end
            global read_in_immag = _standardize_grayness(ImageMagick.load(fpath))
            @testset "$(case): ImageMagick read type equality" begin
                @test eltype(read_in_pngf) == eltype(read_in_immag)
            end
            @testset "$(case): ImageMagick read values equality" begin
                @test all(read_in_pngf .≈ read_in_immag)
            end
            path, ext = splitext(fpath)
            newpath = path * "_new" * ext
            PNGFiles.save(newpath, read_in_pngf)
            @testset "$(case): IO is idempotent" begin
                @test imdiff(read_in_pngf, PNGFiles.load(newpath)) < 0.01
            end
        end
    end

    @testset "PngSuite" begin
        for fpath in glob(joinpath("./**/$(PNG_SUITE_DIR)", "[!x]*[!_new].png"))
            case = splitpath(fpath)[end]
            case_info = parse_pngsuite(case)
            @info case case_info

            C = case_info.color_type
            ignore_gamma = (C == Gray) # It seems Imagemagick doesn't apply gamma correction to gray
            b = case_info.bit_depth
            @testset "$(case)" begin
                global read_in_pngf = PNGFiles.load(fpath, ignore_gamma = ignore_gamma)
                @test read_in_pngf isa Matrix

                path, ext = splitext(fpath)
                newpath = path * "_new" * ext
                @test PNGFiles.save(newpath, read_in_pngf) == 0
                global read_in_immag = _standardize_grayness(ImageMagick.load(fpath))

                @testset "$(case): PngSuite/ImageMagick read type equality" begin
                    if C === _Palleted
                        # _Palleted images could have an alpha channel, but its not evident from "case"
                        @test eltype(read_in_pngf) == eltype(read_in_immag)
                    else
                        basictype = b > 8 ? Normed{UInt16,16} : Normed{UInt8,8}
                        @test eltype(read_in_pngf) == C{basictype}
                    end
                end
                if b >= 8 # ImageMagick.jl does not read in sub 8 bit images correctly
                    @testset "$(case): ImageMagick read values equality" begin
                        @test imdiff(read_in_pngf, read_in_immag) < 0.01
                    end
                end
                @testset "$(case): IO is idempotent" begin
                    @test all(read_in_pngf .≈ PNGFiles.load(newpath))
                end
            end
        end

        ## TODO: Malformed pngs that should error. This throws `signal (6): Aborted` since we
        ## don't work with `png_jmpbuf` properly.
        # for fpath in glob(joinpath("./**/$(PNG_SUITE_DIR)", "[x]*.png"))
        #     case = splitpath(fpath)[end]
        #     @info case
        #     @testset "$(case)" begin
        #         @test_throws ErrorException PNGFiles.load(fpath)
        #     end
        # end
    end
end

# Cleanup
isdir(PNG_TEST_PATH) && rm(PNG_TEST_PATH, recursive = true)
