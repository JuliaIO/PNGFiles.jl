# Manually added
const PNGCAPI = nothing
const PNG_BYTES_TO_CHECK = 8
const png_FILE_p = Ptr{Cvoid}

# Automatically generated using Clang.jl


# Skipping MacroDefinition: PNGARG ( arglist ) arglist

const PNGCBAPI = PNGCAPI
const PNGAPI = PNGCAPI

# Skipping MacroDefinition: PNG_FUNCTION ( type , name , args , attributes ) attributes type name args
# Skipping MacroDefinition: PNG_EXPORT_TYPE ( type ) PNG_IMPEXP type
# Skipping MacroDefinition: PNG_EXPORTA ( ordinal , type , name , args , attributes ) PNG_FUNCTION ( PNG_EXPORT_TYPE ( type ) , ( PNGAPI name ) , PNGARG ( args ) , PNG_LINKAGE_API attributes )
# Skipping MacroDefinition: PNG_EXPORT ( ordinal , type , name , args ) PNG_EXPORTA ( ordinal , type , name , args , PNG_EMPTY )
# Skipping MacroDefinition: PNG_REMOVED ( ordinal , type , name , args , attributes )
# Skipping MacroDefinition: PNG_CALLBACK ( type , name , args ) type ( PNGCBAPI name ) PNGARG ( args )
# Skipping MacroDefinition: PNG_USE_RESULT __attribute__ ( ( __warn_unused_result__ ) )
# Skipping MacroDefinition: PNG_NORETURN __attribute__ ( ( __noreturn__ ) )
# Skipping MacroDefinition: PNG_ALLOCATED __attribute__ ( ( __malloc__ ) )
# Skipping MacroDefinition: PNG_DEPRECATED __attribute__ ( ( __deprecated__ ) )
# Skipping MacroDefinition: PNG_PRIVATE __attribute__ ( ( __unavailable__ ( "This function is not exported by libpng." ) ) )
# Skipping MacroDefinition: PNG_FP_EXPORT ( ordinal , type , name , args ) PNG_EXPORT ( ordinal , type , name , args ) ;
# Skipping MacroDefinition: PNG_FIXED_EXPORT ( ordinal , type , name , args )

const png_byte = Cuchar
const png_int_16 = Int16
const png_uint_16 = UInt16
const png_int_32 = Cint
const png_uint_32 = UInt32
const png_size_t = Csize_t
const png_ptrdiff_t = Cptrdiff_t
const png_alloc_size_t = Csize_t
const png_fixed_point = png_int_32
const png_voidp = Ptr{Cvoid}
const png_const_voidp = Ptr{Cvoid}
const png_bytep = Ptr{png_byte}
const png_const_bytep = Ptr{png_byte}
const png_uint_32p = Ptr{png_uint_32}
const png_const_uint_32p = Ptr{png_uint_32}
const png_int_32p = Ptr{png_int_32}
const png_const_int_32p = Ptr{png_int_32}
const png_uint_16p = Ptr{png_uint_16}
const png_const_uint_16p = Ptr{png_uint_16}
const png_int_16p = Ptr{png_int_16}
const png_const_int_16p = Ptr{png_int_16}
const png_charp = Cstring
const png_const_charp = Cstring
const png_fixed_point_p = Ptr{png_fixed_point}
const png_const_fixed_point_p = Ptr{png_fixed_point}
const png_size_tp = Ptr{Csize_t}
const png_const_size_tp = Ptr{Csize_t}
const png_doublep = Ptr{Cdouble}
const png_const_doublep = Ptr{Cdouble}
const png_bytepp = Ptr{Ptr{png_byte}}
const png_uint_32pp = Ptr{Ptr{png_uint_32}}
const png_int_32pp = Ptr{Ptr{png_int_32}}
const png_uint_16pp = Ptr{Ptr{png_uint_16}}
const png_int_16pp = Ptr{Ptr{png_int_16}}
const png_const_charpp = Ptr{Cstring}
const png_charpp = Ptr{Cstring}
const png_fixed_point_pp = Ptr{Ptr{png_fixed_point}}
const png_doublepp = Ptr{Ptr{Cdouble}}
const png_charppp = Ptr{Ptr{Cstring}}
const PNG_API_RULE = 0
const PNG_DEFAULT_READ_MACROS = 1
const PNG_GAMMA_THRESHOLD_FIXED = 5000
const PNG_ZBUF_SIZE = 8192
const PNG_IDAT_READ_SIZE = PNG_ZBUF_SIZE
const PNG_INFLATE_BUF_SIZE = 1024
const PNG_MAX_GAMMA_8 = 11
const PNG_QUANTIZE_BLUE_BITS = 5
const PNG_QUANTIZE_GREEN_BITS = 5
const PNG_QUANTIZE_RED_BITS = 5
const PNG_TEXT_Z_DEFAULT_COMPRESSION = -1
const PNG_TEXT_Z_DEFAULT_STRATEGY = 0
const PNG_USER_CHUNK_CACHE_MAX = 1000
const PNG_USER_CHUNK_MALLOC_MAX = 8000000
const PNG_USER_HEIGHT_MAX = 1000000
const PNG_USER_WIDTH_MAX = 1000000
const PNG_ZLIB_VERNUM = 0x1250
const PNG_Z_DEFAULT_COMPRESSION = -1
const PNG_Z_DEFAULT_NOFILTER_STRATEGY = 0
const PNG_Z_DEFAULT_STRATEGY = 1
const PNG_sCAL_PRECISION = 5
const PNG_sRGB_PROFILE_CHECKS = 2
const PNG_LIBPNG_VER_STRING = "1.6.37"
const PNG_HEADER_VERSION_STRING = " libpng version 1.6.37 - April 14, 2019\n"
const PNG_LIBPNG_VER_SONUM = 16
const PNG_LIBPNG_VER_DLLNUM = 16
const PNG_LIBPNG_VER_MAJOR = 1
const PNG_LIBPNG_VER_MINOR = 6
const PNG_LIBPNG_VER_RELEASE = 37
const PNG_LIBPNG_VER_BUILD = 0
const PNG_LIBPNG_BUILD_ALPHA = 1
const PNG_LIBPNG_BUILD_BETA = 2
const PNG_LIBPNG_BUILD_RC = 3
const PNG_LIBPNG_BUILD_STABLE = 4
const PNG_LIBPNG_BUILD_RELEASE_STATUS_MASK = 7
const PNG_LIBPNG_BUILD_PATCH = 8
const PNG_LIBPNG_BUILD_PRIVATE = 16
const PNG_LIBPNG_BUILD_SPECIAL = 32
const PNG_LIBPNG_BUILD_BASE_TYPE = PNG_LIBPNG_BUILD_STABLE
const PNG_LIBPNG_VER = 10637
const PNG_LIBPNG_BUILD_TYPE = PNG_LIBPNG_BUILD_BASE_TYPE

