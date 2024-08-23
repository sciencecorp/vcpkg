vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO duckdb/duckdb
    REF v${VERSION}
    HEAD_REF main
    SHA512 9f3f470aeaecc65506ec66183bef4b039cf2a23685ce8c876ce9862e9c5746e8150ace3d37acf167f15611f2bf078f85e8ed0b397397d7391fc044a75c59271a
)

vcpkg_check_features(
  OUT_FEATURE_OPTIONS D_BUILD_FLAGS
  FEATURES
    benchmark                 BUILD_BENCHMARK
    jdbc                      BUILD_JDBC
    odbc                      BUILD_ODBC
    python                    BUILD_PYTHON
    shell                     BUILD_SHELL
)

vcpkg_check_features(
  OUT_FEATURE_OPTIONS D_DEBUG_FLAGS
  FEATURES
    crash-on-assert           CRASH_ON_ASSERT
    debug-stacktrace          DEBUG_STACKTRACE
    destroy-unpinned-blocks   DESTROY_UNPINNED_BLOCKS
    disable-unity-build       DISABLE_UNITY
    disable-sanitizer         DISABLE_SANITIZER
    disable-memory-safety     DISABLE_MEMORY_SAFETY
    disable-string-inline     DISABLE_STRING_INLINE
)

vcpkg_check_features(
  OUT_FEATURE_OPTIONS D_EXTENSION_FLAGS
  FEATURES
    autocomplete              BUILD_AUTOCOMPLETE
    fts                       BUILD_FTS
    httpfs                    BUILD_HTTPFS
    icu                       BUILD_ICU
    inet                      BUILD_INET
    jemalloc                  BUILD_JEMALLOC
    json                      BUILD_JSON
    parquet                   BUILD_PARQUET
    sqlsmith                  BUILD_SQLSMITH
    tpch                      BUILD_TPCH
    tpcds                     BUILD_TPCDS
)

# Clean VCPKG feature flags
# Remove -D and convert ON to 1, add to out list
function(clean_flags in_list out_list)
    set(temp_list "")
    foreach(flag IN LISTS in_list)
        string(REGEX REPLACE "^-D" "" flag "${flag}")
        
        if(flag MATCHES "^(.+)=(.+)$")
            set(flag_name "${CMAKE_MATCH_1}")
            set(flag_value "${CMAKE_MATCH_2}")
            
            if(flag_value STREQUAL "ON")
                set(flag_value "1")
                list(APPEND temp_list "${flag_name}=${flag_value}")
            endif()
        endif()
    endforeach()
    
    set(${out_list} ${temp_list} PARENT_SCOPE)
endfunction()

clean_flags(${D_BUILD_FLAGS} BUILD_FLAGS)
clean_flags(${D_DEBUG_FLAGS} DEBUG_FLAGS)
clean_flags(${D_EXTENSION_FLAGS} EXTENSIONS)

set(OTHER_FLAGS)
list(APPEND OTHER_FLAGS "OVERRIDE_GIT_DESCRIBE=v${VERSION}")

# Recommended to disable vptr sanitizer on arm64-osx
# https://github.com/duckdb/duckdb/blob/f5ab7c167ee895ecc3fc2cd22b7443fcc60419a2/CMakeLists.txt#L189
if (TARGET_TRIPLET STREQUAL "arm64-osx")
    list(APPEND OTHER_FLAGS "DISABLE_SANITIZER=1")
endif()

# set the default number of rows to split query results into DataChunks to 1000
list(APPEND OTHER_FLAGS "STANDARD_VECTOR_SIZE=1000")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    COPY_SOURCE
    SKIP_CONFIGURE
)

# DuckDB build instructions
#
# https://duckdb.org/docs/dev/building/build_instructions
# https://duckdb.org/docs/dev/building/building_extensions
# 
# set the environment variables
# - GEN=ninja
# - BUILD_<flag>=1 (for all enabled build flags)
# - BUILD_<ext>=1 (for all enabled extensions)
# - <flag>=1 (for all enabled debug flags)
#
# then call `make <target>`, where target is 'release' or 'debug'
#
# this Makefile calls CMake under the hood to build files to build/release or build/debug
#
# Because duckdb does not recommend calling cmake configure / build directly,
#   bits of the following script were adapted from
#   https://github.com/microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_build_make.cmake
#   (make flags, build types, etc...)
#

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(BUILD_TARGET "debug")
else()
    set(BUILD_TARGET "release")
