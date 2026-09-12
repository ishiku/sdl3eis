cmake_minimum_required(VERSION 4.3)

project(CmakeConfigPackageTests 
  VERSION ${PROJECT_VERSION}
  LANGUAGES CXX)

if(PROJECT_IS_TOP_LEVEL OR TEST_INSTALLED_VERSION)
  enable_testing()

  find_package(sdl3eis CONFIG REQUIRED)

  if(NOT TARGET sdl3eis_options)
    message(FATAL_ERROR "Required config package not found!")
    return()
  endif()
endif()

include(${Catch2_SOURCE_DIR}/extras/Catch.cmake)

set(TESTS_SOURCES
  foo_tests.cpp)

set(CONSTEXPR_TESTS_SOURCES
  constexpr_foo_tests.cpp
)

add_executable(tests ${TESTS_SOURCES})

target_link_libraries(
  tests
  PRIVATE sdl3eis::sdl3eis_warnings
          sdl3eis::sdl3eis_options
          sdl3eis::sdl3eis
          Catch2::Catch2WithMain)

sdl3eis_configure_linker(tests)

if(WIN32 AND BUILD_SHARED_LIBS)
  add_custom_command(
    TARGET tests
    PRE_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:tests> $<TARGET_FILE_DIR:tests>
    COMMAND_EXPAND_LISTS)
endif()

catch_discover_tests(
  tests
  TEST_PREFIX
  "unittests."
  REPORTER
  XML
  OUTPUT_DIR
  .
  OUTPUT_PREFIX
  "unittests."
  OUTPUT_SUFFIX
  .xml)

add_executable(constexpr_tests ${CONSTEXPR_TESTS_SOURCES})

target_link_libraries(
  constexpr_tests
  PRIVATE sdl3eis::sdl3eis_warnings
          sdl3eis::sdl3eis_options
          sdl3eis::sdl3eis
          Catch2::Catch2WithMain)

sdl3eis_configure_linker(constexpr_tests)

catch_discover_tests(
  constexpr_tests
  TEST_PREFIX
  "constexpr."
  REPORTER
  XML
  OUTPUT_DIR
  .
  OUTPUT_PREFIX
  "constexpr."
  OUTPUT_SUFFIX
  .xml)

add_executable(relaxed_constexpr_tests ${CONSTEXPR_TESTS_SOURCES})

target_link_libraries(
  relaxed_constexpr_tests
  PRIVATE sdl3eis::sdl3eis_warnings
          sdl3eis::sdl3eis_options
          sdl3eis::sdl3eis
          Catch2::Catch2WithMain)
target_compile_definitions(relaxed_constexpr_tests PRIVATE -DCATCH_CONFIG_RUNTIME_STATIC_REQUIRE)

sdl3eis_configure_linker(relaxed_constexpr_tests)

catch_discover_tests(
  relaxed_constexpr_tests
  TEST_PREFIX
  "relaxed_constexpr."
  REPORTER
  XML
  OUTPUT_DIR
  .
  OUTPUT_PREFIX
  "relaxed_constexpr."
  OUTPUT_SUFFIX
  .xml)