# Skipping MacroDefinition: png_libpng_ver png_get_header_ver ( NULL )

const PNG_TEXT_COMPRESSION_NONE_WR = -3
const PNG_TEXT_COMPRESSION_zTXt_WR = -2
const PNG_TEXT_COMPRESSION_NONE = -1
const PNG_TEXT_COMPRESSION_zTXt = 0
const PNG_ITXT_COMPRESSION_NONE = 1
const PNG_ITXT_COMPRESSION_zTXt = 2
const PNG_TEXT_COMPRESSION_LAST = 3
const PNG_HAVE_IHDR = 0x01
const PNG_HAVE_PLTE = 0x02
const PNG_AFTER_IDAT = 0x08

# Skipping MacroDefinition: PNG_UINT_31_MAX ( ( png_uint_32 ) 0x7fffffffL )
# Skipping MacroDefinition: PNG_UINT_32_MAX ( ( png_uint_32 ) ( - 1 ) )
# Skipping MacroDefinition: PNG_SIZE_MAX ( ( size_t ) ( - 1 ) )

const PNG_FP_1 = 100000
const PNG_FP_HALF = 50000

# Skipping MacroDefinition: PNG_FP_MAX ( ( png_fixed_point ) 0x7fffffffL )

const PNG_FP_MAX =  typemax(png_fixed_point)
const PNG_FP_MIN = typemin(png_fixed_point)
const PNG_COLOR_MASK_PALETTE = 1
const PNG_COLOR_MASK_COLOR = 2
const PNG_COLOR_MASK_ALPHA = 4
const PNG_COLOR_TYPE_GRAY = 0
const PNG_COLOR_TYPE_PALETTE = PNG_COLOR_MASK_COLOR | PNG_COLOR_MASK_PALETTE
const PNG_COLOR_TYPE_RGB = PNG_COLOR_MASK_COLOR
const PNG_COLOR_TYPE_RGB_ALPHA = PNG_COLOR_MASK_COLOR | PNG_COLOR_MASK_ALPHA
const PNG_COLOR_TYPE_GRAY_ALPHA = PNG_COLOR_MASK_ALPHA
const PNG_COLOR_TYPE_RGBA = PNG_COLOR_TYPE_RGB_ALPHA
const PNG_COLOR_TYPE_GA = PNG_COLOR_TYPE_GRAY_ALPHA
const PNG_COMPRESSION_TYPE_BASE = 0
const PNG_COMPRESSION_TYPE_DEFAULT = PNG_COMPRESSION_TYPE_BASE
const PNG_FILTER_TYPE_BASE = 0
const PNG_INTRAPIXEL_DIFFERENCING = 64
const PNG_FILTER_TYPE_DEFAULT = PNG_FILTER_TYPE_BASE
const PNG_INTERLACE_NONE = 0
const PNG_INTERLACE_ADAM7 = 1
const PNG_INTERLACE_LAST = 2
const PNG_OFFSET_PIXEL = 0
const PNG_OFFSET_MICROMETER = 1
const PNG_OFFSET_LAST = 2
const PNG_EQUATION_LINEAR = 0
const PNG_EQUATION_BASE_E = 1
const PNG_EQUATION_ARBITRARY = 2
const PNG_EQUATION_HYPERBOLIC = 3
const PNG_EQUATION_LAST = 4
const PNG_SCALE_UNKNOWN = 0
const PNG_SCALE_METER = 1
const PNG_SCALE_RADIAN = 2
const PNG_SCALE_LAST = 3
const PNG_RESOLUTION_UNKNOWN = 0
const PNG_RESOLUTION_METER = 1
const PNG_RESOLUTION_LAST = 2
const PNG_sRGB_INTENT_PERCEPTUAL = 0
const PNG_sRGB_INTENT_RELATIVE = 1
const PNG_sRGB_INTENT_SATURATION = 2
const PNG_sRGB_INTENT_ABSOLUTE = 3
const PNG_sRGB_INTENT_LAST = 4
const PNG_KEYWORD_MAX_LENGTH = 79
const PNG_MAX_PALETTE_LENGTH = 256
const PNG_INFO_gAMA = UInt32(0x0001)
const PNG_INFO_sBIT = UInt32(0x0002)
const PNG_INFO_cHRM = UInt32(0x0004)
const PNG_INFO_PLTE = UInt32(0x0008)
const PNG_INFO_tRNS = UInt32(0x0010)
const PNG_INFO_bKGD = UInt32(0x0020)
const PNG_INFO_hIST = UInt32(0x0040)
const PNG_INFO_pHYs = UInt32(0x0080)
const PNG_INFO_oFFs = UInt32(0x0100)
const PNG_INFO_tIME = UInt32(0x0200)
const PNG_INFO_pCAL = UInt32(0x0400)
const PNG_INFO_sRGB = UInt32(0x0800)
const PNG_INFO_iCCP = UInt32(0x1000)
const PNG_INFO_sPLT = UInt32(0x2000)
const PNG_INFO_sCAL = UInt32(0x4000)
const PNG_INFO_IDAT = UInt32(0x8000)
const PNG_INFO_eXIf = UInt32(0x00010000)
const PNG_TRANSFORM_IDENTITY = 0x0000
const PNG_TRANSFORM_STRIP_16 = 0x0001
const PNG_TRANSFORM_STRIP_ALPHA = 0x0002
const PNG_TRANSFORM_PACKING = 0x0004
const PNG_TRANSFORM_PACKSWAP = 0x0008
const PNG_TRANSFORM_EXPAND = 0x0010
const PNG_TRANSFORM_INVERT_MONO = 0x0020
const PNG_TRANSFORM_SHIFT = 0x0040
const PNG_TRANSFORM_BGR = 0x0080
const PNG_TRANSFORM_SWAP_ALPHA = 0x0100
const PNG_TRANSFORM_SWAP_ENDIAN = 0x0200
const PNG_TRANSFORM_INVERT_ALPHA = 0x0400
const PNG_TRANSFORM_STRIP_FILLER = 0x0800
const PNG_TRANSFORM_STRIP_FILLER_BEFORE = PNG_TRANSFORM_STRIP_FILLER
const PNG_TRANSFORM_STRIP_FILLER_AFTER = 0x1000
const PNG_TRANSFORM_GRAY_TO_RGB = 0x2000
const PNG_TRANSFORM_EXPAND_16 = 0x4000
const PNG_TRANSFORM_SCALE_16 = 0x8000
const PNG_FLAG_MNG_EMPTY_PLTE = 0x01
const PNG_FLAG_MNG_FILTER_64 = 0x04
const PNG_ALL_MNG_FEATURES = 0x05

