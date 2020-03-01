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

@testset "synthetic images" begin
    for (case, image) in synth_imgs
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
                imdiff_val = imdiff(read_in_pngf, read_in_immag)
                onfail(@test imdiff_val < 0.01) do
                    PNGFiles._inspect_png_read(fpath)
                    _add_debugging_entry(fpath, case, imdiff_val)
                end
            end
            path, ext = splitext(fpath)
            newpath = path * "_new" * ext
            PNGFiles.save(newpath, read_in_pngf)
            @testset "$(case): IO is idempotent" begin
                @test all(read_in_pngf .≈ PNGFiles.load(newpath))
            end
        end
    end

    for (case, func_in, image) in edge_case_imgs
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
                imdiff_val = imdiff(read_in_pngf, read_in_immag)
                onfail(@test imdiff_val < 0.01) do
                    PNGFiles._inspect_png_read(fpath)
                    _add_debugging_entry(fpath, case, imdiff_val)
                end
            end
            path, ext = splitext(fpath)
            newpath = path * "_new" * ext
            PNGFiles.save(newpath, read_in_pngf)
            @testset "$(case): IO is idempotent" begin
                @test imdiff(read_in_pngf, PNGFiles.load(newpath)) < 0.01
            end
        end
    end
end
