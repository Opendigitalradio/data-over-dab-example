add_executable(
  "packager"
  "packager.cpp"
  )

target_link_libraries(
  "packager"
  "${CMAKE_THREAD_LIBS_INI}"
  "${DABIP_SHARED_LIBRARIES}"
  "tins"
  )