# Skipping MacroDefinition: png_check_sig ( sig , n ) ! png_sig_cmp ( ( sig ) , 0 , ( n ) )
# Skipping MacroDefinition: png_jmpbuf ( png_ptr ) ( * png_set_longjmp_fn ( ( png_ptr ) , longjmp , ( sizeof ( jmp_buf ) ) ) )

const PNG_ERROR_ACTION_NONE = 1
const PNG_ERROR_ACTION_WARN = 2
const PNG_ERROR_ACTION_ERROR = 3
const PNG_RGB_TO_GRAY_DEFAULT = -1
const PNG_ALPHA_PNG = 0
const PNG_ALPHA_STANDARD = 1
const PNG_ALPHA_ASSOCIATED = 1
const PNG_ALPHA_PREMULTIPLIED = 1
const PNG_ALPHA_OPTIMIZED = 2
const PNG_ALPHA_BROKEN = 3
const PNG_DEFAULT_sRGB = -1
const PNG_GAMMA_MAC_18 = -2
const PNG_GAMMA_sRGB = 220000
const PNG_GAMMA_LINEAR = PNG_FP_1
const PNG_FILLER_BEFORE = 0
const PNG_FILLER_AFTER = 1
const PNG_BACKGROUND_GAMMA_UNKNOWN = 0
const PNG_BACKGROUND_GAMMA_SCREEN = 1
const PNG_BACKGROUND_GAMMA_FILE = 2
const PNG_BACKGROUND_GAMMA_UNIQUE = 3
const PNG_GAMMA_THRESHOLD = PNG_GAMMA_THRESHOLD_FIXED * 1.0e-5
const PNG_CRC_DEFAULT = 0
const PNG_CRC_ERROR_QUIT = 1
const PNG_CRC_WARN_DISCARD = 2
const PNG_CRC_WARN_USE = 3
const PNG_CRC_QUIET_USE = 4
const PNG_CRC_NO_CHANGE = 5
const PNG_NO_FILTERS = 0x00
const PNG_FILTER_NONE = 0x08
const PNG_FILTER_SUB = 0x10
const PNG_FILTER_UP = 0x20
const PNG_FILTER_AVG = 0x40
const PNG_FILTER_PAETH = 0x80
const PNG_FAST_FILTERS = (PNG_FILTER_NONE | PNG_FILTER_SUB) | PNG_FILTER_UP
const PNG_ALL_FILTERS = (PNG_FAST_FILTERS | PNG_FILTER_AVG) | PNG_FILTER_PAETH
const PNG_FILTER_VALUE_NONE = 0
const PNG_FILTER_VALUE_SUB = 1
const PNG_FILTER_VALUE_UP = 2
const PNG_FILTER_VALUE_AVG = 3
const PNG_FILTER_VALUE_PAETH = 4
const PNG_FILTER_VALUE_LAST = 5
const PNG_FILTER_HEURISTIC_DEFAULT = 0
const PNG_FILTER_HEURISTIC_UNWEIGHTED = 1
const PNG_FILTER_HEURISTIC_WEIGHTED = 2
const PNG_FILTER_HEURISTIC_LAST = 3
const PNG_DESTROY_WILL_FREE_DATA = 1
const PNG_SET_WILL_FREE_DATA = 1
const PNG_USER_WILL_FREE_DATA = 2
const PNG_FREE_HIST = UInt32(0x0008)
const PNG_FREE_ICCP = UInt32(0x0010)
const PNG_FREE_SPLT = UInt32(0x0020)
const PNG_FREE_ROWS = UInt32(0x0040)
const PNG_FREE_PCAL = UInt32(0x0080)
const PNG_FREE_SCAL = UInt32(0x0100)
const PNG_FREE_UNKN = UInt32(0x0200)
const PNG_FREE_PLTE = UInt32(0x1000)
const PNG_FREE_TRNS = UInt32(0x2000)
const PNG_FREE_TEXT = UInt32(0x4000)
const PNG_FREE_EXIF = UInt32(0x8000)
const PNG_FREE_ALL = UInt32(0xffff)
const PNG_FREE_MUL = UInt32(0x4220)
const PNG_HANDLE_CHUNK_AS_DEFAULT = 0
const PNG_HANDLE_CHUNK_NEVER = 1
const PNG_HANDLE_CHUNK_IF_SAFE = 2
const PNG_HANDLE_CHUNK_ALWAYS = 3
const PNG_HANDLE_CHUNK_LAST = 4
const PNG_IO_NONE = 0x0000
const PNG_IO_READING = 0x0001
const PNG_IO_WRITING = 0x0002
const PNG_IO_SIGNATURE = 0x0010
const PNG_IO_CHUNK_HDR = 0x0020
const PNG_IO_CHUNK_DATA = 0x0040
const PNG_IO_CHUNK_CRC = 0x0080
const PNG_IO_MASK_OP = Float32(0x0000)
const PNG_IO_MASK_LOC = 0x00f0
const PNG_INTERLACE_ADAM7_PASSES = 7

