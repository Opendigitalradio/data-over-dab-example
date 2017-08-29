cmake_minimum_required(VERSION 3.1.2)
project("DataOverDAB"
  LANGUAGES CXX
  VERSION 1.0.1)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/products/bin" CACHE PATH "" FORCE)

string(TOUPPER ${PROJECT_NAME} ${PROJECT_NAME}_UPPER)
string(TOLOWER ${PROJECT_NAME} ${PROJECT_NAME}_LOWER)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/modules")

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/config/Base.cmake")
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/config/Options.cmake")
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/config/Dependencies.cmake")

include_directories("include")

add_subdirectory("src")
