cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "linux_webview")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "${PROJECT_NAME}_plugin")

find_package(PkgConfig REQUIRED)
pkg_check_modules(WEBKIT REQUIRED webkit2gtk-4.0)
pkg_check_modules(GTK REQUIRED gtk+-3.0)

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
  "${WEBKIT_INCLUDE_DIRS}"
  "${GTK_INCLUDE_DIRS}"
)

target_link_libraries(${PLUGIN_NAME} PRIVATE
  flutter
  flutter_wrapper_plugin
)

target_link_options(${PLUGIN_NAME} PRIVATE
  ${WEBKIT_LDFLAGS}
  ${GTK_LDFLAGS}
)

target_link_directories(${PLUGIN_NAME} PRIVATE
  ${WEBKIT_LIBRARY_DIRS}
  ${GTK_LIBRARY_DIRS}
)

# List of absolute paths to libraries that should be bundled with the plugin
set(linux_webview_bundled_libraries
  ""
  PARENT_SCOPE
)
