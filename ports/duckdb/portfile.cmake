vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO duckdb/duckdb
    REF v${VERSION}
    SHA512 9f3f470aeaecc65506ec66183bef4b039cf2a23685ce8c876ce9862e9c5746e8150ace3d37acf167f15611f2bf078f85e8ed0b397397d7391fc044a75c59271a
)

# Set the build environment variables and configure options
vcpkg_cmake_configure(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            -DBUILD_UNITTESTS=OFF
            -DBUILD_SHELL=FALSE
            -DBUILD_EXTENSIONS=httpfs;json;parquet
            -DENABLE_EXTENSION_AUTOLOADING=1
            -DENABLE_EXTENSION_AUTOINSTALL=1
)
vcpkg_cmake_install()

if(EXISTS "${CURRENT_PACKAGES_DIR}/CMake")
    vcpkg_cmake_config_fixup(CONFIG_PATH CMake)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/DuckDB")
    vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/DuckDB")
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/${PORT}")
    vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/DuckDBConfig.cmake"
  [[set(DuckDB_INCLUDE_DIRS "${DuckDB_CMAKE_DIR}/include")]]

  [[get_filename_component(DuckDB_INCLUDE_DIRS "${DuckDB_CMAKE_DIR}" PATH)
    get_filename_component(DuckDB_INCLUDE_DIRS "${DuckDB_INCLUDE_DIRS}" PATH)
    set(DuckDB_INCLUDE_DIRS "${DuckDB_INCLUDE_DIRS}/include")]]
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/duckdb/storage/serialization")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

message(STATUS "Installed ${PORT} ${VERSION}")
