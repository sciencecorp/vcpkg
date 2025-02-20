vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    tests           WITH_TESTS
)

# Clone repo, then manually download submodules
#   See https://github.com/microsoft/vcpkg/issues/1036#issuecomment-299608663
vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO sciencecorp/synapse-cpp
	REF a29b1a5daee8ac6b980180eee7e49d94a29f64d5
	SHA512 fcf2dc21147fe8861c404f9bc87c794f8756c66452f706c4b9335224d056332ce28eb18eb56433caf7167a6d12d0a2c3d57423d38e032405cae79d33bfb9479f
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
