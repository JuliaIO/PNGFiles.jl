
# # Setup (run this once first time)
# using Pkg
# cd(@__DIR__)
# !isdir("ImageMagick") && mkdir("ImageMagick")
# Pkg.activate(joinpath(@__DIR__,"ImageMagick"))
# Pkg.develop(PackageSpec(path="/Users/ian/Documents/GitHub/FileIO.jl"))
# Pkg.add("ImageMagick")
#
# !isdir("QuartzImageIO") && mkdir("QuartzImageIO")
# Pkg.activate(joinpath(@__DIR__,"QuartzImageIO"))
# Pkg.develop(PackageSpec(path="/Users/ian/Documents/GitHub/FileIO.jl"))
# Pkg.add("QuartzImageIO")
#
# !isdir("PNG") && mkdir("PNG")
# Pkg.activate(joinpath(@__DIR__,"PNG"))
# Pkg.develop(PackageSpec(path="/Users/ian/Documents/GitHub/FileIO.jl"))
# Pkg.develop(PackageSpec(path="/Users/ian/Documents/GitHub/PNG.jl"))

corebench = raw"""
using BenchmarkTools, ImageCore
x = rand(Gray{N0f8}, 20000, 4000)
tfirst = @elapsed begin
    using FileIO
    FileIO.save("tst.png", x)
end
println("Time to first save: $tfirst seconds")
b = @benchmark FileIO.save("tst.png", $(x)) teardown=(rm("tst.png"))
print("Save @btime:")
@btime FileIO.save("tst.png", x)
print("Load @btime:")
@btime  FileIO.load("tst.png")
println("")
"""

@info "Testing with 20000x4000 Gray{N0f8} image"

header = """
@info "Testing FileIO with ImageMagick -----------------------------------------------------"
using Pkg; cd(joinpath(@__DIR__,"ImageMagick")); Pkg.activate(".");
"""
run(`julia --color=yes -e $(string(header, corebench))`)

header = """
@info "Testing FileIO with QuartzImageIO ---------------------------------------------------"
using Pkg; cd(joinpath(@__DIR__,"QuartzImageIO")); Pkg.activate(".");
"""
run(`julia --color=yes -e $(string(header, corebench))`)

header = """
@info "Testing FileIO with PNG -------------------------------------------------------------"
using Pkg; cd(joinpath(@__DIR__,"PNG")); Pkg.activate(".");
"""
run(`julia --color=yes -e $(string(header, corebench))`)
