@testset "Images with wide char name" begin
    img16 = PNGFiles.load("test_images/rgb测试16bit.png")

    @test !isempty(img16)
    @test eltype(img16) === ColorTypes.RGB{FixedPointNumbers.N0f16}
end