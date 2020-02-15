
function map_color(color_type, bit_depth)
    if color_type == PNG_COLOR_TYPE_GRAY
        colors_type = Gray{bit_depth}
    elseif color_type == PNG_COLOR_TYPE_PALETTE
        colors_type = RGB{bit_depth}
    elseif color_type == PNG_COLOR_TYPE_RGB
        colors_type = RGB{bit_depth}
    elseif color_type == PNG_COLOR_TYPE_RGB_ALPHA
        colors_type = RGBA{bit_depth}
    elseif color_type == PNG_COLOR_TYPE_GRAY_ALPHA
        colors_type = GrayA{bit_depth}
    else
        error("Unknown color type: $color_type")
    end
    return colors_type
end

function readimage(filename::String, transforms::Int = 0)
    fp = open_png(filename)

    png_ptr = create_read_struct()
    info_ptr = create_info_struct(png_ptr)
    png_init_io(png_ptr, fp)
    png_set_sig_bytes(png_ptr, PNG_BYTES_TO_CHECK)

    png_read_png(png_ptr, info_ptr, transforms, C_NULL)

    width = png_get_image_width(png_ptr, info_ptr)
    height = png_get_image_height(png_ptr, info_ptr)
    color_type = png_get_color_type(png_ptr, info_ptr)
    bit_depth = png_get_bit_depth(png_ptr, info_ptr)
    num_channels = png_get_channels(png_ptr, info_ptr)

    if (color_type == PNG_COLOR_TYPE_PALETTE)
        error("The color type PNG_COLOR_TYPE_PALETTE is not currently supported.")
    end

    @debug """Read image info:
            width=$width,
            height=$height,
            color_type=$color_type,
            bit_depth=$bit_depth,
            num_channels=$num_channels"""

    even_depth = ((bit_depth + 1) >> 1) << 1
    if bit_depth <= 8
        T = Normed{UInt8, 8}
    elseif bit_depth <= 16
        T = Normed{UInt16, even_depth}
    else
        # TODO UInt32?
        error("Unknown bit_depth: $bit_depth")
    end

    colors_type = map_color(color_type, T)
    buf = Array{colors_type}(undef, height, width)
    get_image_pixels!(rawview(channelview(buf)), png_ptr, info_ptr)
    png_destroy_read_struct(Ref{Ptr{Cvoid}}(png_ptr), Ref{Ptr{Cvoid}}(info_ptr), C_NULL)
    close_png(fp)
    return buf
end

function get_image_pixels!(buf::AbstractArray{T, 2}, png_ptr::Ptr{Cvoid}, info_ptr::Ptr{Cvoid}) where T<:Unsigned
    height, width = size(buf)
    #rows = png_get_rows(png_ptr, info_ptr) #Clang-wrapped version is fixed to UInt8 output!
    rows = ccall((:png_get_rows, libpng), Ptr{Ptr{T}}, (Ptr{Cvoid}, Ptr{Cvoid}), png_ptr, info_ptr)
    for i = 1:height
        row = unsafe_load(rows, i)
        for j = 1:width
            buf[i, j] = unsafe_load(row, j)
        end
    end
    buf
end

function get_image_pixels!(buf::AbstractArray{T, 3}, png_ptr::Ptr{Cvoid}, info_ptr::Ptr{Cvoid}) where T<:Unsigned
    num_channels, height, width = size(buf)
    #rows = png_get_rows(png_ptr, info_ptr) #Clang-wrapped version is fixed to UInt8 output!
    rows = ccall((:png_get_rows, libpng), Ptr{Ptr{T}}, (Ptr{Cvoid}, Ptr{Cvoid}), png_ptr, info_ptr)
    for i = 1:height
        row = unsafe_load(rows, i)
        for j = 1:width
            for c = 1:num_channels
                buf[c, i, j] = unsafe_load(row, num_channels * (j - 1) + c)
            end
        end
    end
    buf
end

function get_image_pixels!(buf::AbstractArray{T, N}, png_ptr::Ptr{Cvoid}, info_ptr::Ptr{Cvoid}) where {T, N}
    error("Image array has invalid dimension $N")
end

to_raw(A::AbstractArray{C}) where C<:Colorant  = to_raw(channelview(A))
to_raw(A::AbstractArray{T}) where T<:Normed    = rawview(A)
to_raw(A::AbstractArray{T}) where T<:Real      = to_raw(convert(Array{N0f8}, A))
to_raw(A::ColorView) = channelview(A)

