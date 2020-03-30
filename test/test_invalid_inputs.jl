invalid_imgs = [
    ("too_few_dimensions", MethodError, rand(127)),
    ("too_many_channels", AssertionError, rand(127, 257, 5)),
    ("too_many_dimensions", MethodError, rand(127, 257, 3, 1)),
]

@testset "invalid inputs" begin
for (case, exception, image) in invalid_imgs
        @testset "$(case) throws" begin
            @test_throws exception PNGFiles.save(
                joinpath(PNG_TEST_PATH, "test_img_err_$(case).png"),
                image
            )
        end
    end
end


invalid_paletted_imgs = [
    ("palette_index_eltype_too_wide", Exception, rand(UInt16.(0:3), 127, 257), rand(RGB{N0f8}, 4)),
    ("palette_index_too_few_dimensions", Exception, rand(UInt16.(0:3), 127), rand(RGB{N0f8}, 4)),
    ("palette_index_out_of_bounds", Exception, collect(reshape(UInt8.(0:5), 2, 3)), rand(RGB{N0f8}, 3)),
    ("palette_index_many_few_dimensions", Exception, rand(UInt16.(0:3), 127, 257, 3), rand(RGB{N0f8}, 4)),
    ("palette_too_large", Exception, rand(UInt8, 127, 257), rand(RGB{N0f8}, 257)),
    ("palette_eltype_too_wide", Exception, rand(UInt8.(0:3), 127, 257), rand(RGB{N0f16}, 4)),
    ("palette_eltype_float", Exception, rand(UInt16.(0:3), 127, 257), rand(RGB, 4)),
    ("palette_non_RGB_colorant", Exception, rand(UInt8.(0:3), 127, 257), rand(Gray{N0f8}, 3)),
]

@testset "invalid peletted inputs" begin
for (case, exception, image, palette) in invalid_paletted_imgs
        @testset "$(case) throws" begin
            @test_throws exception PNGFiles.save(
                joinpath(PNG_TEST_PATH, "test_img_err_$(case).png"),
                image,
                palette=palette
            )
        end
    end
end
