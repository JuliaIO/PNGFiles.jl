@testset "Non-ASCII paths" begin
    mktempdir() do temp_root
        unicode_dir = joinpath(temp_root, "áéüñ")
        mkpath(unicode_dir)

        image = rand(Gray{N0f8}, 4, 4)
        file_path = joinpath(unicode_dir, "test.png")

        PNGFiles.save(file_path, image)
        @test PNGFiles.load(file_path) == image
    end
end