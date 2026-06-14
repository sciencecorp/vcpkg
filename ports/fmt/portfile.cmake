# Overlay of the builtin fmt port (vcpkg baseline e590c2b3, version 11.0.2).
# Identical to upstream EXCEPT that the Android triplet additionally applies a
# one-line backport of fmtlib/fmt#4177 so fmt's compile-time format-string
# checking compiles under NDK Clang 21 (the builtin 11.0.2 + Clang 19+ hits
# "call to consteval function ... is not a constant expression"). The patch is
# applied ONLY on the android triplet, so Linux/other triplets resolve byte-
# identical to the builtin port.
set(PATCHES fix-write-batch.patch)
if(TARGET_TRIPLET MATCHES "android")
    list(APPEND PATCHES fix-clang-consteval.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fmtlib/fmt
    REF "${VERSION}"
    SHA512 47ff6d289dcc22681eea6da465b0348172921e7cafff8fd57a1540d3232cc6b53250a4625c954ee0944c87963b17680ecbc3ea123e43c2c822efe0dc6fa6cef3
    HEAD_REF master
    PATCHES
        ${PATCHES}
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFMT_CMAKE_DIR=share/fmt
        -DFMT_TEST=OFF
        -DFMT_DOC=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/fmt/base.h"
        "defined(FMT_SHARED)"
        "1"
    )
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
