vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    tests           WITH_TESTS
)

# Clone repo, then manually download submodules
#   See https://github.com/microsoft/vcpkg/issues/1036#issuecomment-299608663
vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO sciencecorp/synapse-cpp
	REF 5171f599f1b33d55f3b402ddc4c7fdd467287913
	SHA512 52f2ace26e21d5a81fb8bfcda91eea4ca374297fdd76d35d53d835d252ab320874c81ac1504fcfc511bad05614cf75f43acbc6ff148ded959c6a3bd0947ba844
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
