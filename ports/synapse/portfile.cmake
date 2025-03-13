vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    tests           WITH_TESTS
)

# Clone repo, then manually download submodules
#   See https://github.com/microsoft/vcpkg/issues/1036#issuecomment-299608663
vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO sciencecorp/synapse-cpp
	REF da0daa82a4b8db901e4603145f4a5aac78925077
	SHA512 a6955142d35fbc3c67eed3053468113048ec5a8d186c29e74e9c26af03ae71377d20f0535dead266b5b89c99e879daf60cb7a1aa9faeff70d9a67797e75c67a8
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
