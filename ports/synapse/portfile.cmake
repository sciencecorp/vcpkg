vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    tests           WITH_TESTS
)

# Clone repo, then manually download submodules
#   See https://github.com/microsoft/vcpkg/issues/1036#issuecomment-299608663
vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO sciencecorp/synapse-cpp
	REF b3ca9935a212c81598569a995268f53c21ccb67b
	SHA512 adb5f0392d2cd0cb56f75c03c5e34fcb26b67d050c83d45270ca21c2fd6702381b600c52f1494ad4b93d891305989a5c4684b2034a676a6962e75ea7a7068940
)

vcpkg_download_distfile(API_ARCHIVE
	URLS "https://github.com/sciencecorp/synapse-api/archive/22f14a204e007fbbb7695aea84c344b41f5b47dc.zip"
	FILENAME "synapse-api.zip"
	SOURCE_BASE "synapse-api"
	SHA512 1d454948e589e48a8ffd8277d72426a2fb077789f62000f2361a177ded2892e733e410064f2ceadc46ad9f954081d9479b602c95a2d64db6e40617b813f0ccd2
)

vcpkg_extract_source_archive(
	SOURCE_PATH_ARCHIVE
	ARCHIVE ${API_ARCHIVE}
)

file(RENAME "${SOURCE_PATH_ARCHIVE}" "${SOURCE_PATH}/external/sciencecorp/synapse-api")

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME synapse CONFIG_PATH lib/cmake/synapse)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/LICENSE")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
