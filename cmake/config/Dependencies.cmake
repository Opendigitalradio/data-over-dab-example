include("ExternalDependency")

set(${${PROJECT_NAME}_UPPER}_DEPS)

if(EXTERNAL_DEPS_VIA STREQUAL "conan")
  include("ConanPackages")
  list(APPEND ${${PROJECT_NAME}_UPPER}_DEPS
    CONAN_PKG::libdabdemod
    CONAN_PKG::libdabdecode
    CONAN_PKG::libdabdevice
    CONAN_PKG::libdabip
    )

  install_conan_packages(SYSTEM_HEADERS
    PKGOPTS ${CONAN_OPTIONS}
    )
elseif(EXTERNAL_DEPS_VIA STREQUAL "git")
  external_dependency(CMAKE
    NAME    "dabdemod"
    REPO    "https://github.com/Opendigitalradio/libdabdemod"
    )
  external_dependency(CMAKE
    NAME    "dabdecode"
    REPO    "https://github.com/Opendigitalradio/libdabdecode"
    )
  external_dependency(CMAKE
    NAME    "dabdevice"
    REPO    "https://github.com/Opendigitalradio/libdabdevice"
    )
  external_dependency(CMAKE
    NAME    "dabip"
    REPO    "https://github.com/Opendigitalradio/libdabip"
    )
else()
  message(FATAL_ERROR "Unknown dependency resolution mechanism '${EXTERNAL_DEPS_VIA}'")
endif()
