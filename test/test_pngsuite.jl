using Tar, Downloads

PNG_SUITE_DIR = "PngSuite"
PNG_SUITE_PATH = joinpath(PNG_TEST_PATH, PNG_SUITE_DIR)
PNG_SUITE_FILE = joinpath(PNG_TEST_PATH, "PngSuite.tgz")

# See https://github.com/JuliaIO/PNGFiles.jl/pull/5 for discussion of these errors
const imdiff_tolerance = Dict(
    "basi2c16.png" => 0.010046128738460332,
    "basi6a08.png" => 0.021200980392156808,
    "basn2c16.png" => 0.010046128738460332,
    "basn6a08.png" => 0.021200980392156808,
    "bgan6a08.png" => 0.021200980392156808,
    "bgwn6a08.png" => 0.021200980392156808,
    "g03n2c08.png" => 0.05052849264705868,
    "g05n2c08.png" => 0.041383272058823424,
    "g07n2c08.png" => 0.09764476102941164,
    "g25n2c08.png" => 0.203565410539216,
    "oi1n2c16.png" => 0.010046128738460332,
    "oi2n2c16.png" => 0.010046128738460332,
    "oi4n2c16.png" => 0.010046128738460332,
    "oi9n2c16.png" => 0.010046128738460332,
    "pp0n2c16.png" => 0.010046128738460332,
    "ps1n2c16.png" => 0.010046128738460332,
    "ps2n2c16.png" => 0.010046128738460332,
    "tp0n2c08.png" => 0.012859987745098002,
    "tp0n3p08.png" => 0.012331495098039179,
)

if !isdir(PNG_SUITE_PATH)
    mkdir(PNG_SUITE_PATH)
    Downloads.download("https://github.com/JuliaIO/PNG.jl/releases/download/PngSuite-2017jul19/PngSuite-2017jul19.tar.gz", PNG_SUITE_FILE)
    Tar.extract(PNG_SUITE_FILE, PNG_SUITE_PATH)
    rm(PNG_SUITE_FILE)
end

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

@testset "PngSuite" begin
    for fpath in glob(joinpath("./**/$(PNG_SUITE_DIR)", "[!x]*[!_new][!_new_im].png"))
        case = last(splitpath(fpath))
        case_info = parse_pngsuite(case)
        C = case_info.color_type
        b = case_info.bit_depth
        is_gray = C in (Gray, GrayA)

        @testset "$(case)" begin
            global read_in_pngf = PNGFiles.load(fpath, gamma = is_gray ? 1.0 : nothing)
            @test typeof(read_in_pngf) <: AbstractMatrix

            path, ext = splitext(fpath)
            newpath = path * "_new" * ext

            open(io->PNGFiles.save(io, read_in_pngf), newpath, "w") #test IO method
            @test PNGFiles.save(newpath, read_in_pngf) == 0
            global read_in_immag = _standardize_grayness(ImageMagick.load(fpath))

            @testset "$(case): PngSuite/ImageMagick read type equality" begin
                if case_info.case in ("tbb", "tbg", "tbr", "tbw")  # transaprency adds an alpha layer
                    if C === RGB
                        C = RGBA
                    elseif C === Gray
                        C = GrayA
                    end
                end
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
                    imdiff_val = imdiff(collect(read_in_pngf), read_in_immag)
                    onfail(@test imdiff_val <= get(imdiff_tolerance, case, 0.01)) do
                        PNGFiles._inspect_png_read(fpath)
                        _add_debugging_entry(fpath, case, imdiff_val)
                    end
                end
            end
            @testset "$(case): IO is idempotent" begin
                @test all(read_in_pngf .≈ PNGFiles.load(newpath))
                @test all(read_in_pngf .≈ open(io->PNGFiles.load(io), newpath))
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
