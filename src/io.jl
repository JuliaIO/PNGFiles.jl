"""
    load(fpath::String; gamma::Union{Nothing,Float64}=nothing, expand_paletted::Bool=false)
    load(s::IO; gamma::Union{Nothing,Float64}=nothing, expand_paletted::Bool=false)

Read a `.png` image from file at `fpath` or in IO stream `s`.
`gamma` can be used to override the automatic gamma correction, a value of 1.0
means no gamma correction.

The result will be an 8 bit (N0f8) image if the source bit depth is <= 8 bits, 16 bit (N0f16)
otherwise.

The number of channels (and transparency) of the source determines the color type of the output:
- 1 channel  -> Gray
- 2 channels -> GrayA
- 3 channels -> RGB
- 4 channels -> RGBA

When reading in simple paletted images, i.e. having a PLTE chunk and an 8 bit depth, the image will
be represented as an `IndirectArray` with `OffsetArray` `values` field. To always get back a plain
`Matrix` of colorants, use `expand_paletted=true`.
"""
function load(fpath::String; gamma::Union{Nothing,Float64}=nothing, expand_paletted::Bool=false)
    fp = open_png(fpath)
    png_ptr = create_read_struct()
    info_ptr = create_info_struct(png_ptr)
    png_init_io(png_ptr, fp)
    png_set_sig_bytes(png_ptr, PNG_BYTES_TO_CHECK)
    out = _load(png_ptr, info_ptr, gamma=gamma, expand_paletted=expand_paletted)
    close_png(fp)
    return out
end

maybe_lock(f, io::IO) = lock(f, io)
# IOStream doesn't support locking...
maybe_lock(f, io::IOStream) = f()
maybe_lock(f, io::IOBuffer) = f()

function load(s::IO; gamma::Union{Nothing,Float64}=nothing, expand_paletted::Bool=false)
    isreadable(s) || throw(ArgumentError("read failed, IOStream is not readable"))
    Base.eof(s) && throw(EOFError())

    png_ptr = create_read_struct()
    info_ptr = create_info_struct(png_ptr)

    maybe_lock(s) do
        if s isa IOBuffer
            png_set_read_fn(png_ptr, pointer_from_objref(s), readcallback_iobuffer_c[])
        else
            png_set_read_fn(png_ptr, s.handle, readcallback_c[])
        end
        # https://stackoverflow.com/questions/22564718/libpng-error-png-unsigned-integer-out-of-range
        png_set_sig_bytes(png_ptr, 0)
        return _load(png_ptr, info_ptr, gamma=gamma, expand_paletted=expand_paletted)
    end
end

function _readcallback(png_ptr::png_structp, data::png_bytep, length::png_size_t)::Cvoid
    a = png_get_io_ptr(png_ptr)
    ccall(:ios_readall, Csize_t, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), a, data, length)
    return
end

function _readcallback_iobuffer(png_ptr::png_structp, data::png_bytep, length::png_size_t)::Cvoid
    a = png_get_io_ptr(png_ptr)
    io = unsafe_pointer_to_objref(a)
    unsafe_read(io, Ptr{UInt8}(data), length)
    return
end

