add_executable(
  "packager"
  "packager.cpp"
  )

add_executable(
  "receiver"
  "receiver.cpp"
  "tun_device.cpp"
  )

target_link_libraries(
  "packager"
  "${CMAKE_THREAD_LIBS_INIT}"
  CONAN_PKG::libdabip
  "tins"
  )

target_link_libraries(
  "receiver"
  "${CMAKE_THREAD_LIBS_INIT}"
  CONAN_PKG::libdabdemod
  CONAN_PKG::libdabdecode
  CONAN_PKG::libdabdevice
  CONAN_PKG::libdabip
  "fftw3f"
  "rtlsdr"
  )