endif()

find_program(make_command make REQUIRED)

vcpkg_list(SET make_opts V=1 -j ${VCPKG_CONCURRENCY} -f Makefile)
z_vcpkg_configure_make_common_definitions()

vcpkg_list(SET no_parallel_make_opts V=1 -j 1 -f Makefile)

foreach(buildtype IN ITEMS "debug" "release")
    if (buildtype STREQUAL "debug" AND _VCPKG_MAKE_NO_DEBUG)
        continue()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "${buildtype}")
        string(TOUPPER "${buildtype}" cmake_buildtype)
        string(TOLOWER "${buildtype}" target)
        set(short_buildtype "${short_name_${cmake_buildtype}}")
        set(path_suffix "${path_suffix_${cmake_buildtype}}")

        set(ENV{GEN} "ninja")

        # Specify CMAKE_INSTALL_PREFIX to vcpkg's package directory
        #  via DuckDB's Makefile's COMMON_CMAKE_VARS
        #  which are passed to CMake via the Makefile
        #  https://github.com/duckdb/duckdb/blob/v1.0.0/Makefile
        vcpkg_list(SET make_vars)
        if (buildtype STREQUAL "debug")
            vcpkg_list(APPEND make_vars "COMMON_CMAKE_VARS=-DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug")
        else()
            vcpkg_list(APPEND make_vars "COMMON_CMAKE_VARS=-DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}")
        endif()
        
        # Configure and build

        set(working_directory ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_buildtype})
        file(MAKE_DIRECTORY "${working_directory}")

        vcpkg_list(SET make_args ${make_opts} ${target} ${make_vars} ${BUILD_FLAGS} ${DEBUG_FLAGS} ${EXTENSIONS} ${OTHER_FLAGS})
        vcpkg_list(SET no_parallel_make_args ${no_parallel_make_opts} ${target} ${make_vars} ${BUILD_FLAGS} ${DEBUG_FLAGS} ${EXTENSIONS} ${OTHER_FLAGS})
        vcpkg_execute_build_process(
            COMMAND ${make_command} ${make_args}
            NO_PARALLEL_COMMAND ${no_parallel_make_args}
            WORKING_DIRECTORY ${working_directory}
            LOGNAME "build-${TARGET_TRIPLET}-${short_buildtype}"
        )

        set(build_path "${working_directory}/build/${target}")

        # Register extensions

        message(STATUS "Installing extensions")
        foreach(ext_flag IN ITEMS ${EXTENSIONS})
            string(REGEX REPLACE "^BUILD_([^=]+).*$" "\\1" ext_name "${ext_flag}")
            string(REGEX REPLACE "^BUILD_[^=]+=(.*)$" "\\1" ext_value "${ext_flag}")
            string(TOLOWER ${ext_name} ext_name)

            if(${ext_value})
                string(TOLOWER ${ext_name} ext_name)
                message(STATUS "- installing ${ext_name} extension")

                set(ext_path "${build_path}/extension/${ext_name}/${ext_name}.duckdb_extension")

                # duckdb -c "INSTALL 'extension/<ext>/<ext>.duckdb_extension'
                vcpkg_execute_build_process(
                    COMMAND "${build_path}/duckdb" -c "INSTALL '${ext_path}';"
                    WORKING_DIRECTORY "${working_directory}"
                    LOGNAME "register-extensions-${TARGET_TRIPLET}-${short_buildtype}"
                )
            endif()
        endforeach()

        # Install build
      
        vcpkg_execute_build_process(
            COMMAND
                "${CMAKE_COMMAND}" --build . --target install 
            NO_PARALLEL_COMMAND
                "${CMAKE_COMMAND}" --build . --target install
            WORKING_DIRECTORY "${build_path}"
            LOGNAME "install-${TARGET_TRIPLET}-${short_buildtype}"
        )

    endif()
endforeach()

# Clean up installation
vcpkg_cmake_config_fixup(
  PACKAGE_NAME duckdb
  CONFIG_PATH lib/cmake/DuckDB
)
# Remove empty dirs
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/duckdb/storage/serialization")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# License
vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE)

# Usage
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
