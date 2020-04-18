# A dummy struct used to easily collect alpha values for paletted images. It allows us to simply
# call `pointer_from_objref` on a `Vector{_AlphaBuffer}`
struct _AlphaBuffer
    val::N0f8
end


function _inspect_png_read(fpath, gamma::Union{Nothing,Float64}=nothing)
    fp = open_png(fpath)
    png_ptr = create_read_struct()
    info_ptr = create_info_struct(png_ptr)
    png_init_io(png_ptr, fp)
    png_set_sig_bytes(png_ptr, PNG_BYTES_TO_CHECK)
    png_read_info(png_ptr, info_ptr)

    width = png_get_image_width(png_ptr, info_ptr)
    height = png_get_image_height(png_ptr, info_ptr)
    color_type_orig = png_get_color_type(png_ptr, info_ptr)
    color_type = color_type_orig
    bit_depth_orig = png_get_bit_depth(png_ptr, info_ptr)
    bit_depth = bit_depth_orig
    num_channels = png_get_channels(png_ptr, info_ptr)
    interlace_type = png_get_interlace_type(png_ptr, info_ptr)

    backgroundp = png_color_16p()
    if png_get_bKGD(png_ptr, info_ptr, Ref(backgroundp)[]) != 0
        png_set_background(png_ptr, backgroundp, PNG_BACKGROUND_GAMMA_FILE, 1, 1.0)
    end

    if color_type == PNG_COLOR_TYPE_PALETTE
        png_set_palette_to_rgb(png_ptr)
        color_type = PNG_COLOR_TYPE_RGB
    end

    if color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8
        png_set_expand_gray_1_2_4_to_8(png_ptr)
        png_set_packing(png_ptr)
        bit_depth = UInt8(8)
    end

    if png_get_valid(png_ptr, info_ptr, PNG_INFO_tRNS) != 0
        png_set_tRNS_to_alpha(png_ptr)
        if color_type == PNG_COLOR_TYPE_GRAY || color_type == PNG_COLOR_TYPE_RGB
            color_type |= PNG_COLOR_MASK_ALPHA
        end
    end

    screen_gamma = PNG_DEFAULT_sRGB
    image_gamma = Ref{Cdouble}(0.0)
    intent = Ref{Cint}(-1)
    white_x = Ref{Cdouble}(0.0)
    white_y = Ref{Cdouble}(0.0)
    red_x = Ref{Cdouble}(0.0)
    red_y = Ref{Cdouble}(0.0)
    green_x = Ref{Cdouble}(0.0)
    green_y = Ref{Cdouble}(0.0)
    blue_x = Ref{Cdouble}(0.0)
    blue_y = Ref{Cdouble}(0.0)
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

    buffer_eltype = _buffer_color_type(color_type, bit_depth)
    bit_depth == 16 && png_set_swap(png_ptr)
    n_passes = png_set_interlace_handling(png_ptr)
    png_read_update_info(png_ptr, info_ptr)
    chunk_info(chunk) = png_get_valid(png_ptr, info_ptr, chunk)

    @show(fpath,
        chunk_info(PNG_INFO_sRGB),
        chunk_info(PNG_INFO_iCCP),
        chunk_info(PNG_INFO_gAMA),
        chunk_info(PNG_INFO_tRNS),
        chunk_info(PNG_INFO_cHRM),
        chunk_info(PNG_INFO_PLTE),
        chunk_info(PNG_INFO_sPLT),
        chunk_info(PNG_INFO_hIST),
        chunk_info(PNG_INFO_sBIT),
        chunk_info(PNG_INFO_bKGD),
        chunk_info(PNG_INFO_pCAL),
        (height, width, num_channels),
        (color_type_orig, color_type),
        (bit_depth_orig, bit_depth),
        (image_gamma[], screen_gamma),
        intent[],
        (white_x[], white_y[], red_x[], red_y[], green_x[], green_y[], blue_x[], blue_y[]),
        (interlace_type, n_passes),
        buffer_eltype,
    )

    png_destroy_read_struct(Ref{Ptr{Cvoid}}(png_ptr), Ref{Ptr{Cvoid}}(info_ptr), C_NULL)
    close_png(fp)
end