# Skipping MacroDefinition: PNG_PASS_START_ROW ( pass ) ( ( ( 1 & ~ ( pass ) ) << ( 3 - ( ( pass ) >> 1 ) ) ) & 7 )
# Skipping MacroDefinition: PNG_PASS_START_COL ( pass ) ( ( ( 1 & ( pass ) ) << ( 3 - ( ( ( pass ) + 1 ) >> 1 ) ) ) & 7 )
# Skipping MacroDefinition: PNG_PASS_ROW_OFFSET ( pass ) ( ( pass ) > 2 ? ( 8 >> ( ( ( pass ) - 1 ) >> 1 ) ) : 8 )
# Skipping MacroDefinition: PNG_PASS_COL_OFFSET ( pass ) ( 1 << ( ( 7 - ( pass ) ) >> 1 ) )
# Skipping MacroDefinition: PNG_PASS_ROW_SHIFT ( pass ) ( ( pass ) > 2 ? ( 8 - ( pass ) ) >> 1 : 3 )
# Skipping MacroDefinition: PNG_PASS_COL_SHIFT ( pass ) ( ( pass ) > 1 ? ( 7 - ( pass ) ) >> 1 : 3 )
# Skipping MacroDefinition: PNG_PASS_ROWS ( height , pass ) ( ( ( height ) + ( ( ( 1 << PNG_PASS_ROW_SHIFT ( pass ) ) - 1 ) - PNG_PASS_START_ROW ( pass ) ) ) >> PNG_PASS_ROW_SHIFT ( pass ) )
# Skipping MacroDefinition: PNG_PASS_COLS ( width , pass ) ( ( ( width ) + ( ( ( 1 << PNG_PASS_COL_SHIFT ( pass ) ) - 1 ) - PNG_PASS_START_COL ( pass ) ) ) >> PNG_PASS_COL_SHIFT ( pass ) )
# Skipping MacroDefinition: PNG_ROW_FROM_PASS_ROW ( y_in , pass ) ( ( ( y_in ) << PNG_PASS_ROW_SHIFT ( pass ) ) + PNG_PASS_START_ROW ( pass ) )
# Skipping MacroDefinition: PNG_COL_FROM_PASS_COL ( x_in , pass ) ( ( ( x_in ) << PNG_PASS_COL_SHIFT ( pass ) ) + PNG_PASS_START_COL ( pass ) )
# Skipping MacroDefinition: PNG_PASS_MASK ( pass , off ) ( ( ( 0x110145AF >> ( ( ( 7 - ( off ) ) - ( pass ) ) << 2 ) ) & 0xF ) | ( ( 0x01145AF0 >> ( ( ( 7 - ( off ) ) - ( pass ) ) << 2 ) ) & 0xF0 ) )
# Skipping MacroDefinition: PNG_ROW_IN_INTERLACE_PASS ( y , pass ) ( ( PNG_PASS_MASK ( pass , 0 ) >> ( ( y ) & 7 ) ) & 1 )
# Skipping MacroDefinition: PNG_COL_IN_INTERLACE_PASS ( x , pass ) ( ( PNG_PASS_MASK ( pass , 1 ) >> ( ( x ) & 7 ) ) & 1 )
# Skipping MacroDefinition: png_composite ( composite , fg , alpha , bg ) { png_uint_16 temp = ( png_uint_16 ) ( ( png_uint_16 ) ( fg ) * ( png_uint_16 ) ( alpha ) + ( png_uint_16 ) ( bg ) * ( png_uint_16 ) ( 255 - ( png_uint_16 ) ( alpha ) ) + 128 ) ; ( composite ) = ( png_byte ) ( ( ( temp + ( temp >> 8 ) ) >> 8 ) & 0xff ) ; }
# Skipping MacroDefinition: png_composite_16 ( composite , fg , alpha , bg ) { png_uint_32 temp = ( png_uint_32 ) ( ( png_uint_32 ) ( fg ) * ( png_uint_32 ) ( alpha ) + ( png_uint_32 ) ( bg ) * ( 65535 - ( png_uint_32 ) ( alpha ) ) + 32768 ) ; ( composite ) = ( png_uint_16 ) ( 0xffff & ( ( temp + ( temp >> 16 ) ) >> 16 ) ) ; }
# Skipping MacroDefinition: PNG_get_uint_32 ( buf ) ( ( ( png_uint_32 ) ( * ( buf ) ) << 24 ) + ( ( png_uint_32 ) ( * ( ( buf ) + 1 ) ) << 16 ) + ( ( png_uint_32 ) ( * ( ( buf ) + 2 ) ) << 8 ) + ( ( png_uint_32 ) ( * ( ( buf ) + 3 ) ) ) )
# Skipping MacroDefinition: PNG_get_uint_16 ( buf ) ( ( png_uint_16 ) ( ( ( unsigned int ) ( * ( buf ) ) << 8 ) + ( ( unsigned int ) ( * ( ( buf ) + 1 ) ) ) ) )
# Skipping MacroDefinition: PNG_get_int_32 ( buf ) ( ( png_int_32 ) ( ( * ( buf ) & 0x80 ) ? - ( ( png_int_32 ) ( ( ( png_get_uint_32 ( buf ) ^ 0xffffffffU ) + 1U ) & 0x7fffffffU ) ) : ( png_int_32 ) png_get_uint_32 ( buf ) ) )
# Skipping MacroDefinition: png_get_uint_32 ( buf ) PNG_get_uint_32 ( buf )
# Skipping MacroDefinition: png_get_uint_16 ( buf ) PNG_get_uint_16 ( buf )
# Skipping MacroDefinition: png_get_int_32 ( buf ) PNG_get_int_32 ( buf )

