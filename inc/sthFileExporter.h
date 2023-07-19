#pragma once

/**
 * @file sthFileExporter.h
 * @copyright Copyright 2022 7thSense Design Ltd. All rights reserved.
 * @brief File containing 7th file writer initialization/deinitialization functions, and frame write function
 *
 */

#include "sthFrameFormat.h"
#include "sthImageFrame.h"
#include "sthFileImportExportApi.h"

/**
 * @brief Initializes 7th format file exporter functionality.
 *
 * The library must be initialized with sth_file_import_export_create() before calling this function.
 * sth_file_exporter_create() must be called before attempting to write a file with sth_file_exporter_write_frame()
 *
 * @param[in] source_format The expected format of image frames to be passed in for writing to file (using sth_file_exporter_write_frame())
 * @param[in] destination_format The desired format of the written 7th format file.
 * @return A handle to the exporter state on success, null on failure. Error description may be retrievable by calling sth_file_exporter_get_error().
 * @sa sth_file_exporter_write_frame(), sth_file_exporter_get_error()
 */
STHFILEIMPORTEXPORTAPI void* sth_file_exporter_create(const struct SthFrameFormat* source_format, const struct SthFrameFormat* destination_format);

/**
 * @brief Deinitializes 7th format file exporter functionality.
 *
 * Frees any objects that the library allocated internally for export.
 * 
 * @param[in] exporter_state A valid handle to the exporter state.
 * @return int 0 on success, -1 on failure. Error description may be retrievable by calling sth_file_exporter_get_error().
 * @sa sth_file_exporter_get_error()
 */
STHFILEIMPORTEXPORTAPI int sth_file_exporter_destroy(void* exporter_state);

/**
 * @brief Get description of last exporter initialization/deinitialization error
 *
 * Returns description of the last error that occurred during exporter initialization/deinitialization.
 *
 * @return A pointer to zero-terminated string.
 * @sa sth_file_exporter_create(), sth_file_exporter_destroy()
 */
STHFILEIMPORTEXPORTAPI const char* sth_file_exporter_get_error();

/**
 * @brief Write 7th format file to disk
 *
 * @param[in] exporter_state A valid handle to the exporter state.
 * @param[in] filename A valid file path. 7th format files should have the extension `.7th` or `.sth`
 * @param[in] source_frame An image frame whose format matches the source_format parameter passed to sth_file_exporter_create().
 * @return int 0 on success, -1 on failure. Error description may be retrievable by calling sth_file_exporter_write_frame_get_error().
 * @sa sth_file_exporter_create(), sth_file_exporter_write_frame_get_error()
 */
STHFILEIMPORTEXPORTAPI int sth_file_exporter_write_frame(void* exporter_state, const char* filename, const struct SthImageFrame* source_frame);

/**
 * @brief Get description of last 7th file write error
 *
 * Returns description of the last error that occurred during writing a 7th file.
 *
 * @param[in] exporter_state A valid handle to the exporter state.
 * @return A pointer to zero-terminated string.
 * @sa sth_file_exporter_write_frame()
 */
STHFILEIMPORTEXPORTAPI const char* sth_file_exporter_write_frame_get_error(void* exporter_state);
