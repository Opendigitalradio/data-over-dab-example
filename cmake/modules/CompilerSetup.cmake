if(NOT CXX_VERSION)
  set(CXX_VERSION "c++14")
endif()

# Acquire compiler information
execute_process(
  COMMAND
  bash -c "${CMAKE_CXX_COMPILER} -E -xc++ -std=${CXX_VERSION} - -v </dev/null 2>&1"
  OUTPUT_VARIABLE
  COMPILER_SETTINGS
  )

# Extract system headers
string(
  REGEX
  REPLACE
  "(.*#include <\.\.\.> search starts here:)\n(.*)\n(End of search list\..*)" "\\2"
  LINES
  ${COMPILER_SETTINGS}
  )

# Prepare the list of system headrs
string(STRIP ${LINES} LINES)
string(REPLACE " " "" LINES ${LINES})
string(REPLACE "\n" ";" LINES ${LINES})

# Add system header locations to the system header search-path
include_directories(SYSTEM ${LINES})

# Prepare some generic C++ compiler flags
set(CMAKE_CXX_FLAGS "-std=${CXX_VERSION} -Wall -Wextra -pedantic -Werror")

# Make pedantic warning fatal with GCC
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pedantic-errors")
endif()

# Create upper-case copy of the project name for variable prefixes
string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)

# Enable support for different sanitizers when building with clang
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  option(${PROJECT_NAME_UPPER}_ENABLE_ASAN "Enable ASan (address sanitization)" OFF)
  option(${PROJECT_NAME_UPPER}_ENABLE_UBSAN "Enable UBSan (undefined-behavior sanitization)" OFF)

  if(${PROJECT_NAME_UPPER}_ENABLE_ASAN OR ${PROJECT_NAME_UPPER}_ENABLE_UBSAN)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-omit-frame-pointer")
    set(SANITIZERS "")

    if(${PROJECT_NAME_UPPER}_ENABLE_ASAN)
      list(APPEND SANITIZERS "address")
    endif()

    if(${PROJECT_NAME_UPPER}_ENABLE_UBSAN)
      list(APPEND SANITIZERS "undefined")
    endif()

    string(REPLACE ";" "," SANITIZERS "${SANITIZERS}")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=${SANITIZERS}")
  endif()
endif()

# Allow disabling RTTI
option(${PROJECT_NAME_UPPER}_ENABLE_RTTI "Enable runtime type information" ON)
if(${PROJECT_NAME_UPPER}_ENABLE_RTTI)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -frtti")
else()
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-rtti")
endif()

# Allow disable Exceptions
option(${PROJECT_NAME_UPPER}_ENABLE_EXCEPTIONS "Enable C++ exceptions" ON)
if(${PROJECT_NAME_UPPER}_ENABLE_EXCEPTIONS)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fexceptions")
else()
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-exceptions")
endif()

# Export general C++ compiler flags
set(
  CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native"
  CACHE STRING "Flags used by the compiler during all builds."
  FORCE
  )

# Export additional C++ compiler flags for debug builds
set(
  CMAKE_CXX_FLAGS_DEBUG "-g3"
  CACHE STRING "Flags used by the compiler during debug builds."
  FORCE
  )

# Export additional C++ compiler flags for release builds
set(
  CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG -flto -fvisibility=hidden"
  CACHE STRING "Flags used by the compiler during release builds."
  FORCE
  )

# Export additional C++ compiler flags for release builds with debug information
set(
  CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELEASE} -g -DNDEBUG"
  CACHE STRING "Flags used by the compiler during release builds with debug info."
  FORCE
  )

# Export additional C++ compiler flags for minimum size release builds
set(
  CMAKE_CXX_FLAGS_MINSIZEREL "-O2 -DNDEBUG -flto -fvisibility=hidden"
  CACHE STRING "Flags used by the compiler during release builds for minimum size."
  FORCE
  )

if(${CMAKE_CXX_COMPILER_ID} MATCHES "GNU")
  set(
    CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL} -Os -ffunction-sections -fdata-sections -Wl,--gc-sections"
    CACHE STRING "Flags used by the compiler during release builds for minimum size."
    FORCE
    )
endif()


# Export additional C++ compile flags for coverage builds
set(
  CMAKE_CXX_FLAGS_COVERAGE "-O0 -g --coverage"
  CACHE STRING "Flags used by the compiler during coverage builds."
  FORCE
  )
