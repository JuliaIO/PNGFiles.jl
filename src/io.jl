"""
    load(f::File{DataFormat{:PNG}})

Read a `.png` image from file `f`.
Returns a matrix.

The result will be an 8 bit (N0f8) image if the source bit depth is <= 8 bits, 16 bit (N0f16)
otherwise. The number of channels of the source determines the color type of the output:
    1 channel  -> Gray
    2 channels -> GrayA
    3 channels -> RGB
    4 channels -> RGBA
"""
function load(f::File{DataFormat{:PNG}})
    fp = open_png(f.filename)
    png_ptr = create_read_struct()
    info_ptr = create_info_struct(png_ptr)
    png_init_io(png_ptr, fp)
    png_set_sig_bytes(png_ptr, PNG_BYTES_TO_CHECK)
    png_read_info(png_ptr, info_ptr)

    width = png_get_image_width(png_ptr, info_ptr)
    height = png_get_image_height(png_ptr, info_ptr)
    color_type = png_get_color_type(png_ptr, info_ptr)
    bit_depth = png_get_bit_depth(png_ptr, info_ptr)
    num_channels = png_get_channels(png_ptr, info_ptr)
    interlace_type = png_get_interlace_type(png_ptr, info_ptr)
    buffer_eltype = _buffer_color_type(color_type, bit_depth)

    @debug(
        "Read PNG info:",
        f.filename,
        height,
        width,
        color_type,
        bit_depth,
        num_channels,
        interlace_type,
        buffer_eltype
    )

    if (color_type == PNG_COLOR_TYPE_PALETTE)
        png_set_palette_to_rgb(png_ptr)
    end

    if (color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8)
        png_set_expand_gray_1_2_4_to_8(png_ptr)
        png_set_packing(png_ptr)
        bit_depth = UInt8(8)
    end

    if (png_get_valid(png_ptr, info_ptr, PNG_INFO_tRNS) != 0)
        png_set_tRNS_to_alpha(png_ptr)
    end
    isodd(num_channels) && png_set_strip_alpha(png_ptr)

    bit_depth == 16 && png_set_swap(png_ptr)
    png_set_interlace_handling(png_ptr)
    png_read_update_info(png_ptr, info_ptr)
    # We transpose to work around libpng expecting row-major arrays
    buffer = Array{buffer_eltype}(undef, width, height)

    png_read_image(png_ptr, map(pointer, eachcol(buffer)))
    png_read_end(png_ptr, info_ptr)
    png_destroy_read_struct(Ref{Ptr{Cvoid}}(png_ptr), Ref{Ptr{Cvoid}}(info_ptr), C_NULL)
    close_png(fp)
    return transpose(buffer)
end

function _buffer_color_type(color_type, bit_depth)
    if color_type == PNG_COLOR_TYPE_GRAY
        colors_type = Gray{bit_depth > 8 ? Normed{UInt16,bit_depth} : Normed{UInt8,bit_depth}}
    elseif color_type == PNG_COLOR_TYPE_PALETTE
        colors_type = RGB{bit_depth == 16 ? N0f16 : N0f8}
    elseif color_type == PNG_COLOR_TYPE_RGB
        colors_type = RGB{bit_depth == 16 ? N0f16 : N0f8}
    elseif color_type == PNG_COLOR_TYPE_RGB_ALPHA
        colors_type = RGBA{bit_depth == 16 ? N0f16 : N0f8}
    elseif color_type == PNG_COLOR_TYPE_GRAY_ALPHA
        colors_type = GrayA{bit_depth > 8 ? Normed{UInt16,bit_depth} : Normed{UInt8,bit_depth}}
    else
        throw(error("Unknown color type: $color_type"))
    end
    return colors_type
end


