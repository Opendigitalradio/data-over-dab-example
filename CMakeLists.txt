cmake_minimum_required(VERSION 3.1.2)
project("DataOverDAB"
  LANGUAGES CXX
  VERSION 1.0.1)

string(TOUPPER ${PROJECT_NAME} ${PROJECT_NAME}_UPPER)
string(TOLOWER ${PROJECT_NAME} ${PROJECT_NAME}_LOWER)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/products/bin" CACHE PATH "" FORCE)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/modules")
set(CXX_VERSION "c++14")
include("CompilerSetup")
include("ConanPackages")
install_conan_packages(SYSTEM_HEADERS)

include_directories("include")

add_subdirectory("src")
