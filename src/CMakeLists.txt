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
  "${${${PROJECT_NAME}_UPPER}_DEPS}"
  "tins"
  )

target_link_libraries(
  "receiver"
  "${CMAKE_THREAD_LIBS_INIT}"
  "${${${PROJECT_NAME}_UPPER}_DEPS}"
  "fftw3f"
  "rtlsdr"
  )