### Write ##########################################################################################
"""
    save(f::File{DataFormat{:PNG}}, image::AbstractArray
        [, compression_level::Integer=0, compression_strategy::Integer=3, filters::Integer=4,])

Writes `image` as a png to file `f`.

## Arguments
`compression_level`: 0 (Z_NO_COMPRESSION), 1 (Z_BEST_SPEED), ..., 9 (Z_BEST_COMPRESSION)
`compression_strategy`: 0 (Z_DEFAULT_STRATEGY), 1 (Z_FILTERED), 2 (Z_HUFFMAN_ONLY), 3 (Z_RLE), 4 (Z_FIXED)
`filters`: 0 (None), 1 (Sub), 2 (Up), 3 (Average), 4 (Paeth).

The saved image will have 16 bits of depth if the `image` has eltype that is based on `UInt16`,
8 bits otherwise.
The number of channels and element type of the `image` determines the color type of the
output:
    0/1 channel Float / Integer / Normed or Gray eltype        -> PNG_COLOR_TYPE_GRAY
    2 channels Float  / Integer / Normed or GrayA eltype       -> PNG_COLOR_TYPE_GRAY_ALPHA
    3 channels Float  / Integer / Normed or RGB / BGR eltype   -> PNG_COLOR_TYPE_RGB
    4 channels Float  / Integer / Normed or ARGB / ABGR eltype -> PNG_COLOR_TYPE_RGB_ALPHA
"""
function save(
        f::File{DataFormat{:PNG}},
        image::S,
        compression_level::Integer=Z_NO_COMPRESSION,
        compression_strategy::Integer=Z_RLE,
        filters::Integer=PNG_FILTER_PAETH
    ) where {
        T,
        S<:Union{AbstractMatrix,AbstractArray{T,3}}
    }
    @assert Z_DEFAULT_STRATEGY <= compression_strategy <= Z_FIXED
    @assert Z_NO_COMPRESSION <= compression_level <= Z_BEST_COMPRESSION
    @assert 2 <= ndims(image) <= 3
    @assert size(image, 3) <= 4

    fp = ccall(:fopen, Ptr{Cvoid}, (Cstring, Cstring), f.filename, "wb")
    fp == C_NULL && error("Could not open $(f.filename) for writing")

    png_ptr = create_write_struct(png_error_fn, png_warn_fn)
    info_ptr = create_info_struct(png_ptr)
    png_init_io(png_ptr, fp)
    png_set_filter(png_ptr, PNG_FILTER_TYPE_BASE, UInt32(filters))
    png_set_compression_level(png_ptr, compression_level)
    png_set_compression_strategy(png_ptr, compression_strategy)

    height, width = size(image)[1:2]
    bit_depth = _get_bit_depth(image)
    color_type = _get_color_type(image)
    interlace = PNG_INTERLACE_NONE
    compression_type = PNG_COMPRESSION_TYPE_BASE
    filter_type = PNG_FILTER_TYPE_BASE

    elt = eltype(image)
    if (elt <: BGR || elt <: BGRA || elt <: ABGR)
       png_set_bgr(png_ptr)
    end

    if (elt <: ABGR || elt <: ARGB)
        png_set_swap_alpha(png_ptr)
    end

    if color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8
        png_set_packing(png_ptr)
        bit_depth = 8  # TODO: support 1, 2, 4 bit-depth gray images
    end

    @debug(
        "Write PNG info:",
        f.filename,
        height,
        width,
        bit_depth,
        color_type,
        interlace,
        compression_type,
        filter_type,
        filters,
        compression_level,
        compression_strategy,
        typeof(image)
    )

    # TODO: on error this throws an abort signal because we currently don't handle `longjmp`
    png_set_IHDR(
        png_ptr,
        info_ptr,
        width,
        height,
        bit_depth,
        color_type,
        interlace,
        compression_type,
        filter_type,
    )
    png_write_info(png_ptr, info_ptr)
    bit_depth == 16 && png_set_swap(png_ptr) # Handles endianness for 16 bit

    # We transpose to work around libpng expecting row-major arrays
    _write_image(transpose(_prepare_buffer(image)), png_ptr, info_ptr)

    png_destroy_write_struct(Ref(png_ptr), Ref(info_ptr))
    close_png(fp)
end

function _write_image(buf::AbstractArray{T,2}, png_ptr::Ptr{Cvoid}, info_ptr::Ptr{Cvoid}) where {T}
    ccall(
        (:png_write_image, libpng),
        Cvoid,
        (Ptr{Cvoid}, Ptr{Ptr{T}}),
        png_ptr,
        map(pointer, eachcol(buf)),
    )
    png_write_end(png_ptr, info_ptr)
end

_prepare_buffer(x::BitArray) where {T<:Colorant{<:Normed}} = _prepare_buffer(collect(x))
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:Colorant{<:Normed}} = x
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:UInt8} = reinterpret(Gray{N0f8}, x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:UInt16} = reinterpret(Gray{N0f16}, x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:Normed} = reinterpret(Gray{T}, x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:Gray{<:AbstractFloat}} =
    convert(Array{Gray{N0f8}}, x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:GrayA{<:AbstractFloat}} =
    convert(Array{GrayA{N0f8}}, x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:RGB{<:AbstractFloat}} =
    convert(Array{RGB{N0f8}}, x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:RGBA{<:AbstractFloat}} =
    convert(Array{RGBA{N0f8}}, x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:BGR{<:AbstractFloat}} =
    convert(Array{RGB{N0f8}}, x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:BGRA{<:AbstractFloat}} =
    convert(Array{RGBA{N0f8}}, x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:ARGB{<:AbstractFloat}} =
    convert(Array{RGBA{N0f8}}, x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:ABGR{<:AbstractFloat}} =
    convert(Array{RGBA{N0f8}}, x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:Union{AbstractFloat,Bool}} =
    reinterpret(Gray{N0f8}, convert(Array{N0f8}, x))
