#pragma once

/**
 * @file sthImageFrame.h
 * @copyright Copyright 2022 7thSense Design Ltd. All rights reserved.
 * @brief File containing 7th image frame allocation/deallocation functions
 *
 */

#include "sthFrameFormat.h"

/**
 * @brief Describes the structure of the image frame.
 * Allows access to the raw pixel data, and stores image properties such as height (rows), width (columns)
 * and the pixel format (in the SthFrameFormat format field)
 */
struct SthImageFrame
{
    unsigned char * pixel_buffer;           /**< Pixel buffer data pointer */
    unsigned long pixel_buffer_size_bytes;  /**< Size of the pixel buffer in bytes */
    struct SthFrameFormat frame_format;     /**< The frame format of the image held in the pixel buffer @sa SthFrameFormat */
    int rows;                               /**< The number of rows (height) in the displayable image (not the number of rows after any chroma-sampling for instance) */
    int cols;                               /**< The number of columns (width) in the displayable image (not the number of columns after any chroma-sampling for instance) */
    int step_bytes;                         /**< Number of bytes each image row occupies, including padding bytes. 0 if the image pixel data is contiguous */
    void * image_frame_state_reserved;      /**< For internal use by the library only. Must be set to 0 otherwise. */
};

/**
 * @brief Allocates an image frame
 *
 * The library must be initialized with sth_file_import_export_create() before calling this function.
 * 
 * This function allocates the correct number of pixel bytes based on the format and number of rows and columns.
 * The SthImageFrame struct pointed to by frame is then populated accordingly.
 * 
 * Pixels are stored contiguously (there are no end-of-row padding bytes).
 * 
 * image_frame_state_reserved in the populated SthImageFrame will contain a handle for use by the library only.
 * 
 * Image frames allocated with this function must be freed with sth_image_frame_destroy().
 *
 * @param[in] format The frame format of the image to allocate
 * @param[in] rows The number of rows (height) in the displayable image (not the number of rows after any chroma-sampling for instance)
 * @param[in] cols The number of columns (width) in the displayable image (not the number of columns after any chroma-sampling for instance)
 * @param[in, out] frame A valid pointer to a SthImageFrame. The contents will be overwritten by this function.
 * @return int 0 on success, -1 on failure. Error description may be retrievable by calling sth_image_frame_get_errorsth_image_frame_get_error().
 * @sa sth_image_frame_destroy(), sth_image_frame_get_error()
 */
STHFILEIMPORTEXPORTAPI int sth_image_frame_create(struct SthFrameFormat* format, int rows, int cols, struct SthImageFrame* frame);

/**
 * @brief Deallocates an image frame
 *
 * The image frame must have been allocated with sth_image_frame_create() before calling this function
 *
 * @param[in, out] frame A valid pointer to a SthImageFrame. The contents will be invalidated by this function.
 * @return int 0 on success, -1 on failure. Error description may be retrievable by calling sth_image_frame_get_error().
 * @sa sth_image_frame_create(), sth_image_frame_get_error()
 */
STHFILEIMPORTEXPORTAPI int sth_image_frame_destroy(struct SthImageFrame* frame);

/**
 * @brief Get description of last SthImageFrame allocation/error error
 *
 * Returns description of the last error that occurred when calling sth_image_frame_create() or sth_image_frame_destroy().
 *
 * @return A pointer to zero-terminated string.
 * @sa sth_image_frame_create(), sth_image_frame_destroy()
 */
STHFILEIMPORTEXPORTAPI const char* sth_image_frame_get_error();