function _load(png_ptr, info_ptr; gamma::Union{Nothing,Float64}=nothing, expand_paletted::Bool=false)
    png_read_info(png_ptr, info_ptr)

    width = png_get_image_width(png_ptr, info_ptr)
    height = png_get_image_height(png_ptr, info_ptr)
    color_type_orig = png_get_color_type(png_ptr, info_ptr)
    color_type = color_type_orig
    bit_depth_orig = png_get_bit_depth(png_ptr, info_ptr)
    bit_depth = bit_depth_orig
    num_channels = png_get_channels(png_ptr, info_ptr)
    interlace_type = png_get_interlace_type(png_ptr, info_ptr)

    # TODO: verify this is needed
    backgroundp = png_color_16p()
    if png_get_bKGD(png_ptr, info_ptr, Ptr{png_color_16p}(backgroundp)) != 0
        png_set_background(png_ptr, backgroundp, PNG_BACKGROUND_GAMMA_FILE, 1, 1.0)
    end

    screen_gamma = PNG_DEFAULT_sRGB
    image_gamma = Ref{Cdouble}(-1.0)
    intent = Ref{Cint}(-1)
    if isnothing(gamma)
        if png_get_valid(png_ptr, info_ptr, PNG_INFO_sRGB) != 0
            if png_get_sRGB(png_ptr, info_ptr, intent) != 0
                png_set_gamma(png_ptr, screen_gamma, PNG_DEFAULT_sRGB);
            else
                if png_get_gAMA(png_ptr, info_ptr, image_gamma) != 0
                    png_set_gamma(png_ptr, screen_gamma, image_gamma[])
                else
                    image_gamma[] = 0.45455
                    png_set_gamma(png_ptr, screen_gamma, image_gamma[])
                end
            end
        elseif png_get_valid(png_ptr, info_ptr, PNG_INFO_gAMA) != 0
            if png_get_gAMA(png_ptr, info_ptr, image_gamma) != 0
                png_set_gamma(png_ptr, screen_gamma, image_gamma[])
            else
                image_gamma[] = 0.45455
                png_set_gamma(png_ptr, screen_gamma, image_gamma[])
            end
        end
    elseif gamma != 1
        image_gamma[] = gamma
        png_set_gamma(png_ptr, screen_gamma, image_gamma[])
    end

    read_as_paletted = !expand_paletted &&
        color_type == PNG_COLOR_TYPE_PALETTE &&
        bit_depth == 8

    if !read_as_paletted
        if color_type == PNG_COLOR_TYPE_PALETTE
            png_set_palette_to_rgb(png_ptr)
            color_type = PNG_COLOR_TYPE_RGB
        end

        if color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8
            png_set_expand_gray_1_2_4_to_8(png_ptr)
            png_set_packing(png_ptr)
            bit_depth = 8
        end

        if png_get_valid(png_ptr, info_ptr, PNG_INFO_tRNS) != 0
            png_set_tRNS_to_alpha(png_ptr)
            if color_type == PNG_COLOR_TYPE_GRAY || color_type == PNG_COLOR_TYPE_RGB
                color_type |= PNG_COLOR_MASK_ALPHA
            end
        end
        buffer_eltype = _buffer_color_type(color_type, bit_depth)
        bit_depth == 16 && png_set_swap(png_ptr)
    end
    n_passes = png_set_interlace_handling(png_ptr)
    png_read_update_info(png_ptr, info_ptr)

    # Gamma correction is applied to a palette after `png_read_update_info` is called
    if read_as_paletted
        palette_length = Ref{Cint}()
        # TODO: Figure out the lenght of paletted before calling png_get_PLTEs
        palette_buffer = Vector{RGB{N0f8}}(undef, PNG_MAX_PALETTE_LENGTH)
        png_get_PLTE(png_ptr, info_ptr, pointer_from_objref(palette_buffer), palette_length)
        palette = palette_buffer[1:palette_length[]]

        if png_get_valid(png_ptr, info_ptr, PNG_INFO_tRNS) != 0
            alpha_buffer = Vector{_AlphaBuffer}(undef, palette_length[])
            alphas_cnt = Ref{Cint}()
            png_get_tRNS(png_ptr, info_ptr, pointer_from_objref(alpha_buffer), alphas_cnt, C_NULL)
            if alphas_cnt[] > 1
                palette = map(x->RGBA(x[1], x[2].val), zip(palette, alpha_buffer))
            else
                # Seems that if there is only one transparency entry, it is applied to the first
                # color in palette while the rest of the colors are opaque
                α = alpha_buffer[1].val
                palette = map(x->RGBA(x[2], x[1] == 1 ? α : 1), enumerate(palette))
            end
        end
        buffer_eltype = UInt8
    end

    # We transpose to work around libpng expecting row-major arrays
    buffer = Array{buffer_eltype}(undef, width, height)

    @debug(
        "Read PNG info:",
        fpath,
        height,
        width,
        color_type_orig,
        color_type,
        bit_depth_orig,
        bit_depth,
        num_channels,
        interlace_type,
        gamma,
        image_gamma[],
        screen_gamma,
        intent[],
        read_as_paletted,
        n_passes,
        buffer_eltype,
        PNG_HEADER_VERSION_STRING
    )

    png_read_image(png_ptr, map(pointer, eachcol(buffer)))
    png_read_end(png_ptr, info_ptr)
    png_destroy_read_struct(Ref{Ptr{Cvoid}}(png_ptr), Ref{Ptr{Cvoid}}(info_ptr), C_NULL)
    buffer = permutedims(buffer, (2, 1))
    if expand_paletted || color_type != PNG_COLOR_TYPE_PALETTE
        return buffer
    else
        # We got 0-based indices back from libpng and converting to 1-based could overflow UInt8.
        # Using UInt16 for index would cost us large part of the savings provided by IndirectArray.
        return IndirectArray(buffer, OffsetArray(palette, -1))
    end
