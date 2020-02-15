using PNG
using FileIO: DataFormat, @format_str, Stream, File, filename, stream
using Test
using FixedPointNumbers
using ImageCore
using Logging
using Random

#logger = ConsoleLogger(stdout, Logging.Debug)
logger = ConsoleLogger(stdout, Logging.Info)
global_logger(logger)

tmpdir = joinpath(@__DIR__,"temp")
@testset "PNG" begin
    isdir(tmpdir) && rm(tmpdir, recursive = true)
    mkdir(tmpdir)

    img = rand(Bool, 5, 5, 5, 5)
    filepath = joinpath(tmpdir, "5x5x5x5.png")
    @test_throws ErrorException PNG.save(File{DataFormat{:PNG}}(filepath), img)

    @testset "Binary Image" begin
        a = rand(Bool, 11, 10)
        filepath = joinpath(tmpdir, "binary1.png")
        PNG.save(File{DataFormat{:PNG}}(filepath), a)
        b1 = PNG.load(File{DataFormat{:PNG}}(filepath))
        @test b1 == convert(Array{Gray{N0f8}}, a)

        a = bitrand(5,5)
        filepath = joinpath(tmpdir, "binary2.png")
        PNG.save(File{DataFormat{:PNG}}(filepath), a)
        b2 = PNG.load(File{DataFormat{:PNG}}(filepath))
        @test b2 == convert(Array{Gray{N0f8}}, a)

        a = colorview(Gray, a)
        filepath = joinpath(tmpdir, "binary3.png")
        PNG.save(File{DataFormat{:PNG}}(filepath), a)
        b3 = PNG.load(File{DataFormat{:PNG}}(filepath))
        @test b3 == convert(Array{Gray{N0f8}}, a)
    end

    @testset "Gray image" begin
        gray = vcat(fill(Gray(1.0), 10, 10), fill(Gray(0.5), 10, 10), fill(Gray(0.0), 10, 10))
        filepath = joinpath(tmpdir, "gray1.png")
        PNG.save(File{DataFormat{:PNG}}(filepath), gray)
        g1 = PNG.load(File{DataFormat{:PNG}}(filepath))
        @test g1 == convert(Array{Gray{N0f8}}, gray)

        gray = rand(Gray{N0f8}, 5, 5)
        filepath = joinpath(tmpdir, "gray2.png")
        PNG.save(File{DataFormat{:PNG}}(filepath), gray)
        g2 = PNG.load(File{DataFormat{:PNG}}(filepath))
        @test g2 == gray
    end

    @testset "Color - RGB" begin
        #rgb8 = rand(RGB{N0f8}, 10, 5)
        rgb8 = reshape(range(RGB{N0f8}(1,0,0),RGB{N0f8}(0,1,1), length=10*5), 10, 5)
        filepath = joinpath(tmpdir, "rgb_n0f8.png")
        PNG.save(File{DataFormat{:PNG}}(filepath), rgb8)
        r1 = PNG.load(File{DataFormat{:PNG}}(filepath))
        @test r1 == rgb8

        #rgb16 = rand(RGB{N0f16}, 10, 5)
        rgb16 = reshape(range(RGB{N0f16}(1,0,0),RGB{N0f16}(0,1,1), length=10*5), 10, 5)
        filepath = joinpath(tmpdir, "rgb_n0f16.png")
        PNG.save(File{DataFormat{:PNG}}(filepath), rgb16)
        r2 = PNG.load(File{DataFormat{:PNG}}(filepath))
        PNG.save(File{DataFormat{:PNG}}(joinpath(tmpdir, "rgb_n0f16_resave.png")), r2)
        @test r2 == rgb16
    end

    @testset "Alpha" begin
        # RGBA
        r = RGBA(1.0,0.0,0.0, 0.2)
        g = RGBA(0.0,1.0,0.0, 0.8)
        b = RGBA(0.0,0.0,1.0, 1.0)
        rgba1 = vcat(fill(r, 50,100), fill(g, 50,100), fill(b, 50,100))
        filepath = joinpath(tmpdir, "rgba1.png")
        PNG.save(File{DataFormat{:PNG}}(filepath), rgba1)
        r1 = PNG.load(File{DataFormat{:PNG}}(filepath))
        @test r1 == rgba1

        # GrayA
        r = GrayA(1.0, 0.25)
        g = GrayA(0.5, 0.5)
        b = GrayA(0.0, 0.75)
        graya = vcat(fill(r, 50,100), fill(g, 50,100), fill(b, 50,100))
        filepath = joinpath(tmpdir, "graya1.png")
        PNG.save(File{DataFormat{:PNG}}(filepath), graya)
        g1 = PNG.load(File{DataFormat{:PNG}}(filepath))
        @test g1 == convert(Array{GrayA{N0f8}}, graya)
    end
    # TODO implement palette
end
