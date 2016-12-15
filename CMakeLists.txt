cmake_minimum_required(VERSION 2.8)

# Setup generic project properties
project(dabdata_example CXX)
add_definitions(-DASIO_STANDALONE)

# Set general compiler flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")

# Default to "Release" build
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "The configuration to build" FORCE)
endif()

# Define the output directory for 'Release' builds
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/products/Release/bin" CACHE PATH "" FORCE)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/products/Release/lib" CACHE PATH "" FORCE)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/products/Release/lib" CACHE PATH "" FORCE)

# Define the output directory for 'Debug' builds
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/products/Debug/bin" CACHE PATH "" FORCE)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/products/Debug/lib" CACHE PATH "" FORCE)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/products/Debug/lib" CACHE PATH "" FORCE)

# Search for the systems threading library
find_package(Threads REQUIRED)

# Set libtins options
set(LIBTINS_ENABLE_CXX11 ON CACHE BOOL "" FORCE)
set(LIBTINS_ENABLE_WPA2 OFF CACHE BOOL "" FORCE)
set(LIBTINS_BUILD_SHARED OFF CACHE BOOL "" FORCE)
set(LIBTINS_ENABLE_DOT11 OFF CACHE BOOL "" FORCE)
set(LIBTINS_ENABLE_ACK_TRACKER OFF CACHE BOOL "" FORCE)
set(LIBTINS_ENABLE_WPA2_CALLBACKS OFF CACHE BOOL "" FORCE)
set(LIBTINS_ENABLE_TCP_STREAM_CUSTOM_DATA OFF CACHE BOOL "" FORCE)

# Add dependencies
add_subdirectory("third_party/tins")
add_subdirectory("third_party/libdabip")
add_subdirectory("third_party/libdabdemod")
add_subdirectory("third_party/libdabdevice")
add_subdirectory("third_party/libdabdecode")

# Tell CMake about our custom include paths
include_directories("include")
include_directories(SYSTEM "third_party/asio/asio/include")
include_directories(SYSTEM "${DABIP_INCLUDES}")
include_directories(SYSTEM "${DABDEMOD_INCLUDES}")
include_directories(SYSTEM "${DABDECODE_INCLUDES}")
include_directories(SYSTEM "${DABDEVICE_INCLUDES}")

# Include the CMakeLists.txt found in the folder "src"
add_subdirectory("src")
