# PNGFiles.jl

FileIO.jl integration for PNG files

[![Build Status](https://travis-ci.com/JuliaIO/PNGFiles.jl.svg?branch=master)](https://travis-ci.com/JuliaIO/PNGFiles.jl)
[![Codecov](https://codecov.io/gh/JuliaIO/PNGFiles.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaIO/PNGFiles.jl)

## Installation

Installation is recommended via the `ImageIO` thin IO wrapper for `FileIO`:

```jl
pkg> add ImageIO  # Press ']' to enter te Pkg REPL mode.
```

## Usage

Once `ImageIO` is installed, usage is as simple as:

```jl
using FileIO
save("img.png", rand(Gray, 100, 100))
load("img.png")
```

Or direct usage, if `PNGFiles` has been directly installed:
```jl
using PNGFiles
PNGFiles.save("img.png", rand(Gray, 100, 100))
PNGFiles.load("img.png")
```