end

function _buffer_color_type(color_type, bit_depth)
    bit_depth = Int(bit_depth)
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

const SupportedPaletteColor = Union{
    AbstractRGB{<:Union{N0f8,AbstractFloat}},
    TransparentRGB{T,<:Union{N0f8,AbstractFloat}} where T,
}

"""
    save(fpath::String, image::AbstractArray;
         compression_level::Integer=0, compression_strategy::Integer=3, filters::Integer=4)
    save(s::IO, image::AbstractArray;
         compression_level::Integer=0, compression_strategy::Integer=3, filters::Integer=4)

Writes `image` as a png to file at `fpath`, or to IO stream `s`.

## Arguments
- `compression_level`: 0 (`Z_NO_COMPRESSION`), 1 (`Z_BEST_SPEED`), ..., 9 (`Z_BEST_COMPRESSION`)
- `compression_strategy`: 0 (`Z_DEFAULT_STRATEGY`), 1 (`Z_FILTERED`), 2 (`Z_HUFFMAN_ONLY`), 3 (`Z_RLE`), 4 (`Z_FIXED`)
- `filters`: 0 (None), 1 (Sub), 2 (Up), 3 (Average), 4 (Paeth).

The saved image will have 16 bits of depth if the `image` has eltype that is based on `UInt16`,
8 bits otherwise.

The number of channels and element type of the `image` determines the color type of the
output:
- 0/1 channel Float / Integer / Normed or Gray eltype        -> `PNG_COLOR_TYPE_GRAY`
- 2 channels Float  / Integer / Normed or GrayA eltype       -> `PNG_COLOR_TYPE_GRAY_ALPHA`
- 3 channels Float  / Integer / Normed or RGB / BGR eltype   -> `PNG_COLOR_TYPE_RGB`
- 4 channels Float  / Integer / Normed or ARGB / ABGR eltype -> `PNG_COLOR_TYPE_RGB_ALPHA`

When `image` is an `IndirectArray` with up to 256 unique RGB colors, the result is encoded as a
"paletted image".

"""
function save(
    fpath::String,
    image::S;
    compression_level::Integer = Z_BEST_SPEED,
    compression_strategy::Integer = Z_RLE,
    filters::Integer = Int(PNG_FILTER_PAETH),
    palette::Union{Nothing,AbstractVector{<:Union{RGB{N0f8},RGBA{N0f8}}}} = nothing,
) where {
    T,
    S<:Union{AbstractMatrix,AbstractArray{T,3}}
}
    @assert Z_DEFAULT_STRATEGY <= compression_strategy <= Z_FIXED
    @assert Z_NO_COMPRESSION <= compression_level <= Z_BEST_COMPRESSION
    @assert 2 <= ndims(image) <= 3
    @assert size(image, 3) <= 4

    fp = ccall(:fopen, Ptr{Cvoid}, (Cstring, Cstring), fpath, "wb")
    fp == C_NULL && error("Could not open $(fpath) for writing")

    png_ptr = create_write_struct()
    info_ptr = create_info_struct(png_ptr)

    png_init_io(png_ptr, fp)

    _save(png_ptr, info_ptr, image,
        compression_level=compression_level,
        compression_strategy=compression_strategy,
        filters=filters,
        palette=palette)

    close_png(fp)