const PNG_IMAGE_VERSION = 1
const PNG_IMAGE_WARNING = 1
const PNG_IMAGE_ERROR = 2

# Skipping MacroDefinition: PNG_IMAGE_FAILED ( png_cntrl ) ( ( ( ( png_cntrl ) . warning_or_error ) & 0x03 ) > 1 )

const PNG_FORMAT_FLAG_ALPHA = UInt32(0x01)
const PNG_FORMAT_FLAG_COLOR = UInt32(0x02)
const PNG_FORMAT_FLAG_LINEAR = UInt32(0x04)
const PNG_FORMAT_FLAG_COLORMAP = UInt32(0x08)
const PNG_FORMAT_FLAG_BGR = UInt32(0x10)
const PNG_FORMAT_FLAG_AFIRST = UInt32(0x20)
const PNG_FORMAT_FLAG_ASSOCIATED_ALPHA = UInt32(0x40)
const PNG_FORMAT_GRAY = 0
const PNG_FORMAT_GA = PNG_FORMAT_FLAG_ALPHA
const PNG_FORMAT_AG = PNG_FORMAT_GA | PNG_FORMAT_FLAG_AFIRST
const PNG_FORMAT_RGB = PNG_FORMAT_FLAG_COLOR
const PNG_FORMAT_BGR = PNG_FORMAT_FLAG_COLOR | PNG_FORMAT_FLAG_BGR
const PNG_FORMAT_RGBA = PNG_FORMAT_RGB | PNG_FORMAT_FLAG_ALPHA
const PNG_FORMAT_ARGB = PNG_FORMAT_RGBA | PNG_FORMAT_FLAG_AFIRST
const PNG_FORMAT_BGRA = PNG_FORMAT_BGR | PNG_FORMAT_FLAG_ALPHA
const PNG_FORMAT_ABGR = PNG_FORMAT_BGRA | PNG_FORMAT_FLAG_AFIRST
const PNG_FORMAT_LINEAR_Y = PNG_FORMAT_FLAG_LINEAR
const PNG_FORMAT_LINEAR_Y_ALPHA = PNG_FORMAT_FLAG_LINEAR | PNG_FORMAT_FLAG_ALPHA
const PNG_FORMAT_LINEAR_RGB = PNG_FORMAT_FLAG_LINEAR | PNG_FORMAT_FLAG_COLOR
const PNG_FORMAT_LINEAR_RGB_ALPHA = (PNG_FORMAT_FLAG_LINEAR | PNG_FORMAT_FLAG_COLOR) | PNG_FORMAT_FLAG_ALPHA
const PNG_FORMAT_RGB_COLORMAP = PNG_FORMAT_RGB | PNG_FORMAT_FLAG_COLORMAP
const PNG_FORMAT_BGR_COLORMAP = PNG_FORMAT_BGR | PNG_FORMAT_FLAG_COLORMAP
const PNG_FORMAT_RGBA_COLORMAP = PNG_FORMAT_RGBA | PNG_FORMAT_FLAG_COLORMAP
const PNG_FORMAT_ARGB_COLORMAP = PNG_FORMAT_ARGB | PNG_FORMAT_FLAG_COLORMAP
const PNG_FORMAT_BGRA_COLORMAP = PNG_FORMAT_BGRA | PNG_FORMAT_FLAG_COLORMAP
const PNG_FORMAT_ABGR_COLORMAP = PNG_FORMAT_ABGR | PNG_FORMAT_FLAG_COLORMAP

