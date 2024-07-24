cmake_minimum_required(VERSION 3.10)
project(NexusBrowser)

set(CMAKE_CXX_STANDARD 17)

add_executable(NexusBrowser src/main.cpp src/renderer/html_parser.cpp src/renderer/css_parser.cpp src/renderer/renderer.cpp)