end
function save(
    s::IO,
    image::S;
    compression_level::Integer = Z_BEST_SPEED,
    compression_strategy::Integer = Z_RLE,
    filters::Integer = Int(PNG_FILTER_PAETH),
    palette::Union{Nothing,AbstractVector{<:Union{RGB{N0f8},RGBA{N0f8}}}} = nothing,
) where {
    T,
    S<:Union{AbstractMatrix,AbstractArray{T,3}}
}
    @assert Z_DEFAULT_STRATEGY <= compression_strategy <= Z_FIXED
    @assert Z_NO_COMPRESSION <= compression_level <= Z_BEST_COMPRESSION
    @assert 2 <= ndims(image) <= 3
    @assert size(image, 3) <= 4
    iswritable(s) || throw(ArgumentError("write failed, IOStream is not writeable"))

    png_ptr = create_write_struct()
    info_ptr = create_info_struct(png_ptr)
    maybe_lock(s) do
        png_set_write_fn(png_ptr, s.handle, writecallback_c[], C_NULL)

        _save(png_ptr, info_ptr, image,
            compression_level=compression_level,
            compression_strategy=compression_strategy,
            filters=filters,
            palette=palette)

    end
end

function _save(png_ptr, info_ptr, image::S;
    compression_level::Integer = Z_BEST_SPEED,
    compression_strategy::Integer = Z_RLE,
    filters::Integer = Int(PNG_FILTER_PAETH),
    palette::Union{Nothing,AbstractVector{<:Union{RGB{N0f8},RGBA{N0f8}}}} = nothing,
) where {
    T,
    S<:Union{AbstractMatrix,AbstractArray{T,3}}
}
    height, width = size(image)[1:2]
    bit_depth = _get_bit_depth(image)
    color_type = _get_color_type(image)

    png_set_filter(png_ptr, PNG_FILTER_TYPE_BASE, UInt32(filters))
    png_set_compression_level(png_ptr, compression_level)
    png_set_compression_strategy(png_ptr, compression_strategy)

    if color_type == PNG_COLOR_TYPE_PALETTE
        # TODO: 1, 2, 4 bit-depth indices for palleted
        _png_check_paletted(image)
        palette = image.values
        color_count = length(palette)
        if eltype(palette) <: TransparentRGB
            png_set_PLTE(png_ptr, info_ptr, _standardize_palette(color.(palette)), color_count)
            png_set_tRNS(png_ptr, info_ptr, _palette_alpha(palette), color_count, C_NULL)
        else
            png_set_PLTE(png_ptr, info_ptr, _standardize_palette(palette), color_count)
        end
    else
        image_eltype = eltype(image)
        if (image_eltype <: BGR || image_eltype <: BGRA || image_eltype <: ABGR)
            png_set_bgr(png_ptr)
        end

        if (image_eltype <: ABGR || image_eltype <: ARGB)
            png_set_swap_alpha(png_ptr)
        end

        if color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8
            png_set_packing(png_ptr)
            bit_depth = 8  # TODO: support 1, 2, 4 bit-depth gray images
        end
    end

    # gAMA and cHRM chunks should be always present for compatibility with older systems
    png_set_sRGB_gAMA_and_cHRM(png_ptr, info_ptr, 0)

    @debug(
        "Write PNG info:",
        fpath,
        height,
        width,
        bit_depth,
        color_type,
        filters,
        compression_level,
        compression_strategy,
        palette,
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
        PNG_INTERLACE_NONE,
        PNG_COMPRESSION_TYPE_BASE,
        PNG_FILTER_TYPE_BASE,
    )

    png_write_info(png_ptr, info_ptr)
    # Handles endianness for 16 bit, must be set after png_write_info
    bit_depth == 16 && png_set_swap(png_ptr)

    # We transpose to work around libpng expecting row-major arrays
    _write_image(permutedims(_prepare_buffer(image), (2, 1)), png_ptr, info_ptr)

    png_destroy_write_struct(Ref(png_ptr), Ref(info_ptr))
end

function _writecallback(png_ptr::png_structp, data::png_bytep, length::png_size_t)::Csize_t
    a = png_get_io_ptr(png_ptr)
    return ccall(:ios_write, Csize_t, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), a, data, length)
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

