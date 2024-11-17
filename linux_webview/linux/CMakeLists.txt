cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "linux_webview")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "${PROJECT_NAME}_plugin")

# Define where to find the Flutter Linux files
if(NOT DEFINED FLUTTER_LINUX_DIR)
  set(FLUTTER_LINUX_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../flutter/ephemeral")
endif()

# Get the Flutter Linux engine path
if(NOT DEFINED FLUTTER_ENGINE_DIR)
  set(FLUTTER_ENGINE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../flutter/ephemeral/flutter_linux")
endif()

# Find required packages
find_package(PkgConfig REQUIRED)
pkg_check_modules(WEBKIT REQUIRED IMPORTED_TARGET webkit2gtk-4.0)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)

list(APPEND FLUTTER_LIBRARY_DIRS "${FLUTTER_LINUX_DIR}")
list(APPEND FLUTTER_LIBRARY_DIRS "${FLUTTER_ENGINE_DIR}")

add_library(${PLUGIN_NAME} SHARED
  "linux_webview_plugin.cc"
)

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_include_directories(${PLUGIN_NAME} PRIVATE
  "${FLUTTER_LINUX_DIR}"
  "${FLUTTER_ENGINE_DIR}"
)

# Link against imported targets
target_link_libraries(${PLUGIN_NAME} PRIVATE
  PkgConfig::GTK
  PkgConfig::WEBKIT
)

# Add Flutter library directories
target_link_directories(${PLUGIN_NAME} PRIVATE
  ${FLUTTER_LIBRARY_DIRS}
)

# Link against Flutter libraries
target_link_libraries(${PLUGIN_NAME} PRIVATE
  flutter
  flutter_wrapper_plugin
)

set(linux_webview_bundled_libraries
  ""
  PARENT_SCOPE)
