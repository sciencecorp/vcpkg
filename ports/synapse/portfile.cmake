vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    cli             WITH_CLI
    tests           WITH_TESTS
)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL git@github.com:sciencecorp/synapse.git
    REF "01e5b21f52dba8c051431691af5370ccde1a25ce"
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSYNAPSE_BUILD_CLI=${WITH_CLI}
        -DSYNAPSE_BUILD_TESTS=${WITH_TESTS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME synapse CONFIG_PATH lib/cmake/synapse)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/LICENSE")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
