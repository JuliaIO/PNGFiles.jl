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

Use FileIO to save and load PNGs images via this package

```jl
using FileIO
save("test.png", rand(Gray, 100, 100))
load("test.png")
```
