#pragma once

/**
 * @file sthFileImporter.h
 * @copyright Copyright 2022 7thSense Design Ltd. All rights reserved.
 * @brief File containing 7th file reader initialization/deinitialization functions, and frame read function
 *
 */

#include "sthFrameFormat.h"
#include "sthImageFrame.h"
#include "sthFileImportExportApi.h"

/**
 * @brief Initializes 7th format file importer functionality.
 *
 * The library must be initialized with sth_file_import_export_create() before calling this function.
 * sth_file_importer_create() must be called before attempting to read a file with sth_file_importer_read_frame()
 *
 * @param[in] destination_format The desired destination format that the 7th format file is converted to after being read in. Files which are stored as chroma-subsampled (YCbCr 4:2:2 or 4:2:0) or bit-packed 10-bit or 12-bit RGB
 * will typically be read and converted to an unpacked, uncompressed destination format, ready for use in the host software, e.g. RGB/BGR or RGBA/BGRA channels, and likely 16-bit unsigned integer or 32-bit float per channel.
 * @return A handle to the importer state on success, null on failure. Error description may be retrievable by calling sth_file_importer_get_error().
 * @sa sth_file_importer_read_frame(), sth_file_importer_get_error()
 */
STHFILEIMPORTEXPORTAPI void* sth_file_importer_create(const struct SthFrameFormat* destination_format);

/**
 * @brief Deinitializes 7th format file importer functionality.
 *
 * Frees any objects that the library allocated internally for import.
 * 
 * @param[in] importer_state A valid handle to the importer state.
 * @return int 0 on success, -1 on failure. Error description may be retrievable by calling sth_file_importer_get_error().
 * @sa sth_file_importer_get_error()
 */
STHFILEIMPORTEXPORTAPI int sth_file_importer_destroy(void* importer_state);

/**
 * @brief Get description of last importer initialization/deinitialization error
 *
 * Returns description of the last error that occurred during importer initialization/deinitialization.
 *
 * @return A pointer to zero-terminated string.
 * @sa sth_file_importer_create(), sth_file_importer_destroy()
 */
STHFILEIMPORTEXPORTAPI const char* sth_file_importer_get_error();

/**
 * @brief Read 7th format file from disk
 *
 * @param[in] importer_state A valid handle to the importer state.
 * @param[in] filename A valid file path. 7th format files should have the extension `.7th` or `.sth`
 * @param[in] destination_frame An image frame whose format matches the destination_format parameter passed to sth_file_exporter_create().
 * @return int 0 on success, -1 on failure. Error description may be retrievable by calling sth_file_importer_read_frame_get_error().
 * @sa sth_file_importer_create(), sth_file_importer_read_frame_get_error()
 */
STHFILEIMPORTEXPORTAPI int sth_file_importer_read_frame(void* importer_state, const char* filename, struct SthImageFrame* destination_frame);

/**
 * @brief Get description of last 7th file read error
 *
 * Returns description of the last error that occurred during reading a 7th file.
 *
 * @param[in] importer_state A valid handle to the importer state.
 * @return A pointer to zero-terminated string.
 * @sa sth_file_importer_read_frame()
 */
STHFILEIMPORTEXPORTAPI const char* sth_file_importer_read_frame_get_error(void* importer_state);
