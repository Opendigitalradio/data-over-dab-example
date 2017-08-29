#[[.rst:
CUTE
----

Normally, CUTE ships with the `Cevelop C++ IDE <https://www.cevelop.com>`_. This
module enables you to easily use CUTE in CMake based projects, making it easy to
use CUTE based tests in continuous integration environments like Jenkins, Travis
CI, GitlabCI, and many others.  It will also make sure that *CTest*, CMakes test
executor, is activated. It also enables you to run the unit tests of your
project **during** the build process, making it possible to *fail fast* when one
of your modules fails its tests.

Installation
^^^^^^^^^^^^

CUTE for CMake can be downloaded via from `GitHub
<https://github.com/fmorgner/cute-cmake>`_ or installed directly via the `conan
<https://conan.io>`_ C++ package mangager. To do so, add the package to your
``conanfile.txt`` like this

.. code-block:: ini

  [requires]
  CUTE-cmake/[>=1.0]@fmorgner/stable

Using the conan package also makes sure, that an appropriate version of CUTE
will be installed as well. If you decide to install *CUTE for CMake* manually,
make sure to put the *CUTE* headers somewhere where your compiler will find
them.

Adding tests
^^^^^^^^^^^^

*CUTE for CMake* provides a single function to register a unit test with CMake.
In addition, a handful of per-project variables are provided, to customize the
configuration of *CUTE for CMake* on the project level.

Synopsis
""""""""

.. command:: cute_test

  Add a CUTE test to the project

  .. code-block:: cmake

    cute_test(<TestName>
              [GROUP <groupname>]
              [DEPENDENCIES <compiliation_dependency>...]
              [LIBRARIES <linking_dependency>...]
              [UNIQUE (On|Off)]
              [RUN_DURING_BUILD (On|Off)])

Description
"""""""""""

This function will search for one of the following files:

  - ``<TestName>_test.cpp``
  - ``<TestName>_test.cxx``
  - ``<TestName>_test.cc``

If none OR multiple files are found, a fatal error will be raised.

.. _section_arguments:

Parameters
""""""""""

*CUTE for CMake* provides several parameters for the :command:`cute_test`
function, that allow you to customize the behavior of the function, as well as
specify build time and link time dependencies for a specific test.

.. variable:: GROUP

  Add the test to the test-group named ``<groupname>``. Grouping tests adds
  another target to enable to run a specified test group only.

  | **Type**: `STRING`
  | **Parameter(s)**: <groupname>
  | **Default vaue**: `UNSET`

.. variable:: DEPENDENCIES

  Add compile-time dependencies to the test. ``<compiliation_dependency>`` shall
  be either a file name or a CMake *generator expression*. If one or more of the
  file names provided can not be resolved to actual files, test registration
  will fail.

  | **Type**: `PATH` or `GENERATOR_EXPRESSION`
  | **Parameter(s)**: <compiliation_dependency>...
  | **Default vaue**: `UNSET`

.. variable:: LIBRARIES

  Add link-time dependencies to the test. Every expression that is valid for
  use in ``target_link_libraries`` is also valid as an expression for
  ``linking_dependency``.

  | **Type**: `PATH` or `GENERATOR_EXPRESSION`
  | **Parameter(s)**: <linking_dependency>...
  | **Default vaue**: `UNSET`

.. variable:: UNIQUE

  If enabled (**ON**), ``cute_test`` will try to ensure the uniqueness of the test
  name by appending part of the SHA256 hash of the test's **group name** (see
  :variable:`GROUP`).  This feature helps to avoid collisions, when the same test
  name is reused throughout a project.

  | **Type**: `BOOL`
  | **Default vaue**: `OFF`

.. variable:: RUN_DURING_BUILD

  If enabled (**ON**), the test will be run as part of the build process. If the
  test fails, the build process will be aborted, similar to when a compilation
  error happens. Note however, that all targets the test depends on, if any,
  will be built/executed before the test is run.

  | **Type**: `BOOL`
  | **Default vaue**: `ON`