function _png_check_paletted(image)
    palette = image.values
    color_count = length(palette)
    color_type = eltype(palette)

    ndims(image) != 2 && throw(ArgumentError("Only 2D `IndirectArrays` are supported"))
    color_count > 256 && throw(ArgumentError("Maximum size of `image.velues` is 256 colors"))
    if !(color_type <: SupportedPaletteColor)
        throw(ArgumentError(
            "Only 8-bit (transparent) RGB colors are supported for paletted images"
        ))
    end
end

function _prepare_buffer(x::IndirectArray{T,2,I,V}) where {T,I<:AbstractMatrix{<:UInt8},V<:OffsetVector}
    return UInt8.(x.index .- (x.values.offsets[1] + 1))
end
_prepare_buffer(x::IndirectArray) = UInt8.(x.index .- 1)
_prepare_buffer(x::BitArray) = _prepare_buffer(collect(x))
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:Colorant{<:Normed}} = x
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:UInt8} =  reinterpret(Gray{N0f8}, x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:UInt16} = reinterpret(Gray{N0f16}, x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:Normed} = reinterpret(Gray{T}, x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:Gray{<:AbstractFloat}} =  Gray{N0f8}.(x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:GrayA{<:AbstractFloat}} = GrayA{N0f8}.(x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:RGB{<:AbstractFloat}} =   RGB{N0f8}.(x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:RGBA{<:AbstractFloat}} =  RGBA{N0f8}.(x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:BGR{<:AbstractFloat}} =   BGR{N0f8}.(x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:BGRA{<:AbstractFloat}} =  BGRA{N0f8}.(x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:ARGB{<:AbstractFloat}} =  ARGB{N0f8}.(x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:ABGR{<:AbstractFloat}} =  ABGR{N0f8}.(x)
_prepare_buffer(x::AbstractMatrix{<:T}) where {T<:Union{AbstractFloat,Bool}} = reinterpret(Gray{N0f8}, N0f8.(x))
_prepare_buffer(x::AbstractArray{T,3}) where {T<:Union{AbstractFloat,Bool}} = __prepare_buffer(N0f8.(x))
_prepare_buffer(x::AbstractArray{T,3}) where {T<:Union{UInt8,Int8}} = __prepare_buffer(reinterpret(N0f8, x))
_prepare_buffer(x::AbstractArray{T,3}) where {T<:Union{UInt16,Int16}} = __prepare_buffer(reinterpret(N0f16, x))
_prepare_buffer(x::AbstractArray{T,3}) where {T<:Normed} = __prepare_buffer(x)

function __prepare_buffer(x::AbstractArray{T,3}) where {T}
    nchannels = size(x, 3)
    if nchannels == 1
        ifelse(ndims(x) == 3, _prepare_buffer(dropdims(x, dims=3)), x)
    elseif nchannels == 2
        GrayA.(colorview(GrayA, view(x, :, :, 1), view(x, :, :, 2)))
    elseif nchannels == 3
        RGB.(colorview(RGB, view(x, :, :, 1), view(x, :, :, 2), view(x, :, :, 3)))
    elseif nchannels == 4
        RGBA.(colorview(RGBA, view(x, :, :, 1), view(x, :, :, 2), view(x, :, :, 3), view(x, :, :, 4)))
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
_get_color_type(x::IndirectArray) = PNG_COLOR_TYPE_PALETTE
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

_standardize_palette(p::AbstractVector{<:RGB}) = p
_standardize_palette(p::AbstractVector{<:AbstractRGB}) = RGB.(p)
_standardize_palette(p::AbstractVector{<:RGB{<:AbstractFloat}}) = RGB{N0f8}.(p)
_standardize_palette(p::AbstractVector{<:AbstractRGB{<:AbstractFloat}}) = RGB{N0f8}.(p)
_standardize_palette(p::OffsetArray) = _standardize_palette(parent(p))

_palette_alpha(p::OffsetArray) where {T} = _palette_alpha(collect(p))
_palette_alpha(p::AbstractVector{<:TransparentRGB{T,N0f8}}) where {T} = alpha.(p)
_palette_alpha(p::AbstractVector{<:TransparentRGB{T,<:AbstractFloat}}) where {T} = N0f8.(alpha.(p))
