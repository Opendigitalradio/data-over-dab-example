include(CMakeParseArguments)

function(install_conan_packages)
  get_directory_property(HAS_PARENT PARENT_DIRECTORY)
  if(HAS_PARENT)
    return()
  endif()

  set(OPTIONS SYSTEM_HEADERS)
  set(SV_ARGUMENTS LIBCXX CONANFILE)
  set(MV_ARGUMENTS PKGOPTS)
  cmake_parse_arguments(INSTALL_CONAN "${OPTIONS}" "${SV_ARGUMENTS}" "${MV_ARGUMENTS}" ${ARGN})

  if(${CMAKE_CXX_COMPILER_ID} MATCHES "GNU")
    set(_COMPILER "gcc")
  elseif(${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
    set(_COMPILER "clang")
  else()
    message(FATAL_ERROR "Conan: Unknown compiler ${CMAKE_CXX_COMPILER_ID}")
  endif()

  string(SUBSTRING ${CMAKE_CXX_COMPILER_VERSION} 0 3 _COMPILER_VERSION)

  if(NOT DEFINED INSTALL_CONAN_LIBCXX)
    if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
      set(_LIBCXX "libc++")
    elseif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
      if(${_COMPILER} MATCHES "gcc" AND ${_COMPILER_VERSION} VERSION_LESS "5.1")
        set(_LIBCXX "libstdc++")
      else()
        set(_LIBCXX "libstdc++11")
      endif()
    else()
      message(FATAL_ERROR "Conan: failed to determine C++ standard library")
    endif()
  else()
    set(_LIBCXX ${INSTALL_CONAN_LIBCXX})
  endif()

  if(NOT DEFINED INSTALL_CONAN_CONANFILE)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/conanfile.py")
      set(_CONANFILE "${CMAKE_CURRENT_SOURCE_DIR}/conanfile.py")
    elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/conanfile.txt")
      set(_CONANFILE "${CMAKE_CURRENT_SOURCE_DIR}/conanfile.txt")
    else()
      message(FATAL_ERROR "Conan: could not find valid conanfile")
    endif()
  else()
    get_filename_component(_CONANFILE "${INSTALL_CONAN_CONANFILE}" REALPATH BASE_DIR "${CMAKE_BINARY_DIR}")
    if(NOT EXISTS "${_CONANFILE}")
      message(FATAL_ERROR "Conan: the specified conanfile '${_CONANFILE}' does not exist")
    endif()
  endif()

  if(DEFINED INSTALL_CONAN_PKGOPTS)
    foreach(OPT ${INSTALL_CONAN_PKGOPTS})
      set(_OPTIONS ${_OPTIONS} -o ${OPT})
    endforeach()
  endif()

  message(STATUS "Conan: current conanfile: ${_CONANFILE}")

  message(STATUS "Conan: installing packages")
  get_filename_component(_CONANFILE "${_CONANFILE}" DIRECTORY)
  execute_process(COMMAND conan
    install
    --build=missing
    -g txt
    -g cmake
    -s compiler=${_COMPILER}
    -s compiler.version=${_COMPILER_VERSION}
    -s compiler.libcxx=${_LIBCXX}
    ${_OPTIONS}
    ${_CONANFILE}
    OUTPUT_FILE "${CMAKE_BINARY_DIR}/${PROJECT_NAME}_conan_install.log"
    RESULT_VARIABLE _RESULT)
  if(${_RESULT})
    message(FATAL_ERROR "Conan: failed to install packages. Check ${CMAKE_BINARY_DIR}/${PROJECT_NAME}_conan_install.log")
  endif()

  include("${CMAKE_BINARY_DIR}/conanbuildinfo.cmake")
  if(DEFINED INSTALL_CONAN_SYSTEM_HEADERS)
    set(CONAN_SYSTEM_INCLUDES ON)
  endif()
  conan_basic_setup(TARGETS)
endfunction()
