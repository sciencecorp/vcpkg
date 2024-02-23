vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bji/libs3 # original contributer fork of ceph/libs3 (dead)
    SHA512 "3d2604daf1504eea67c39636ecef002761db8b5f175d9c05ae230b4d1b0a78c76d5b3aa5bb52deeba0b9e4b86d75284515c0bec0bc9c6ef2fa31cce91dee8f00"
    REF "287e4bee6fd430ffb52604049de80a27a77ff6b4"
    HEAD_REF master
    PATCHES
)


# SKIP_CONFIGURE is broken
# https://github.com/microsoft/vcpkg/issues/14389
# https://github.com/microsoft/vcpkg/pull/31150/files#diff-fc2d1983b84c8b4510ea06cc300599a3cb9a68bd1f0d517f6f78150abf85def3
file(COPY "${CMAKE_CURRENT_LIST_DIR}/configure" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_get_vars(cmake_vars_file)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    COPY_SOURCE
)


if (VCPKG_TARGET_IS_OSX)
    set(makefile "GNUmakefile.osx")
elseif (VCPKG_TARGET_IS_LINUX)
    set(makefile "GNUmakefile")
endif()

vcpkg_build_make(
    BUILD_TARGET "exported"
    MAKEFILE ${makefile}
    LOGFILE_ROOT "build"
)

file(INSTALL "${SOURCE_PATH}/inc/" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.h")

set(BUILD_DIR_RELEASE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/build")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(INSTALL "${BUILD_DIR_RELEASE}/lib/libs3.a" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
else()
  file(INSTALL "${BUILD_DIR_RELEASE}/lib/libs3.so" DESTINATION "${CURRENT_PACKAGES_DIR}/lib" FOLLOW_SYMLINK_CHAIN)
endif()


set(BUILD_DIR_DEBUG "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/build")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(INSTALL "${BUILD_DIR_DEBUG}/lib/libs3.a" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
else()
  file(INSTALL "${BUILD_DIR_DEBUG}/lib/libs3.so" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib" FOLLOW_SYMLINK_CHAIN)
endif()


vcpkg_fixup_pkgconfig()


vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/LICENSE")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
