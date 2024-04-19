cmake_minimum_required(VERSION 3.7)
project(ffmpeg-kit-linux-test VERSION 6.0)

include(CTest)
enable_testing()

set(ENV{PKG_CONFIG_PATH} "${CMAKE_SOURCE_DIR}/../../../prebuilt/bundle-linux/ffmpeg-kit/pkgconfig")
find_package(PkgConfig REQUIRED)
pkg_check_modules(FFMPEG_KIT REQUIRED IMPORTED_TARGET ffmpeg-kit=6.0)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg-kit-linux-test-app.sh.in ${CMAKE_CURRENT_BINARY_DIR}/bin/ffmpeg-kit-linux-test-app.sh @ONLY)

list(APPEND APP_SOURCES
    "src/main.cpp"
)

add_executable(ffmpeg-kit-linux-test ${APP_SOURCES})
set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "ffmpeg-kit-linux-test-app")
target_link_libraries(${PROJECT_NAME} PUBLIC PkgConfig::FFMPEG_KIT)
target_link_libraries(${PROJECT_NAME} PUBLIC pthread)

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)

install (TARGETS ${CMAKE_PROJECT_NAME} RUNTIME DESTINATION bin)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/bin/ffmpeg-kit-linux-test-app.sh DESTINATION bin PERMISSIONS OWNER_WRITE OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_WRITE WORLD_READ)
