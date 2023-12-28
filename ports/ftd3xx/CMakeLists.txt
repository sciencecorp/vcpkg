cmake_minimum_required(VERSION 3.23)
project(ftd3xx)

option(BUILD_SHARED_LIBS "Build using shared libraries" ON)

if(APPLE)
    set(SHARED_LIB_NAME "libftd3xx.dylib")
else()
    set(SHARED_LIB_NAME "libftd3xx.so")
endif()

if(BUILD_SHARED_LIBS)
  set(LIB_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${SHARED_LIB_NAME}")
  add_library(ftd3xx SHARED IMPORTED)
else()
  set(LIB_PATH "${CMAKE_CURRENT_SOURCE_DIR}/libftd3xx-static.a")
  add_library(ftd3xx STATIC IMPORTED)
endif()

set_target_properties(ftd3xx PROPERTIES
    IMPORTED_LOCATION ${LIB_PATH}
    INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_CURRENT_SOURCE_DIR}
)

install(FILES ${LIB_PATH} DESTINATION lib)

# Install header files
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
        DESTINATION include/ftd3xx
        FILES_MATCHING PATTERN "*.h")

# Generate and install the package configuration file
configure_file(cmake/Config.cmake.in "${CMAKE_CURRENT_BINARY_DIR}/ftd3xxConfig.cmake" @ONLY)
configure_file(cmake/Targets.cmake.in "${CMAKE_CURRENT_BINARY_DIR}/ftd3xxTargets.cmake" @ONLY)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/ftd3xxConfig.cmake"
              "${CMAKE_CURRENT_BINARY_DIR}/ftd3xxTargets.cmake"
        DESTINATION share/ftd3xx
)
