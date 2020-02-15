# PNG.jl

FileIO.jl integration for PNG files

[![Build Status](https://travis-ci.com/JuliaIO/PNG.jl.svg?branch=master)](https://travis-ci.com/JuliaIO/PNG.jl)
[![Codecov](https://codecov.io/gh/JuliaIO/PNG.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaIO/PNG.jl)


## Installation

Install with Pkg, just like any other registered Julia package:

```jl
pkg> add PNG  # Press ']' to enter te Pkg REPL mode.
```

## Usage

Use FileIO to save and load PNGs via this package

```jl
using FileIO
save("test.png", rand(Gray, 100, 100))
load("test.png")
```