# Skipping MacroDefinition: PNG_IMAGE_SAMPLE_CHANNELS ( fmt ) ( ( ( fmt ) & ( PNG_FORMAT_FLAG_COLOR | PNG_FORMAT_FLAG_ALPHA ) ) + 1 )
# Skipping MacroDefinition: PNG_IMAGE_SAMPLE_COMPONENT_SIZE ( fmt ) ( ( ( ( fmt ) & PNG_FORMAT_FLAG_LINEAR ) >> 2 ) + 1 )
# Skipping MacroDefinition: PNG_IMAGE_SAMPLE_SIZE ( fmt ) ( PNG_IMAGE_SAMPLE_CHANNELS ( fmt ) * PNG_IMAGE_SAMPLE_COMPONENT_SIZE ( fmt ) )
# Skipping MacroDefinition: PNG_IMAGE_MAXIMUM_COLORMAP_COMPONENTS ( fmt ) ( PNG_IMAGE_SAMPLE_CHANNELS ( fmt ) * 256 )
# Skipping MacroDefinition: PNG_IMAGE_PIXEL_ ( test , fmt ) ( ( ( fmt ) & PNG_FORMAT_FLAG_COLORMAP ) ? 1 : test ( fmt ) )
# Skipping MacroDefinition: PNG_IMAGE_PIXEL_CHANNELS ( fmt ) PNG_IMAGE_PIXEL_ ( PNG_IMAGE_SAMPLE_CHANNELS , fmt )
# Skipping MacroDefinition: PNG_IMAGE_PIXEL_COMPONENT_SIZE ( fmt ) PNG_IMAGE_PIXEL_ ( PNG_IMAGE_SAMPLE_COMPONENT_SIZE , fmt )
# Skipping MacroDefinition: PNG_IMAGE_PIXEL_SIZE ( fmt ) PNG_IMAGE_PIXEL_ ( PNG_IMAGE_SAMPLE_SIZE , fmt )
# Skipping MacroDefinition: PNG_IMAGE_ROW_STRIDE ( image ) ( PNG_IMAGE_PIXEL_CHANNELS ( ( image ) . format ) * ( image ) . width )
# Skipping MacroDefinition: PNG_IMAGE_BUFFER_SIZE ( image , row_stride ) ( PNG_IMAGE_PIXEL_COMPONENT_SIZE ( ( image ) . format ) * ( image ) . height * ( row_stride ) )
# Skipping MacroDefinition: PNG_IMAGE_SIZE ( image ) PNG_IMAGE_BUFFER_SIZE ( image , PNG_IMAGE_ROW_STRIDE ( image ) )
# Skipping MacroDefinition: PNG_IMAGE_COLORMAP_SIZE ( image ) ( PNG_IMAGE_SAMPLE_SIZE ( ( image ) . format ) * ( image ) . colormap_entries )

