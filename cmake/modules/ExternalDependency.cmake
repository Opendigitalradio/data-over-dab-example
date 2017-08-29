include(CMakeParseArguments)

set(EXTERNAL_DEPS_VIA "git"
  CACHE STRING
  "The dependency resolution mechanism to use for ${PROJECT_NAME} and its subprojects"
  )

set_property(CACHE EXTERNAL_DEPS_VIA
  PROPERTY
  STRINGS
  "git"
  "conan"
  )

function(EXTERNAL_DEPENDENCY)
  set(OPTS   CMAKE)
  set(SVARGS NAME LIBNAME REPO)
  set(MVARGS INCLUDE_DIRECTORIES DEPENDENCIES)

  cmake_parse_arguments(DEP
    "${OPTS}"
    "${SVARGS}"
    "${MVARGS}"
    ${ARGN}
    )

  if(NOT DEP_NAME)
    message(FATAL_ERROR "ExternalDependency: Missing required argument NAME")
  endif()

  if(NOT DEP_REPO)
    message(FATAL_ERROR "ExternalDependency: Missing required argument REPO")
  endif()

  if(NOT GIT_FOUND)
    find_package(Git REQUIRED)
  endif()

  if(NOT DEP_LIBNAME)
    set(DEP_LIBNAME ${DEP_NAME})
  endif()

  list(APPEND ${${PROJECT_NAME}_UPPER}_DEPS
    ${DEP_LIBNAME}
    )

  set(${${PROJECT_NAME}_UPPER}_DEPS ${${${PROJECT_NAME}_UPPER}_DEPS} PARENT_SCOPE)

  set(GUARD_TARGET "external_dep_${DEP_LIBNAME}")

  if(NOT TARGET ${GUARD_TARGET})
    add_custom_target(${GUARD_TARGET})
  else()
    return()
  endif()

  set(CLONE_DIR "${PROJECT_SOURCE_DIR}/external")

  file(MAKE_DIRECTORY ${CLONE_DIR})

  if(NOT EXISTS ${CLONE_DIR}/${DEP_NAME})
    message(STATUS "ExternalDependency: Cloning ${DEP_NAME}")
    execute_process(COMMAND ${GIT_EXECUTABLE}
      clone ${DEP_REPO} ${DEP_NAME}
      WORKING_DIRECTORY ${CLONE_DIR}
      OUTPUT_FILE "${CMAKE_BINARY_DIR}/${DEP_NAME}_git_stdout.log"
      ERROR_FILE "${CMAKE_BINARY_DIR}/${DEP_NAME}_git_stderr.log"
      )
  endif()

  if(DEP_CMAKE)
    add_subdirectory(${CLONE_DIR}/${DEP_NAME})
  else()
    if(NOT DEP_INCLUDE_DIRECTORIES)
      message(FATAL_ERROR "ExternalDependency: Missing required argument INCLUDE_DIRECTORIES")
    endif()

    foreach(INCLUDE_DIRECTORY IN LISTS DEP_INCLUDE_DIRECTORIES)
      if(NOT IS_ABSOLUTE ${DEP_INCLUDE_DIRECTORIES})
        set(INCLUDE_DIRECTORY "${CLONE_DIR}/${DEP_NAME}/${INCLUDE_DIRECTORY}")
        file(TO_CMAKE_PATH ${INCLUDE_DIRECTORY} INCLUDE_DIRECTORY)
      endif()
      list(APPEND PROCESSED_INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORY})
    endforeach()
    add_library(${DEP_LIBNAME} INTERFACE)
    target_include_directories(${DEP_LIBNAME} SYSTEM INTERFACE
      $<BUILD_INTERFACE:${PROCESSED_INCLUDE_DIRECTORIES}>
      )
    target_link_libraries(${DEP_LIBNAME} INTERFACE
      ${DEP_DEPENDENCIES}
      )
  endif()

  unset(CLONE_DIR)
endfunction()
