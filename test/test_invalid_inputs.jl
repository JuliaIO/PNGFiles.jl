invalid_imgs = [
    ("too_few_dimensions", MethodError, rand(127)),
    ("too_many_channels", AssertionError, rand(127, 257, 5)),
    ("too_many_dimensions", MethodError, rand(127, 257, 3, 1)),
    ("palette_too_large", ArgumentError, IndirectArray(rand(1:257, 127, 256), rand(RGB{N0f8}, 257))),
    ("palette_index_too_few_dimensions", MethodError, IndirectArray(rand(1:4, 127), rand(RGB{N0f8}, 4))),
    ("palette_index_too_many_dimensions", ArgumentError, IndirectArray(rand(1:4, 127, 256, 1), rand(RGB{N0f8}, 4))),
    ("palette_eltype_too_wide", ArgumentError, IndirectArray(rand(1:4, 127, 256), rand(RGB{N0f16}, 4))),
    ("palette_non_RGB_colorant", ArgumentError, IndirectArray(rand(1:4, 127, 256), rand(Gray{N0f8}, 4))),
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
