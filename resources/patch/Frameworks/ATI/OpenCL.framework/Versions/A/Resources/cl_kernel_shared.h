/*******************************************************************************
 * Copyright:  (c) 2008-2012 by Apple, Inc., All Rights Reserved.
 ******************************************************************************/


#ifndef __CL_KERNEL_SHARED_H__
#define __CL_KERNEL_SHARED_H__

#ifndef __OPENCL_TYPES_DEFINED__
    #include <stddef.h>
    #include <stdint.h>

    typedef char            char16      __attribute__ ((__vector_size__(16)));
    typedef unsigned char   uchar16     __attribute__ ((__vector_size__(16)));
    typedef short           short8      __attribute__ ((__vector_size__(16)));
    typedef unsigned short  ushort8     __attribute__ ((__vector_size__(16)));
    typedef float           float4      __attribute__ ((__vector_size__(16)));
    typedef int             int4        __attribute__ ((__vector_size__(16)));
    typedef unsigned int    uint4       __attribute__ ((__vector_size__(16)));
    typedef long long       long2       __attribute__ ((__vector_size__(16)));
    typedef unsigned long long  ulong2  __attribute__ ((__vector_size__(16)));
    typedef double          double2     __attribute__ ((__vector_size__(16)));
    typedef size_t          event_t;
    typedef unsigned char   uchar;
    typedef unsigned short  ushort;
    typedef unsigned int    uint;

    typedef struct short16{ short8 lo, hi;  }short16;
    typedef struct ushort16{ ushort8 lo, hi;  }ushort16;
    typedef struct int8{ int4 lo, hi; }int8;
    typedef struct int16{ struct{ int4 lo, hi; }lo; struct{ int4 lo, hi; }hi; }int16;
    typedef struct uint16{ struct{ uint4 lo, hi; }lo; struct{ uint4 lo, hi; }hi; }uint16;
    typedef struct float16{ struct{ float4 lo, hi; }lo; struct{ float4 lo, hi; }hi; }float16;

#ifdef AVX_IMAGE_AUTOVEC_BRINGUP
    typedef struct float8{ float4 lo, hi; }float8;
    typedef struct float32{ float16 lo,hi; }float32;
#endif

    #define __OPENCL_TYPES_DEFINED__
#endif /* __OPENCL_TYPES_DEFINED__ */

// Channel order; MUST be kept in sync with cld_internal.h in the drivers.
enum {
  CLK_R,
  CLK_A,
  CLK_RG,
  CLK_RA,
  CLK_RGB,
  CLK_RGBA,
  CLK_ARGB,
  CLK_BGRA,
  CLK_INTENSITY,
  CLK_LUMINANCE,
  CLK_Rx,
  CLK_RGx,
  CLK_RGBx,
  CLK_1RGB_APPLE,
  CLK_BGR1_APPLE,
  CLK_422_YCbYCr_APPLE,
  CLK_422_CbYCrY_APPLE,
};

// Extension: cl_APPLE_yuv
// YUV color conversion matrices
enum {
    CLK_ITU_601_APPLE = 0x1000000A,
    CLK_ITU_709_APPLE = 0x1000000B
};

// Extension: cl_APPLE_yuv
// YUV chroma siting
enum {
    CLK_CHROMA_CENTERED_APPLE = 0x1000000C,
    CLK_CHROMA_COSITED_APPLE = 0x1000000D
};

