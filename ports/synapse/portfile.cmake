vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    tests           WITH_TESTS
)

# Manually clone & checkout the repository, in order to init submodules
#   See https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_from_git.cmake
#       https://github.com/microsoft/vcpkg/issues/6886
set(URL "git@github.com:sciencecorp/synapse-cpp.git")
set(REF "58e0ae7fc8e964649e22f7ed210b766227794be0")
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${PORT})

if(NOT EXISTS "${SOURCE_PATH}/.git")
	file(REMOVE_RECURSE ${SOURCE_PATH})
	file(MAKE_DIRECTORY ${SOURCE_PATH})

	message(STATUS "Cloning repository")
	vcpkg_execute_required_process(
	  COMMAND ${GIT} clone ${URL} ${SOURCE_PATH}
	  WORKING_DIRECTORY ${SOURCE_PATH}
	  LOGNAME clone
	)

	message(STATUS "Checking out revision ${REF}")
	vcpkg_execute_required_process(
	  COMMAND ${GIT} checkout ${REF}
	  WORKING_DIRECTORY ${SOURCE_PATH}
	  LOGNAME checkout
	)

	message(STATUS "Fetching submodules")
	vcpkg_execute_required_process(
	  COMMAND ${GIT} submodule update --init --recursive
	  WORKING_DIRECTORY ${SOURCE_PATH}
	  LOGNAME submodule
	)

endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME synapse CONFIG_PATH lib/cmake/synapse)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/LICENSE")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