const PNG_IMAGE_FLAG_COLORSPACE_NOT_sRGB = 0x01
const PNG_IMAGE_FLAG_FAST = 0x02
const PNG_IMAGE_FLAG_16BIT_sRGB = 0x04

# Skipping MacroDefinition: png_image_write_get_memory_size ( image , size , convert_to_8_bit , buffer , row_stride , colormap ) png_image_write_to_memory ( & ( image ) , 0 , & ( size ) , convert_to_8_bit , buffer , row_stride , colormap )
# Skipping MacroDefinition: PNG_IMAGE_DATA_SIZE ( image ) ( PNG_IMAGE_SIZE ( image ) + ( image ) . height )
# Skipping MacroDefinition: PNG_ZLIB_MAX_SIZE ( b ) ( ( b ) + ( ( ( b ) + 7U ) >> 3 ) + ( ( ( b ) + 63U ) >> 6 ) + 11U )
# Skipping MacroDefinition: PNG_IMAGE_COMPRESSED_SIZE_MAX ( image ) PNG_ZLIB_MAX_SIZE ( ( png_alloc_size_t ) PNG_IMAGE_DATA_SIZE ( image ) )
# Skipping MacroDefinition: PNG_IMAGE_PNG_SIZE_MAX_ ( image , image_size ) ( ( 8U /*sig*/ + 25U /*IHDR*/ + 16U /*gAMA*/ + 44U /*cHRM*/ + 12U /*IEND*/ + ( ( ( image ) . format & PNG_FORMAT_FLAG_COLORMAP ) ? /*colormap: PLTE, tRNS*/ 12U + 3U * ( image ) . colormap_entries /*PLTE data*/ + ( ( ( image ) . format & PNG_FORMAT_FLAG_ALPHA ) ? 12U /*tRNS*/ + ( image ) . colormap_entries : 0U ) : 0U ) + 12U ) + ( 12U * ( ( image_size ) / PNG_ZBUF_SIZE ) ) /*IDAT*/ + ( image_size ) )
# Skipping MacroDefinition: PNG_IMAGE_PNG_SIZE_MAX ( image ) PNG_IMAGE_PNG_SIZE_MAX_ ( image , PNG_IMAGE_COMPRESSED_SIZE_MAX ( image ) )

const PNG_MAXIMUM_INFLATE_WINDOW = 2
const PNG_SKIP_sRGB_CHECK_PROFILE = 4
const PNG_IGNORE_ADLER32 = 8
const PNG_OPTION_NEXT = 12
const PNG_OPTION_UNSET = 0
const PNG_OPTION_INVALID = 1
const PNG_OPTION_OFF = 2
const PNG_OPTION_ON = 3
const png_libpng_version_1_6_37 = Cstring
const png_struct_def = Cvoid
const png_struct = png_struct_def
const png_const_structp = Ptr{png_struct}
const png_structp = Ptr{png_struct}
const png_structpp = Ptr{Ptr{png_struct}}
const png_info_def = Cvoid
const png_info = png_info_def
const png_infop = Ptr{png_info}
const png_const_infop = Ptr{png_info}
const png_infopp = Ptr{Ptr{png_info}}
const png_structrp = Ptr{png_struct}
const png_const_structrp = Ptr{png_struct}
const png_inforp = Ptr{png_info}
const png_const_inforp = Ptr{png_info}

