vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL git@github.com:foxglove/mcap.git
    REF "f87352f0aaae81628bdd7ffc43f7563f6bd98547"
    HEAD_REF "main"
)

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
    DESTINATION "${SOURCE_PATH}")
file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/cmake/Config.cmake.in"
    DESTINATION "${SOURCE_PATH}/cmake")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
