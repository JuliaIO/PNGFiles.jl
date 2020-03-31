synth_paletted_imgs = [
    ("RGB_paletted", IndirectArray(rand(1:100, 127, 257), rand(RGB{N0f8}, 100))),
    ("BRG_paletted", IndirectArray(rand(1:100, 127, 257), rand(BGR{N0f8}, 100))),
    ("ARGB_paletted", IndirectArray(rand(1:100, 127, 257), rand(ARGB{N0f8}, 100))),
    ("ABGR_paletted", IndirectArray(rand(1:100, 127, 257), rand(ABGR{N0f8}, 100))),
    ("RGBA_paletted", IndirectArray(rand(1:100, 127, 257), rand(RGBA{N0f8}, 100))),
    ("RGB_paletted_float", IndirectArray(rand(1:100, 127, 257), rand(RGB{Float64}, 100))),
    ("BRG_paletted_float", IndirectArray(rand(1:100, 127, 257), rand(BGR{Float64}, 100))),
    ("ARGB_paletted_float", IndirectArray(rand(1:100, 127, 257), rand(ARGB{Float64}, 100))),
    ("ABGR_paletted_float", IndirectArray(rand(1:100, 127, 257), rand(ABGR{Float64}, 100))),
    ("RGBA_paletted_float", IndirectArray(rand(1:100, 127, 257), rand(RGBA{Float64}, 100))),
]

expected_img(x::Matrix{<:TransparentColor}) = convert(Array{RGBA{N0f8}}, x)
expected_img(x::Matrix{<:AbstractRGB}) = convert(Array{RGB{N0f8}}, x)

@testset "synthetic paletted images" begin
    for (case, image) in synth_paletted_imgs
        @testset "$(case)" begin
            expected = expected_img(collect(image))
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
end
