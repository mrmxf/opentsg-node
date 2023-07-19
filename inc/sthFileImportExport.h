#pragma once

/**
 * @file sthFileImportExport.h
 * @copyright Copyright 2022 7thSense Design Ltd. All rights reserved.
 * @brief File containing library global initialization/deinitialization functions
 *
 */

#include "sthFileImportExportApi.h"

/**
 * @brief Initializes the sthFileImportExport library.
 *
 * Must be called before using any other functionality in the library.
 * Can be called by any thread.
 *
 * @return A handle to the library state on success, null on failure. Error description may be retrievable by calling sth_file_import_export_get_error().
 * @sa sth_file_import_export_get_error()
 */
STHFILEIMPORTEXPORTAPI void* sth_file_import_export_create();

/**
 * @brief Deinitializes the sthFileImportExport library.
 *
 * Frees any memory that the library allocated internally while in use.
 * Memory allocated with either sth_image_frame_create() or sth_file_importer_read_frame() must still be explicitly freed first with sth_image_frame_destroy().
 * 
 * @param[in] import_export_state A valid handle to the library state.
 * @return int 0 on success, -1 on failure. Error description may be retrievable by calling sth_file_import_export_get_error().
 * @sa sth_image_frame_create(), sth_file_importer_read_frame(), sth_image_frame_destroy(), sth_file_import_export_get_error()
 */
STHFILEIMPORTEXPORTAPI int sth_file_import_export_destroy(void* import_export_state);

/**
 * Get description of last error
 *
 * Returns description of the last error that occurred during library initialization/deinitialization.
 *
 * @return A pointer to zero-terminated string.
 */
STHFILEIMPORTEXPORTAPI const char* sth_file_import_export_get_error();

/**
 * Get sthFileImportExport library version
 *
 * Returns version of this library in the form "x.y.z [Beta]" where:
 *   - x is major version number
 *   - y is minor version number
 *   - z is build number
 *   - Beta is an optional field, indicating production release status
 *
 * @param[in] import_export_state A valid handle to the library state.
 * @return A pointer to zero-terminated string.
 */
STHFILEIMPORTEXPORTAPI const char* sth_file_import_export_get_version(void* import_export_state);

/**
 * Get sthFileImportExport library build date
 *
 * Returns build date of this library in the form "yyyy mm dd" where
 *
 * @param[in] import_export_state A valid handle to the library state.
 * @return A pointer to zero-terminated string.
 */
STHFILEIMPORTEXPORTAPI const char* sth_file_import_export_get_date(void* import_export_state);

/**
 * Get sthFileImportExport library build unique identifier
 *
 * Returns build id of this library.
 * Used for customer support purposes.
 *
 * @param[in] import_export_state A valid handle to the library state.
 * @return A pointer to zero-terminated string.
 */
STHFILEIMPORTEXPORTAPI const char* sth_file_import_export_get_fingerprint(void* import_export_state);

/**
 * Get 7thSense MediaConversion library version
 *
 * Returns version of the MediaConversion library which provides the underlying functionality for the sthFileImportExport shared library.
 * The library version is in the form "x.y.z [Beta]" where:
 *   - x is major version number
 *   - y is minor version number
 *   - z is build number
 *   - Beta is an optional field, indicating production release status
 *
 * @param[in] import_export_state A valid handle to the library state.
 * @return A pointer to zero-terminated string.
 */
STHFILEIMPORTEXPORTAPI const char* sth_file_import_export_get_mcl_version(void* import_export_state);
