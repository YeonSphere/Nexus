cmake_minimum_required(VERSION 3.10)
project(NexusBrowser)

set(CMAKE_CXX_STANDARD 17)

# Include directories
include_directories(include)

# Add the path to the cmake directory
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
message(STATUS "CMAKE_MODULE_PATH: ${CMAKE_MODULE_PATH}")
message(STATUS "TensorFlow include directory: ${TENSORFLOW_INCLUDE_DIR}")
message(STATUS "TensorFlow libraries: ${TENSORFLOW_LIBRARIES}")


# Find TensorFlow
find_package(TensorFlow REQUIRED)

# Add executable
add_executable(NexusBrowser 
  src/main.cpp 
  src/renderer/HtmlParser.cpp 
  src/renderer/CssParser.cpp 
  src/renderer/Renderer.cpp 
  src/ui/Navigation.cpp 
  src/ui/TabManager.cpp 
  src/ui/Settings.cpp 
  src/ui/Bookmarks.cpp 
  src/ui/Downloads.cpp 
  src/AdBlocker.cpp 
  src/AIEngine.cpp 
  src/ExtensionManager.cpp
)

# Link TensorFlow
target_include_directories(NexusBrowser PRIVATE ${TENSORFLOW_INCLUDE_DIRS})
target_link_libraries(NexusBrowser PRIVATE ${TENSORFLOW_LIBRARIES})