get_bit_depth(img::AbstractArray{C}) where C<:Colorant = _get_bit_depth(eltype(C))
get_bit_depth(img::AbstractArray{T}) where T<:Normed = _get_bit_depth(T)
_get_bit_depth(::Type{Normed{T, N}}) where {T, N} = N
_get_bit_depth(img::Type{T}) where T<:AbstractFloat = 8
_get_bit_depth(img::Type{Bool}) = 8

get_color_type(::Type{Gray{T}}) where T   = PNG_COLOR_TYPE_GRAY
get_color_type(::Type{GrayA{T}}) where T  = PNG_COLOR_TYPE_GRAY_ALPHA
get_color_type(::Type{RGB{T}}) where T    = PNG_COLOR_TYPE_RGB
get_color_type(::Type{RGBA{T}}) where T   = PNG_COLOR_TYPE_RGBA
get_color_type(::Type{T}) where T<:Normed = PNG_COLOR_TYPE_RGB

map_image(c::Gray{T}) where T = convert(Gray{N0f8}, c)
map_image(c::Gray{T}) where T<:Normed = c
map_image(c::GrayA{T}) where T = convert(GrayA{N0f8}, c)
map_image(c::GrayA{T}) where T<:Normed = c
map_image(c::RGB{T}) where T = convert(RGB{N0f8}, c)
map_image(c::RGB{T}) where T<:Normed = c
map_image(c::RGBA{T}) where T = convert(RGBA{N0f8}, c)
map_image(c::RGBA{T}) where T<:Normed = c

map_image(x::Bool) = convert(Gray{N0f8}, x)
map_image(x::AbstractFloat) = convert(N0f8, x)
map_image(x::Normed) = x

get_image_size(buffer::AbstractArray{T,2}) where T = size(buffer)
get_image_size(buffer::AbstractArray{T,N}) where {T, N} = error("Number of dimensions in image of $ndims not supported.")
function get_image_size(buffer::AbstractArray{T,3}) where T
    n_channels, height, width = size(buffer)
    height, width
end

function writeimage(filename::String, image::AbstractArray{T}) where T

    fp = ccall(:fopen, Ptr{Cvoid}, (Cstring, Cstring), filename, "wb")
    fp == C_NULL && error("Could not open $(filename) for writing")

    png_ptr = create_write_struct(png_error_fn, png_warn_fn)
    info_ptr = create_info_struct(png_ptr)
    png_init_io(png_ptr, fp)

    image = map(map_image, image)
    buffer = to_raw(image)

    height, width = get_image_size(buffer)
    bit_depth = get_bit_depth(image)

    color_type = get_color_type(eltype(image))
    interlace = 0        # Set to always off
    compression_type = 0 # Set to always off
    filter_type = 0      # Set to always off

    @debug """Write image info:
            width=$width,
            height=$height,
            bit_depth=$bit_depth,
            color_type=$color_type,
            interlace=$interlace,
            compression_type=$compression_type,
            filter_type=$filter_type"""

    png_set_IHDR(png_ptr, info_ptr, width, height, bit_depth, color_type, interlace, compression_type, filter_type)
    png_write_info(png_ptr, info_ptr)
    #png_set_swap(png_ptr)
    write_rows(buffer, png_ptr, info_ptr)
    png_destroy_write_struct(Ref(png_ptr), Ref(info_ptr))
    close_png(fp)

    return nothing
end

# 2 dim matrix
function write_rows(buf::AbstractArray{T, 2}, png_ptr::Ptr{Cvoid}, info_ptr::Ptr{Cvoid}) where T
    height, width = get_image_size(buf)
    for row = 1:height
        row_buf = buf[row, :]
        png_write_row(png_ptr, row_buf)
    end
    png_write_end(png_ptr, info_ptr)
end

# 3-dim matrix
function write_rows(buf::AbstractArray{T, 3}, png_ptr::Ptr{Cvoid}, info_ptr::Ptr{Cvoid}) where T
    height, width = get_image_size(buf)
    for row = 1:height
        row_buf = buf[:, row, :]
        png_write_row(png_ptr, row_buf)
    end
    png_write_end(png_ptr, info_ptr)
end

function write_rows(buf::AbstractArray{T, N}, png_ptr::Ptr{Cvoid}, info_ptr::Ptr{Cvoid}) where {T, N}
    error("Image has invalid dimension $N")
end