typedef enum clk_channel_type{
  // valid formats for float return types
  CLK_SNORM_INT8,            // four channel RGBA unorm8
  CLK_UNORM_INT8,            // four channel RGBA unorm8
  CLK_SNORM_INT16,           // four channel RGBA unorm16
  CLK_UNORM_INT16,           // four channel RGBA unorm16
  CLK_HALF_FLOAT,            // four channel RGBA half
  CLK_FLOAT,                 // four channel RGBA float

  // valid only for integer return types
  CLK_SIGNED_INT8,
  CLK_SIGNED_INT16,
  CLK_SIGNED_INT32,
  CLK_UNSIGNED_INT8,
  CLK_UNSIGNED_INT16,
  CLK_UNSIGNED_INT32,

  // CI SPI for CPU
  __CLK_UNORM_INT8888,         // four channel ARGB unorm8
  __CLK_UNORM_INT8888R,        // four channel BGRA unorm8
  __CLK_UNORM_INT8A,           // single channel CL_A unorm8
  __CLK_UNORM_INT8I,           // single channel CL_INTENSITY unorm8

  CLK_UNORM_SHORT_565,
  CLK_UNORM_SHORT_555,
  CLK_UNORM_INT_101010,
  
  CLK_UNORM_INT8_ITU_601_APPLE,
  CLK_UNORM_INT8_ITU_709_APPLE,
  CLK_SFIXED14_APPLE,
  CLK_BIASED_HALF_APPLE,
  
  __CLK_VALID_IMAGE_TYPE_COUNT,
  __CLK_INVALID_IMAGE_TYPE = __CLK_VALID_IMAGE_TYPE_COUNT,
  __CLK_VALID_IMAGE_TYPE_MASK_BITS = 5,         // number of bits required to represent any image type
  __CLK_VALID_IMAGE_TYPE_MASK = ( 1 << __CLK_VALID_IMAGE_TYPE_MASK_BITS ) - 1
}clk_channel_type;

typedef enum clk_sampler_type
{
    __CLK_ADDRESS_BASE             = 0,
    CLK_ADDRESS_NONE               = 0 << __CLK_ADDRESS_BASE,
    CLK_ADDRESS_CLAMP              = 1 << __CLK_ADDRESS_BASE,
    CLK_ADDRESS_CLAMP_TO_EDGE      = 2 << __CLK_ADDRESS_BASE,
    CLK_ADDRESS_REPEAT             = 3 << __CLK_ADDRESS_BASE,
    CLK_ADDRESS_MIRRORED_REPEAT    = 4 << __CLK_ADDRESS_BASE,
    __CLK_ADDRESS_MASK             = CLK_ADDRESS_NONE | CLK_ADDRESS_CLAMP | CLK_ADDRESS_CLAMP_TO_EDGE | CLK_ADDRESS_REPEAT | CLK_ADDRESS_MIRRORED_REPEAT,
    __CLK_ADDRESS_BITS             = 3,        // number of bits required to represent address info

    __CLK_NORMALIZED_BASE          = __CLK_ADDRESS_BITS,
    CLK_NORMALIZED_COORDS_FALSE    = 0,
    CLK_NORMALIZED_COORDS_TRUE     = 1 << __CLK_NORMALIZED_BASE,
    __CLK_NORMALIZED_MASK          = CLK_NORMALIZED_COORDS_FALSE | CLK_NORMALIZED_COORDS_TRUE,
    __CLK_NORMALIZED_BITS          = 1,        // number of bits required to represent normalization 

    __CLK_FILTER_BASE              = __CLK_NORMALIZED_BASE + __CLK_NORMALIZED_BITS,
    CLK_FILTER_NEAREST             = 0 << __CLK_FILTER_BASE,
    CLK_FILTER_LINEAR              = 1 << __CLK_FILTER_BASE,
    CLK_FILTER_ANISOTROPIC         = 2 << __CLK_FILTER_BASE,
    __CLK_FILTER_MASK              = CLK_FILTER_NEAREST | CLK_FILTER_LINEAR | CLK_FILTER_ANISOTROPIC,
    __CLK_FILTER_BITS              = 2,        // number of bits required to represent address info

    __CLK_MIP_BASE                 = __CLK_FILTER_BASE + __CLK_FILTER_BITS,
    CLK_MIP_NEAREST                = 0 << __CLK_MIP_BASE,
    CLK_MIP_LINEAR                 = 1 << __CLK_MIP_BASE,
    CLK_MIP_ANISOTROPIC            = 2 << __CLK_MIP_BASE,
    __CLK_MIP_MASK                 = CLK_MIP_NEAREST | CLK_MIP_LINEAR | CLK_MIP_ANISOTROPIC,
    __CLK_MIP_BITS                 = 2,
  
    __CLK_SAMPLER_BITS             = __CLK_MIP_BASE + __CLK_MIP_BITS,
    __CLK_SAMPLER_MASK             = __CLK_MIP_MASK | __CLK_FILTER_MASK | __CLK_NORMALIZED_MASK | __CLK_ADDRESS_MASK,
    
    __CLK_ANISOTROPIC_RATIO_BITS   = 5,
    __CLK_ANISOTROPIC_RATIO_MASK   = (int) 0x80000000 >> (__CLK_ANISOTROPIC_RATIO_BITS-1)
}clk_sampler_type;


