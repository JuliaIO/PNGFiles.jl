# PNGFiles.jl

(work in progress) FileIO.jl integration for PNG files

[![Build Status](https://travis-ci.com/JuliaIO/PNGFiles.jl.svg?branch=master)](https://travis-ci.com/JuliaIO/PNGFiles.jl)
[![Codecov](https://codecov.io/gh/JuliaIO/PNGFiles.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaIO/PNGFiles.jl)

## Installation

Install with Pkg, just like any other registered Julia package:

```jl
pkg> add PNGFiles  # Press ']' to enter te Pkg REPL mode.
```

## Usage

PNGFiles is not yet integrated into FileIO.
For now, do this:

```jl
using FileIO, PNGFiles
fformat = File{DataFormat{:PNG}}("path/to/img.png")

PNGFiles.save(fformat, rand(Gray, 100, 100))
PNGFiles.load(fformat)
```


In the future, it will be as simple as:

```jl
using FileIO
save("test.png", rand(Gray, 100, 100))
load("test.png")
```
