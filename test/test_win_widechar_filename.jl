@testset "Images with wide char name" begin
    src16 = rand(RGB{N0f16}, 50, 50)
    save("tmp.png", src16)

    tmp16 = PNGFiles.load("tmp.png")
    mv("tmp.png", "测试rgb16.png", force=true)
    img16 = PNGFiles.load("测试rgb16.png")
    rm("测试rgb16.png")
    
    @test !isempty(img16)
    @test isequal(src16, tmp16)
    @test isequal(src16, img16)
    @test eltype(img16) === ColorTypes.RGB{N0f16}
end
