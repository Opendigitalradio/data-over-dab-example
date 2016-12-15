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
  "${CMAKE_THREAD_LIBS_INI}"
  "${DABIP_SHARED_LIBRARIES}"
  "tins"
  )

target_link_libraries(
  "receiver"
  "${CMAKE_THREAD_LIBS_INI}"
  "${DABIP_SHARED_LIBRARIES}"
  "${DABDEMOD_SHARED_LIBRARIES}"
  "${DABDECODE_SHARED_LIBRARIES}"
  "fftw3f"
  "rtlsdr"
  )
