using ImageMagick
using Images
using Test

onfail(body, x) = error("I might have overlooked something: $x")
onfail(body, _::Test.Pass) = nothing
onfail(body, _::Tuple{Test.Fail,T}) where {T} = body()

absdiff(x, y) = x > y ? x - y : y - x

function imdiff(a, b)
    a_view = channelview(a)
    b_view = channelview(b)
    diffscale = max(maxabsfinite(a_view), maxabsfinite(b_view))
    d = sum(absdiff.(a_view, b_view))
    return d / (length(a) * diffscale)
end

_convert(C, T, xs::AbstractArray) =
    collect(colorview(C, map(i -> collect(reinterpret(T, collect(xs)[:, :, i])), 1:size(xs, 3))...))
_convert(C, T, xs::AbstractMatrix) = collect(colorview(C, collect(reinterpret(T, collect(xs)))))

_standardize_grayness(x) = x
_standardize_grayness(x::AbstractArray{<:Gray{Bool}}) = convert(Array{Gray{N0f8}}, x)
_standardize_grayness(x::AbstractArray{<:RGB}) = all(red.(x) .≈ green.(x) .≈ blue.(x)) ? Gray.(red.(x)) : x
_standardize_grayness(x::AbstractArray{<:RGBA}) = all(red.(x) .≈ green.(x) .≈ blue.(x)) ?
    convert(Array{GrayA}, colorview(GrayA, red.(x), alpha.(x))) :
    x

function _plotdiffs(p, i)
    border = fill(Gray(0), 2, size(p, 2))
    vcat(border,
         Gray.(absdiff.(red.(i), red.(p))),
         border,
         Gray.(absdiff.(green.(i), green.(p))),
         border,
         Gray.(absdiff.(blue.(i), blue.(p))))
end

function _plotdiffs(p::AbstractArray{<:GrayA}, i::AbstractArray{<:GrayA})
    border = fill(Gray(0), 2, size(p, 2))
    vcat(border,
         Gray.(absdiff.(gray.(i), gray.(p))),
         border,
         Gray.(absdiff.(alpha.(i), alpha.(p))))
end

function _plotdiffs(p::AbstractArray{<:Gray}, i::AbstractArray{<:Gray})
    vcat(fill(Gray(0), 2, size(p, 2)), Gray.(absdiff.(gray.(i), gray.(p))))
end

function _plotdiffs(p::AbstractArray{<:RGBA}, i::AbstractArray{<:RGBA})
    border = fill(Gray(0), 2, size(p, 2))
    vcat(border,
         Gray.(absdiff.(red.(i), red.(p))),
         border,
         Gray.(absdiff.(green.(i), green.(p))),
         border,
         Gray.(absdiff.(blue.(i), blue.(p))),
         border,
         Gray.(absdiff.(alpha.(i), alpha.(p))))
end

function plotdiffs(p, i)
    """
    Returns a Matrix of Colorants with following structure:

    |----------------------|-------------------|
    |image p               | image i           |
    |----------------------|-------------------|
    |scaled diff channel 1 | absdiff channel 1 |
    |----------------------|-------------------|
    |scaled diff channel 2 | absdiff channel 2 |
    |----------------------|-------------------|
    ...
    """
    o = _plotdiffs(p, i)
    m = maximum(o)
    border = fill(Gray(0), size(o, 1) + size(p, 1), 2)
    collect(hcat(vcat(p, Gray.(o ./ (m == 0 ? 1.0 : m))), border, vcat(i, o)))
end
