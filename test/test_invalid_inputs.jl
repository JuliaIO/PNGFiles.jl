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