#if defined( __clang__ )
    //FIXME: commented out per <rdar://problem/6307429> ABI bustage in read_image
    #define __FAST_CALL           /* __attribute__ ((fastcall)) */
    #define __ALWAYS_INLINE       __attribute__ ((__always_inline__))
    #define INLINE                  inline
#else
    // compiling GCC version for debugging
    #define __FAST_CALL
    #define __ALWAYS_INLINE      __attribute__ (( __noinline__))
    #define INLINE
#endif

#if defined( __OPENCL_TYPES_DEFINED__ )

    struct __ImageFuncTableTransposed;
    struct __ImageFuncTable;

    typedef struct __ImageExecInfo
    {
        int4                                largest;                    //largest valid position in { x, y, z, x-3 } Unused fields should be INT_MAX
        float4                              imageSize;                  //size of the image as { w, h, d, 0 }
        ulong2                              stride;                     //# of elements per row in { rowElements, slicePitch } Unused fields should be 0
        void                                *data;                      // ptr to image data
        void                                *readConstants;             // ptr to __gReadConstants + 8 * float4
        void                                *writeConstants;            // ptr to __gWriteConstants + 8 * float4
        size_t                              pixelType;                  // type of image, also index into table for writes
        size_t                              width, height, depth;
        int                                 user_pixel_type;
        int                                 user_channel_order;
        struct __ImageFuncTableTransposed   *imageFuncTableTransposed;  // ptr to the __ImageFuncTable_F for this image type
        struct __ImageFuncTable             *imageFuncTable;            // ptr to the __ImageFuncTable_F for this image type
    }__ImageExecInfo __attribute__ ((aligned(16)));

    typedef float4  (*__Read_1d_ff) ( const __ImageExecInfo *, float4 where )          __FAST_CALL;
    typedef float4  (*__Read_2d_fi) ( const __ImageExecInfo *, int4 where )            __FAST_CALL;
    typedef float16 (*__Read4_2d_fi)( const __ImageExecInfo *, int4 where )            __FAST_CALL;
    typedef float4  (*__Read_2d_ff) ( const __ImageExecInfo *, float4 where )          __FAST_CALL;
    typedef float16 (*__Read4_2d_ff)( const __ImageExecInfo *, float4 x, float4 y )    __FAST_CALL;
    typedef float4  (*__Read_3d_fi) ( const __ImageExecInfo *, int4 where )            __FAST_CALL;
    typedef float4  (*__Read_3d_ff) ( const __ImageExecInfo *, float4 where )          __FAST_CALL;
    typedef float16 (*__Read4_3d_ff)( const __ImageExecInfo *, float4 x, float4 y, float4 z )    __FAST_CALL;
    
    typedef float4  (*__Read_1d_arr_ff) ( const __ImageExecInfo *, float4 where )      __FAST_CALL;
    typedef float4  (*__Read_2d_arr_fi) ( const __ImageExecInfo *, int4 where )        __FAST_CALL;
    typedef float4  (*__Read_2d_arr_ff) ( const __ImageExecInfo *, float4 where )      __FAST_CALL;
    
    typedef void    (*__Write_2d_fi)( float4,  const __ImageExecInfo *, int4 where )   __FAST_CALL;
    typedef void    (*__Write4_2d_fi)( float4 r, float4 g, float4 b, float4 a, const __ImageExecInfo *i, int4 where )     __FAST_CALL;
    typedef void    (*__Write_3d_fi)( float4,  const __ImageExecInfo *, int4 where )   __FAST_CALL;

    typedef int4    (*__Read_2d_ii) ( const __ImageExecInfo *, int4 where )            __FAST_CALL;
    typedef int4    (*__Read_2d_if) ( const __ImageExecInfo *, float4 where )          __FAST_CALL;
    typedef void    (*__Write_2d_ii)( int4,  const __ImageExecInfo *, int4 where )     __FAST_CALL;
    typedef void    (*__Write_3d_ii)( int4,  const __ImageExecInfo *, int4 where )     __FAST_CALL;
    typedef int4    (*__Read_3d_ii) ( const __ImageExecInfo *, int4 where )            __FAST_CALL;
    typedef int4    (*__Read_3d_if) ( const __ImageExecInfo *, float4 where )          __FAST_CALL;
    
    typedef int4    (*__Read_2d_arr_ii) ( const __ImageExecInfo *, int4 where )        __FAST_CALL;
    typedef int4    (*__Read_2d_arr_if) ( const __ImageExecInfo *, float4 where )      __FAST_CALL;
    
    typedef uint4   (*__Read_2d_ui) ( const __ImageExecInfo *, int4 where )            __FAST_CALL;
    typedef uint4   (*__Read_2d_uf) ( const __ImageExecInfo *, float4 where )          __FAST_CALL;
    typedef void    (*__Write_2d_ui)( uint4,  const __ImageExecInfo *, int4 where )     __FAST_CALL;
    typedef void    (*__Write_3d_ui)( uint4,  const __ImageExecInfo *, int4 where )     __FAST_CALL;
    typedef uint4   (*__Read_3d_ui) ( const __ImageExecInfo *, int4 where )            __FAST_CALL;
    typedef uint4   (*__Read_3d_uf) ( const __ImageExecInfo *, float4 where )          __FAST_CALL;
    
    typedef uint4   (*__Read_2d_arr_ui) ( const __ImageExecInfo *, int4 where )        __FAST_CALL;
    typedef uint4   (*__Read_2d_arr_uf) ( const __ImageExecInfo *, float4 where )      __FAST_CALL;
    
    typedef event_t (*__Write_array_2d_fi) ( const __ImageExecInfo *, size_t x, size_t y, size_t count, const float4 *dest )   __FAST_CALL;
    typedef event_t (*__Read_array_2d_ff)( const __ImageExecInfo *i, float4 start, float4 stride, size_t offset, size_t count, float4 *src ) __FAST_CALL;
    typedef event_t (*__Write_array_2d_fi_transposed) ( const __ImageExecInfo *, size_t x, size_t y, size_t count,     
                                const float4 *r, const float4 *g,  const float4 *b, const float4 *a )   __FAST_CALL;
    typedef event_t (*__Read_array_2d_ff_transposed)( const __ImageExecInfo *i, float4 start, float4 stride, size_t offset, size_t count, 
                                                    float4 *r, float4 *g, float4 *b, float4 *a ) __FAST_CALL;
    
    // Used by clEnqueueFillImage, but utilizes routines in the read_image implementation:
    typedef void (*__Cvt_pixel)( const void*, void*, const float4* constants ) __FAST_CALL;

