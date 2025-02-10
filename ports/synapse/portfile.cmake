vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    tests           WITH_TESTS
)

# Clone repo, then manually download submodules
#   See https://github.com/microsoft/vcpkg/issues/1036#issuecomment-299608663
vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO sciencecorp/synapse-cpp
	REF 80eb3f56f9b11c0ec8a17cb23ffc2a200b1ef08b
	SHA512 4722eafe59993bf3d174cafd523cb4b20b84d75d233f38ea9e5fdadc02d2a5af0676098b49f411aeaada5900482696ccdf10a47a8cdd6dc75d46cc4f5a9ac9ae
)

vcpkg_download_distfile(API_ARCHIVE
	URLS "https://github.com/sciencecorp/synapse-api/archive/6b02951bcad82241719853487eceebe78eb6835f.zip"
	FILENAME "synapse-api.zip"
	SOURCE_BASE "synapse-api"
	SHA512 d049339e09954ff8274870f61cb39b8227e960414f8762c047a55bc36439eb5ab76d0d25e3fd5a2be2d16ef7e0b87906304042c1d26830769893846370f0dbfb
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
