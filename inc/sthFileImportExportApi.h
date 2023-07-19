#pragma once

/**
 * @file sthFileImportExportApi.h
 * @copyright Copyright 2022 7thSense Design Ltd. All rights reserved.
 * @brief File containing shared object/DLL and C linkage defintions
 *
 */

#ifdef __cplusplus
  #define STHFILEIMPORTEXPORTAPI_EXTERNC extern "C"
#else
  #define STHFILEIMPORTEXPORTAPI_EXTERNC
#endif

#ifdef _WIN32
  #ifdef BUILD_STHFILEIMPORTEXPORT
    #define STHFILEIMPORTEXPORTAPI STHFILEIMPORTEXPORTAPI_EXTERNC __declspec(dllexport)
  #else
    #define STHFILEIMPORTEXPORTAPI STHFILEIMPORTEXPORTAPI_EXTERNC __declspec(dllimport)
  #endif
#else
  #define STHFILEIMPORTEXPORTAPI STHFILEIMPORTEXPORTAPI_EXTERNC
#endif