#ifdef AVX_IMAGE_AUTOVEC_BRINGUP
    typedef float32 (*__Read8_2d_ff)( const __ImageExecInfo *, float8 x, float8 y ) __FAST_CALL;
    typedef float32 (*__Read8_2d_fi)( const __ImageExecInfo *, int8 where ) __FAST_CALL;
    typedef void (*__Write8_2d_fi)( float8 r, float8 g, float8 b, float8 a, const __ImageExecInfo *i, int4 where ) __FAST_CALL;
    typedef event_t (*__Write8_array_2d_fi_transposed) ( const __ImageExecInfo *, size_t x, size_t y, size_t count,     
                                const float8 *r, const float8 *g,  const float8 *b, const float8 *a ) __FAST_CALL;
#endif

    #define READ_TABLE_SIZE  (1<< __CLK_SAMPLER_BITS)
    #define WRITE_TABLE_SIZE (1<< __CLK_VALID_IMAGE_TYPE_MASK_BITS )

    typedef struct __ImageFuncTableTransposed
    {
        __Read_1d_ff    read_1d_ff[READ_TABLE_SIZE];
        __Read_2d_fi    read_2d_fi[READ_TABLE_SIZE];
        __Read_2d_ff    read_2d_ff[READ_TABLE_SIZE];
        __Read4_2d_ff   read4_2d_ff[READ_TABLE_SIZE];
#ifdef AVX_IMAGE_AUTOVEC_BRINGUP
        __Read8_2d_ff   read8_2d_ff[READ_TABLE_SIZE];
#endif
        __Read_3d_fi    read_3d_fi[READ_TABLE_SIZE];
        __Read_3d_ff    read_3d_ff[READ_TABLE_SIZE];
        __Read4_3d_ff   read4_3d_ff[READ_TABLE_SIZE];
        
        __Read_1d_arr_ff read_1d_arr_ff[READ_TABLE_SIZE];
        __Read_2d_arr_fi read_2d_arr_fi[READ_TABLE_SIZE];
        __Read_2d_arr_ff read_2d_arr_ff[READ_TABLE_SIZE];
        
        __Write_2d_fi   write_2d_fi;
        __Write4_2d_fi  write4_2d_fi;
#ifdef AVX_IMAGE_AUTOVEC_BRINGUP
        __Write8_2d_fi  write8_2d_fi;
#endif
        __Write_3d_fi   write_3d_fi;
        __Read_array_2d_ff_transposed  read_array_2d_ff_transposed[READ_TABLE_SIZE];
        __Write_array_2d_fi_transposed write_array_2d_ff_transposed;
#ifdef AVX_IMAGE_AUTOVEC_BRINGUP
        __Write8_array_2d_fi_transposed write8_array_2d_ff_transposed;
#endif

        __Read_2d_ii    read_2d_ii[READ_TABLE_SIZE];
        __Read_2d_if    read_2d_if[READ_TABLE_SIZE];
        __Read_3d_ii    read_3d_ii[READ_TABLE_SIZE];
        __Read_3d_if    read_3d_if[READ_TABLE_SIZE];
        
        __Read_2d_arr_ii read_2d_arr_ii[READ_TABLE_SIZE];
        __Read_2d_arr_if read_2d_arr_if[READ_TABLE_SIZE];
        
        __Write_2d_ii   write_2d_ii;
        __Write_3d_ii   write_3d_ii;

        __Read_2d_ui    read_2d_ui[READ_TABLE_SIZE];
        __Read_2d_uf    read_2d_uf[READ_TABLE_SIZE];
        __Read_3d_ui    read_3d_ui[READ_TABLE_SIZE];
        __Read_3d_uf    read_3d_uf[READ_TABLE_SIZE];
        
        __Read_2d_arr_ui read_2d_arr_ui[READ_TABLE_SIZE];
        __Read_2d_arr_uf read_2d_arr_uf[READ_TABLE_SIZE];
        
        __Write_2d_ui   write_2d_ui;
        __Write_3d_ui   write_3d_ui;
        __Cvt_pixel     cvt_pixel;

    }__ImageFuncTableTransposed;

    typedef struct __ImageFuncTable
    {
        __Read4_2d_ff   read4_2d_ff[READ_TABLE_SIZE];
#ifdef AVX_IMAGE_AUTOVEC_BRINGUP
        __Read8_2d_ff   read8_2d_ff[READ_TABLE_SIZE];
#endif
        __Read4_3d_ff   read4_3d_ff[READ_TABLE_SIZE];
        __Write4_2d_fi  write4_2d_fi;
#ifdef AVX_IMAGE_AUTOVEC_BRINGUP
        __Write8_2d_fi  write8_2d_fi;
#endif
        __Read_array_2d_ff  read_array_2d_ff[READ_TABLE_SIZE];
        __Write_array_2d_fi write_array_2d_ff;
    }__ImageFuncTable;
        
        
#endif  /* __CL_TYPES_DEFINED__ */
#endif /* __CL_KERNEL_SHARED_H__ */