struct png_color_struct
    red::png_byte
    green::png_byte
    blue::png_byte
end

const png_color = png_color_struct
const png_colorp = Ptr{png_color}
const png_const_colorp = Ptr{png_color}
const png_colorpp = Ptr{Ptr{png_color}}

struct png_color_16_struct
    index::png_byte
    red::png_uint_16
    green::png_uint_16
    blue::png_uint_16
    gray::png_uint_16
end

const png_color_16 = png_color_16_struct
const png_color_16p = Ptr{png_color_16}
const png_const_color_16p = Ptr{png_color_16}
const png_color_16pp = Ptr{Ptr{png_color_16}}

struct png_color_8_struct
    red::png_byte
    green::png_byte
    blue::png_byte
    gray::png_byte
    alpha::png_byte
end

const png_color_8 = png_color_8_struct
const png_color_8p = Ptr{png_color_8}
const png_const_color_8p = Ptr{png_color_8}
const png_color_8pp = Ptr{Ptr{png_color_8}}

struct png_sPLT_entry_struct
    red::png_uint_16
    green::png_uint_16
    blue::png_uint_16
    alpha::png_uint_16
    frequency::png_uint_16
end

const png_sPLT_entry = png_sPLT_entry_struct
const png_sPLT_entryp = Ptr{png_sPLT_entry}
const png_const_sPLT_entryp = Ptr{png_sPLT_entry}
const png_sPLT_entrypp = Ptr{Ptr{png_sPLT_entry}}

struct png_sPLT_struct
    name::png_charp
    depth::png_byte
    entries::png_sPLT_entryp
    nentries::png_int_32
end

const png_sPLT_t = png_sPLT_struct
const png_sPLT_tp = Ptr{png_sPLT_t}
const png_const_sPLT_tp = Ptr{png_sPLT_t}
const png_sPLT_tpp = Ptr{Ptr{png_sPLT_t}}

struct png_text_struct
    compression::Cint
    key::png_charp
    text::png_charp
    text_length::Csize_t
    itxt_length::Csize_t
    lang::png_charp
    lang_key::png_charp
end

const png_text = png_text_struct
const png_textp = Ptr{png_text}
const png_const_textp = Ptr{png_text}
const png_textpp = Ptr{Ptr{png_text}}

struct png_time_struct
    year::png_uint_16
    month::png_byte
    day::png_byte
    hour::png_byte
    minute::png_byte
    second::png_byte
end

const png_time = png_time_struct
const png_timep = Ptr{png_time}
const png_const_timep = Ptr{png_time}
const png_timepp = Ptr{Ptr{png_time}}

struct png_unknown_chunk_t
    name::NTuple{5, png_byte}
    data::Ptr{png_byte}
    size::Csize_t
    location::png_byte
end

const png_unknown_chunk = png_unknown_chunk_t
const png_unknown_chunkp = Ptr{png_unknown_chunk}
const png_const_unknown_chunkp = Ptr{png_unknown_chunk}
const png_unknown_chunkpp = Ptr{Ptr{png_unknown_chunk}}

struct png_row_info_struct
    width::png_uint_32
    rowbytes::Csize_t
    color_type::png_byte
    bit_depth::png_byte
    channels::png_byte
    pixel_depth::png_byte
end

const png_row_info = png_row_info_struct
const png_row_infop = Ptr{png_row_info}
const png_row_infopp = Ptr{Ptr{png_row_info}}
const png_error_ptr = Ptr{Cvoid}
const png_rw_ptr = Ptr{Cvoid}
const png_flush_ptr = Ptr{Cvoid}
const png_read_status_ptr = Ptr{Cvoid}
const png_write_status_ptr = Ptr{Cvoid}
const png_progressive_info_ptr = Ptr{Cvoid}
const png_progressive_end_ptr = Ptr{Cvoid}
const png_progressive_row_ptr = Ptr{Cvoid}
const png_user_transform_ptr = Ptr{Cvoid}
const png_user_chunk_ptr = Ptr{Cvoid}
const png_longjmp_ptr = Ptr{Cvoid}
const png_malloc_ptr = Ptr{Cvoid}
const png_free_ptr = Ptr{Cvoid}
const png_control = Cvoid
const png_controlp = Ptr{png_control}

struct png_image
    opaque::png_controlp
    version::png_uint_32
    width::png_uint_32
    height::png_uint_32
    format::png_uint_32
    flags::png_uint_32
    colormap_entries::png_uint_32
    warning_or_error::png_uint_32
    message::NTuple{64, UInt8}
end

const png_imagep = Ptr{png_image}