_prepare_buffer(x::AbstractArray{T,3}) where {T<:Union{AbstractFloat,Bool}} =
    __prepare_buffer(convert(Array{N0f8}, x))
_prepare_buffer(x::AbstractArray{T,3}) where {T<:Union{UInt8,Int8}} =
    __prepare_buffer(reinterpret(N0f8, x))
_prepare_buffer(x::AbstractArray{T,3}) where {T<:Union{UInt16,Int16}} =
    __prepare_buffer(reinterpret(N0f16, x))
_prepare_buffer(x::AbstractArray{T,3}) where {T<:Normed} = __prepare_buffer(x)

function __prepare_buffer(x::AbstractArray{T,3}) where {T}
    nchannels = size(x, 3)
    if nchannels == 1
        ifelse(ndims(x) == 3, _prepare_buffer(dropdims(x, dims=3)), x)
    elseif nchannels == 2
        convert(Array{GrayA}, colorview(GrayA, view(x, :, :, 1), view(x, :, :, 2)))
    elseif nchannels == 3
        convert(Array{RGB}, colorview(RGB, view(x, :, :, 1), view(x, :, :, 2), view(x, :, :, 3)))
    elseif nchannels == 4
        convert(
            Array{RGBA},
            colorview(RGBA, view(x, :, :, 1), view(x, :, :, 2), view(x, :, :, 3), view(x, :, :, 4)),
        )
    else
        error("Unsupported number of channels $(nchannels) in input. Only <= 4 is expected.")
    end
end

_get_bit_depth(img::BitArray) = 8  # TODO: write 1 bit-depth images
_get_bit_depth(img::AbstractArray{C}) where {C<:Colorant} = __get_bit_depth(eltype(C))
_get_bit_depth(img::AbstractArray{T}) where {T<:Normed} = __get_bit_depth(T)
# __get_bit_depth(::Type{Normed{T,1}}) where T = 1  # TODO: write 1 bit-depth images
# __get_bit_depth(::Type{Normed{T,2}}) where T = 2  # TODO: write 2 bit-depth images
# __get_bit_depth(::Type{Normed{T,4}}) where T = 4  # TODO: write 4 bit-depth images
__get_bit_depth(::Type{Normed{T,8}}) where T = 8
__get_bit_depth(::Type{Normed{T,16}}) where T = 16
__get_bit_depth(::Type{Normed{T,N}}) where {T,N} = ifelse(N <= 8, 8, 16)
__get_bit_depth(::Type{<:AbstractFloat}) = 8
_get_bit_depth(img::AbstractArray{T}) where {T<:AbstractFloat} = 8
_get_bit_depth(img::AbstractArray{<:Bool}) = 8  # TODO: write 1 bit-depth images
_get_bit_depth(img::AbstractArray{<:UInt8}) = 8
_get_bit_depth(img::AbstractArray{<:UInt16}) = 16

_get_color_type(x::AbstractArray{<:Gray{T}}) where {T} = PNG_COLOR_TYPE_GRAY
_get_color_type(x::AbstractArray{<:GrayA{T}}) where {T} = PNG_COLOR_TYPE_GRAY_ALPHA
_get_color_type(x::AbstractArray{<:RGB{T}}) where {T} = PNG_COLOR_TYPE_RGB
_get_color_type(x::AbstractArray{<:RGBA{T}}) where {T} = PNG_COLOR_TYPE_RGBA
_get_color_type(x::AbstractArray{<:BGR{T}}) where {T} = PNG_COLOR_TYPE_RGB
_get_color_type(x::AbstractArray{<:BGRA{T}}) where {T} = PNG_COLOR_TYPE_RGBA
_get_color_type(x::AbstractArray{<:ARGB{T}}) where {T} = PNG_COLOR_TYPE_RGBA
_get_color_type(x::AbstractArray{<:ABGR{T}}) where {T} = PNG_COLOR_TYPE_RGBA
function _get_color_type(
        x::AbstractArray{T, N}
    ) where {
        T<:Union{Normed,Unsigned,Bool,AbstractFloat},
        N
    }
    if N == 2
        return PNG_COLOR_TYPE_GRAY
    elseif N == 3
        d = size(x, 3)
        d == 1 && (return PNG_COLOR_TYPE_GRAY)
        d == 2 && (return PNG_COLOR_TYPE_GRAY_ALPHA)
        d == 3 && (return PNG_COLOR_TYPE_RGB)
        d == 4 && (return PNG_COLOR_TYPE_RGBA)
    end
    error("Number of dimensions $(N) in image not supported (only 2D or 3D Arrays are expected).")
end
