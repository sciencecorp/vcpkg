vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    cli             WITH_CLI
    tests           WITH_TESTS
)

# Manually clone & checkout the repository, in order to init submodules
#   See https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_from_git.cmake
#       https://github.com/microsoft/vcpkg/issues/6886
set(URL "git@github.com:sciencecorp/synapse-client-cpp.git")
set(REF "18bd27767aa0c8a15d1f450ebdd09642bd60a0ea")
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${PORT})

if(NOT EXISTS "${SOURCE_PATH}/.git")
    file(REMOVE_RECURSE ${SOURCE_PATH})
    file(MAKE_DIRECTORY ${SOURCE_PATH})

	message(STATUS "Cloning and fetching submodules")
	vcpkg_execute_required_process(
	  COMMAND ${GIT} clone --recurse-submodules ${URL} ${SOURCE_PATH}
	  WORKING_DIRECTORY ${SOURCE_PATH}
	  LOGNAME clone
	)

	message(STATUS "Checkout revision ${GIT_REV}")
	vcpkg_execute_required_process(
	  COMMAND ${GIT} checkout ${REF}
	  WORKING_DIRECTORY ${SOURCE_PATH}
	  LOGNAME checkout
	)
endif()

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