Variables
"""""""""

In addition to the regular arguments to the :command:`cute_test` function,
*CUTE for CMake* also provides a number of variables to override settings via
the project global scope. It is strongly advised to not use these variables in
libraries that are intended to be included as sub-projects in another CMake
project.

.. variable:: CUTE_REPORTS_DIRECTORY

  This variable makes it possible to specify a directory in which **all** CUTE
  tests, including the tests of sub-projects, will be executed. This can be used
  to, for example, collect all *XML* CUTE test reports in a common directory. If
  this variable is left empty, each project/sub-project receives its own working
  directory. The path to the respective project CUTE working directory can be
  found in ``<PROJECT_NAME>_CUTE_REPORTS_DIRECTORY``, where ``<PROJECT_NAME>``
  is substituted for the upper-case name of the project.

  | **Type**: `PATH`
  | **Parameter(s)**: <directory>
  | **Default vaue**: `UNSET`

.. variable:: CUTE_GROUP

  This variable makes it possible to group **all** unit tests into the same
  group. By default, each project gets its own test group. Using this variable,
  a master project can put all tests of all of its sub-projects into a common
  group.

  | **Type**: `STRING`
  | **Parameter(s)**: <group_name>
  | **Default vaue**: `UNSET`

.. variable:: CUTE_UNIQUE

  This variable can be used to globally force (**ON**) or prevent (**OFF**)
  *CUTE for CMakes* from trying to generate unique test names.

  | **Type**: `BOOL`
  | **Default vaue**: `UNSET`

.. variable:: CUTE_RUN_DURING_BUILD

  This variables makes it possible to globally enable (**ON**) or disable
  (**OFF**) test execution during the build process.

  | **Type**: `BOOL`
  | **Default vaue**: `UNSET`

Running tests
^^^^^^^^^^^^^

*Cute for CMake* provides several ways to run a project's CUTE tests. This
section gives an overview over the different ways to start a projects CUTE
tests.

As shown in section :ref:`section_arguments`, in the default configuration,
*CUTE for CMake* will run the registered tests during compilation. This will
make the build fail, if one of the tests of a project fails. Additionally,
*CUTE for CMake* provides a run-target for each registered test. These targets
all follow the same naming scheme: ``cute_test_<test_target_name>``.

Groups
^^^^^^

Groups make it possible to run a specific set of tests while leaving out the
others. For every project, *CUTE for CMake* provides a group target that makes
it easy to manually run all unit tests, called ``cute_all``. This target also
includes all CUTE tests of all sub-project. Another standard target provided
by *CUTE for CMake* called ``cute_group_<project_name>``, where
``<project_name>`` is the **lower case** name of the respective CMake project,
allows for the execution of the tests of a specific to a single project.

Examples
^^^^^^^^


#]]

enable_testing()

string(TOUPPER ${PROJECT_NAME} CUTE_${PROJECT_NAME}_UPPER)
if(NOT DEFINED CUTE_REPORTS_DIRECTORY AND NOT DEFINED ${CUTE_${PROJECT_NAME}_UPPER}_CUTE_REPORTS_DIRECTORY)
  set(${CUTE_${PROJECT_NAME}_UPPER}_CUTE_REPORTS_DIRECTORY
    ${PROJECT_BINARY_DIR}/cute-reports
    CACHE
    STRING
    "Output directory for CUTE test reports of ${PROJECT_NAME}"
    )
else()
  set(${CUTE_${PROJECT_NAME}_UPPER}_CUTE_REPORTS_DIRECTORY ${CUTE_REPORTS_DIRECTORY})
endif()
file(MAKE_DIRECTORY ${${CUTE_${PROJECT_NAME}_UPPER}_CUTE_REPORTS_DIRECTORY})

include(CMakeParseArguments)
function(cute_test TEST_NAME)
  set(OPTIONS)
  set(SV_ARGUMENTS GROUP UNIQUE RUN_DURING_BUILD)
  set(MV_ARGUMENTS DEPENDENCIES LIBRARIES)
  cmake_parse_arguments(CUTE_TEST "${OPTIONS}" "${SV_ARGUMENTS}" "${MV_ARGUMENTS}" ${ARGN})

  if(NOT DEFINED CUTE_TEST_UNIQUE)
    if(DEFINED CUTE_UNIQUE)
      set(CUTE_TEST_UNIQUE ${CUTE_UNIQUE})
    else()
      set(CUTE_TEST_UNIQUE Off)
    endif()
  endif()

  if(NOT DEFINED CUTE_TEST_GROUP)
    if(DEFINED CUTE_GROUP)
      set(CUTE_TEST_GROUP "${PROJECT_NAME}::${CUTE_GROUP}")
    else()
      set(CUTE_TEST_GROUP "${PROJECT_NAME}")
    endif()
  else()
    set(CUTE_TEST_GROUP "${PROJECT_NAME}::${CUTE_TEST_GROUP}")
  endif()
  string(REGEX REPLACE "::" "_" TEST_TARGET_GROUP ${CUTE_TEST_GROUP})

  if(NOT DEFINED CUTE_TEST_RUN_DURING_BUILD)
    if(DEFINED CUTE_RUN_DURING_BUILD)
      set(CUTE_TEST_RUN_DURING_BUILD ${CUTE_RUN_DURING_BUILD})
    else()
      set(CUTE_TEST_RUN_DURING_BUILD On)
    endif()
  endif()

  if(CMAKE_RUNTIME_OUTPUT_DIRECTORY)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cute-tests/${TEST_TARGET_GROUP}")
  else()
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/cute-tests/${TEST_TARGET_GROUP}")
  endif()

  set(SOURCE_FILE_CANDIDATES ${TEST_NAME}_test.cpp ${TEST_NAME}_test.cxx ${TEST_NAME}_test.cc)
  set(CANDIDATE_COUNT 0)
  foreach(CANDIDATE IN LISTS SOURCE_FILE_CANDIDATES)
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${CANDIDATE})
      MATH(EXPR CANDIDATE_COUNT "${CANDIDATE_COUNT}+1")
      set(TEST_SOURCE_FILE ${CANDIDATE})
    endif()
  endforeach()
  if(CANDIDATE_COUNT GREATER 1)
    message(FATAL_ERROR "More than one source candidate for ${TEST_NAME}")
  elseif(CANDIDATE_COUNT LESS 1)
    message(FATAL_ERROR "No source candidate for ${TEST_NAME}")
  endif()

  if(${CUTE_TEST_UNIQUE})
    string(SHA256 GROUP_HASH ${CUTE_TEST_GROUP})
    string(SUBSTRING ${GROUP_HASH} 0 8 GROUP_HASH)
    set(TEST_NAME "${TEST_NAME}_${GROUP_HASH}")
  endif()

  set(TEST_TARGET_NAME "${TEST_TARGET_GROUP}_${TEST_NAME}_test")
  if(NOT TARGET ${TEST_TARGET_NAME})
    message(STATUS "Registering CUTE test '${CUTE_TEST_GROUP}::${TEST_NAME}'")
    add_executable(${TEST_TARGET_NAME} ${TEST_SOURCE_FILE} ${CUTE_TEST_DEPENDENCIES})
    target_link_libraries(${TEST_TARGET_NAME} ${CUTE_TEST_LIBRARIES})
    target_compile_definitions(${TEST_TARGET_NAME} PRIVATE "-DCUTE_TESTING")
    add_test(NAME "${TEST_TARGET_NAME}"
      WORKING_DIRECTORY "${${CUTE_${PROJECT_NAME}_UPPER}_CUTE_REPORTS_DIRECTORY}"
      COMMAND ${TEST_TARGET_NAME}
    )

    if(${CUTE_TEST_RUN_DURING_BUILD})
      set(CUTE_TEST_RUN_TARGET "ALL")
    endif()
    add_custom_target(cute_test_${TEST_TARGET_NAME} ${CUTE_TEST_RUN_TARGET}
      COMMAND ctest -R ${TEST_TARGET_NAME} -Q --output-on-failure
      DEPENDS ${TEST_TARGET_NAME}
      COMMENT "Running CUTE test '${CUTE_TEST_GROUP}::${TEST_NAME}' ..."
      VERBATIM)

    set(GROUP_TARGET "cute_group_${TEST_TARGET_GROUP}")
    if(NOT TARGET ${GROUP_TARGET})
      add_custom_target(${GROUP_TARGET}
        COMMAND ctest -R ${TEST_TARGET_GROUP}* -Q ---output-on-failure
        DEPENDS ${TEST_TARGET_NAME}
        COMMENT "Running tests in group '${CUTE_TEST_GROUP}' ..."
        VERBATIM)
    else()
      add_dependencies(${GROUP_TARGET} ${TEST_TARGET_NAME})
    endif()

    string(TOLOWER ${PROJECT_NAME} CUTE_TEST_PROJECT_GROUP)
    if(NOT TARGET "cute_all_${CUTE_TEST_PROJECT_GROUP}")
      add_custom_target("cute_all_${CUTE_TEST_PROJECT_GROUP}"
        COMMAND ctest -R ${CUTE_TEST_PROJECT_GROUP}* -Q --output-on-failure
        DEPENDS ${TEST_TARGET_NAME}
        COMMENT "Running CUTE tests of '${PROJECT_NAME}' ..."
        VERBATIM)
    else()
      add_dependencies(cute_all_${CUTE_TEST_PROJECT_GROUP} ${TEST_TARGET_NAME})
    endif()

    if(NOT TARGET "cute_all")
      add_custom_target("cute_all"
        DEPENDS cute_all_${CUTE_TEST_PROJECT_GROUP}
        VERBATIM)
    else()
      add_dependencies(cute_all cute_all_${CUTE_TEST_PROJECT_GROUP})
    endif()

  endif()
endfunction()
