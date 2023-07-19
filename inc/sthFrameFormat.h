#pragma once

/**
 * @file sthFrameFormat.h
 * @copyright Copyright 2022 7thSense Design Ltd. All rights reserved.
 * @brief File containing 7th image frame format structures and helper function
 *
 */

#include "sthFileImportExportApi.h"

#include <stdint.h>

/**
 * @brief Basic colour model, indicating the number of colour primaries/channels/axes encoded in the image
 * Any colourimetric variation, such as the chromaticity co-ordinates of the primaries and white point are not encoded here.
 * Additional colourspace information is may possibly inferred by the channel_format field in SthFrameFormat.
 */
enum SthColourspace
{
    SthColourspace_RGB,             /**< Red, Green, Blue */
    SthColourspace_RGBA,            /**< Red, Green, Blue, Alpha */
    SthColourspace_YCbCr_ITU_T871,  /**< Y (luma), Cb (chroma blue), Cr (chroma red). Modified Rec. 601 Y′CbCr where Y′, CB and CR have the full 8-bit range of [0...255]. See ITU-T-REC-T.871 */
    SthColourspace_YCbCrA_ITU_T871, /**< Y (luma), Cb (chroma blue), Cr (chroma red). Modified Rec. 601 Y′CbCr where Y′, CB and CR have the full 8-bit range of [0...255], plus Alpha. See ITU-T-REC-T.871 */
    SthColourspace_YCoCg,           /**< Y (luma), Co (chroma orange), Cg (chroma green) */
    SthColourspace_YCoCgA           /**< Y (luma), Co (chroma orange), Cg (chroma green) */
};

/**
 * @brief Indicates the (uncompressed) range of the data stored for each channel
 */

enum SthChannelType
{
    SthChannelType_U8,  /**< 8-bit range unsigned integer */
    SthChannelType_U10, /**< 10-bit range unsigned integer */
    SthChannelType_U12, /**< 12-bit range unsigned integer */
    SthChannelType_U16, /**< 16-bit range unsigned integer */
    SthChannelType_F32  /**< 32-bit single precision float */
};

/**
 * @brief Indicates the integral ratio of bytes/samples/pixels.
 * 
 * For instance, for internal (not writable to 7th file) formats:
 * ```
 *    SthPixelPacking packing { .bytes = 3,  .samples = 3, .pixel_rows = 1, .pixel_cols = 1 }; // could represent RGB or 4:4:4 YCbCr, 8-bits per channel
 *    SthPixelPacking packing { .bytes = 4,  .samples = 4, .pixel_rows = 1, .pixel_cols = 1 }; // could represent RGBA or 4:4:4 YCbCrA, 8-bits per channel
 *    SthPixelPacking packing { .bytes = 8,  .samples = 4, .pixel_rows = 1, .pixel_cols = 1 }; // could represent RGBA, 16-bits per channel
 *    SthPixelPacking packing { .bytes = 16, .samples = 4, .pixel_rows = 1, .pixel_cols = 1 }; // could represent RGBA, 32-bit single precision float per channel
 * ```
 * For external (writable to 7th file) formats:
 * ```
 *    SthPixelPacking packing { .bytes = 9, .samples = 6, .pixel_rows = 1, .pixel_cols = 2 }; // could represent 12-bit packed RGB (36 bits per pixel, or 9 bytes per pixel pair).
 *    SthPixelPacking packing { .bytes = 5, .samples = 4, .pixel_rows = 1, .pixel_cols = 2 }; // could represent 10-bit packed 4:2:2 YCbCr (20 bits per pixel, or 5 bytes per pixel pair).
 * ```
 */
struct SthPixelPacking
{
    uint32_t bytes;       /**< Total number of bytes per indivisible pixel "block" */
    uint32_t samples;     /**< Total number of channel samples per indivisible pixel "block" */
    uint32_t pixel_rows;  /**< Number of pixel rows present per indivisible pixel "block" */
    uint32_t pixel_cols;  /**< Number of pixel colums present per indivisible pixel "block" */
};

/**
 * @brief Describes the overall format and pixel structure of the image frame.
 * Contains the colourspace, bit depth (per channel, when uncompressed) and channel format/ordering.
 * 
 * The channel format channel_format can describe channel ordering and/or type of packing/planar format
 * and is a freeform character buffer for maximum flexibility and to account for the non-overlapping variation
 * in the permissible formats for different bit depths and colourspaces etc. 
 * 
 * e.g.
 * 
 * * RGB frames can have channel_format of `"RGB"` or `"BGR"`
 * * RGBA frames can be `"RGBA"`, `"BGRA"`, `"ARGB"`, or `"ABGR"`
 * * YCbCr 4:2:2 frames can be `"YUYV-422"` or `"7TH-422"`, ...
 * * RGB 12-bit packed SMPTE-2110 is `"RGB-SMPTE-2110"`
 */
struct SthFrameFormat
{
    enum SthColourspace colourspace;        /**< Enum indicating number of colour primaries/channel */
    enum SthChannelType channel_type;       /**< Enum indicating numeric range of each colour channel */
    struct SthPixelPacking pixel_packing;   /**< Struct containing pixel layout and packing of the image frame */
    char channel_format[256];               /**< Freeform character buffer which should uniquely describe further layout/packing details pertaining to specific format requirements */
};

/**
 * @brief Populate SthFrameFormat struct from set of pre-defined strings
 *
 * @param[in, out] format A valid pointer to a SthFrameFormat. The contents will be overwritten by this function.
 * @param[in] format_identifier A recognised short-hand string which uniquely identifies a frame format.
 * The SthFrameFormat struct pointed to by format is then populated according to the predefined properties associated with the short-hand string.
 * 
 * If the format_identifier does not correspond to a recognised short-hand string, the function will fail.
 * 
 * Short-hand strings are of the form `"<colourspace>_<channel_type>_<channel_format>"` as per the SthFrameFormat components.
 * 
 * Recognised short-hand strings are:
 * 
 * * `"RGBA_U16_BGRA"`
 * This short-hand string describes a RGBA colourspace format, each channel 16-bit unsigned integer, in BGRA channel order
 * 
 * * `"RGBA_F32_BGRA"`
 * This short-hand string describes a RGBA colourspace format, each channel 32-bit float, in BGRA channel order
 * 
 * * `"RGB_U12_RGB-SMPTE-2110"`
 * This short-hand string describes a RGB colourspace format, each channel has 12-bit unsigned integer range, bit-packed according to SMPTE 2110 in RGB channel order
 * 
 * * `"YCbCr_ITU_T871_U10_7TH-422"`
 * This short-hand string describes a YCbCr colourspace format, according to ITU T871, 4:2:2 chroma-subsampled, each sample with 10-bit unsigned integer range, bit-packed in 7th format
 * 
 * @return int 0 on success, -1 on failure. Error description may be retrievable by calling sth_frame_format_populate_get_error().
 * @sa sth_frame_format_populate_get_error()
 */
STHFILEIMPORTEXPORTAPI int sth_frame_format_populate(struct SthFrameFormat* format, const char* format_identifier);

/**
 * @brief Get description of last SthFrameFormat population error
 *
 * Returns description of the last error that occurred when calling sth_frame_format_populate to populate a SthFrameFormat struct from a pre-defined string.
 *
 * @return A pointer to zero-terminated string.
 * @sa sth_frame_format_populate()
 */
STHFILEIMPORTEXPORTAPI const char* sth_frame_format_populate_get_error();
