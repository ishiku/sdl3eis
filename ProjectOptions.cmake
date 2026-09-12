include(cmake/LibFuzzer.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)


include(CheckCXXSourceCompiles)

function(sdl3eis_supports_sanitizers)
  # Emscripten doesn't support sanitizers
  if(EMSCRIPTEN)
    set(SUPPORTS_UBSAN OFF PARENT_SCOPE)
    set(SUPPORTS_ASAN OFF PARENT_SCOPE)
  elseif((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)
    message(STATUS "Sanity checking UndefinedBehaviorSanitizer, it should be supported on this platform")
    set(TEST_PROGRAM "int main() { return 0; }")

    # Check if UndefinedBehaviorSanitizer works at link time
    set(CMAKE_REQUIRED_FLAGS "-fsanitize=undefined")
    set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=undefined")
    check_cxx_source_compiles("${TEST_PROGRAM}" HAS_UBSAN_LINK_SUPPORT)

    if(HAS_UBSAN_LINK_SUPPORT)
      message(STATUS "UndefinedBehaviorSanitizer is supported at both compile and link time.")
      set(SUPPORTS_UBSAN ON PARENT_SCOPE)
    else()
      message(WARNING "UndefinedBehaviorSanitizer is NOT supported at link time.")
      set(SUPPORTS_UBSAN OFF PARENT_SCOPE)
    endif()
  else()
    set(SUPPORTS_UBSAN OFF PARENT_SCOPE)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF PARENT_SCOPE)
  else()
    if(NOT WIN32)
      message(STATUS "Sanity checking AddressSanitizer, it should be supported on this platform")
      set(TEST_PROGRAM "int main() { return 0; }")

      # Check if AddressSanitizer works at link time
      set(CMAKE_REQUIRED_FLAGS "-fsanitize=address")
      set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=address")
      check_cxx_source_compiles("${TEST_PROGRAM}" HAS_ASAN_LINK_SUPPORT)

      if(HAS_ASAN_LINK_SUPPORT)
        message(STATUS "AddressSanitizer is supported at both compile and link time.")
        set(SUPPORTS_ASAN ON PARENT_SCOPE)
      else()
        message(WARNING "AddressSanitizer is NOT supported at link time.")
        set(SUPPORTS_ASAN OFF PARENT_SCOPE)
      endif()
    else()
      set(SUPPORTS_ASAN ON PARENT_SCOPE)
    endif()
  endif()
endfunction()

macro(sdl3eis_setup_options)
  option(sdl3eis_ENABLE_HARDENING "Enable hardening" ON)
  option(sdl3eis_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    sdl3eis_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    sdl3eis_ENABLE_HARDENING
    OFF)

  sdl3eis_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR sdl3eis_PACKAGING_MAINTAINER_MODE)
    option(sdl3eis_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(sdl3eis_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(sdl3eis_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(sdl3eis_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(sdl3eis_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(sdl3eis_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(sdl3eis_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(sdl3eis_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(sdl3eis_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(sdl3eis_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(sdl3eis_ENABLE_PCH "Enable precompiled headers" OFF)
    option(sdl3eis_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(sdl3eis_ENABLE_IPO "Enable IPO/LTO" ON)
    option(sdl3eis_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(sdl3eis_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(sdl3eis_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(sdl3eis_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(sdl3eis_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(sdl3eis_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(sdl3eis_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(sdl3eis_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(sdl3eis_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(sdl3eis_ENABLE_PCH "Enable precompiled headers" OFF)
    option(sdl3eis_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      sdl3eis_ENABLE_IPO
      sdl3eis_WARNINGS_AS_ERRORS
      sdl3eis_ENABLE_SANITIZER_ADDRESS
      sdl3eis_ENABLE_SANITIZER_LEAK
      sdl3eis_ENABLE_SANITIZER_UNDEFINED
      sdl3eis_ENABLE_SANITIZER_THREAD
      sdl3eis_ENABLE_SANITIZER_MEMORY
      sdl3eis_ENABLE_UNITY_BUILD
      sdl3eis_ENABLE_CLANG_TIDY
      sdl3eis_ENABLE_CPPCHECK
      sdl3eis_ENABLE_COVERAGE
      sdl3eis_ENABLE_PCH
      sdl3eis_ENABLE_CACHE)
  endif()

  sdl3eis_check_libfuzzer_support(LIBFUZZER_SUPPORTED)
  if(LIBFUZZER_SUPPORTED AND (sdl3eis_ENABLE_SANITIZER_ADDRESS OR sdl3eis_ENABLE_SANITIZER_THREAD OR sdl3eis_ENABLE_SANITIZER_UNDEFINED))
    set(DEFAULT_FUZZER ON)
  else()
    set(DEFAULT_FUZZER OFF)
  endif()

  option(sdl3eis_BUILD_FUZZ_TESTS "Enable fuzz testing executable" ${DEFAULT_FUZZER})

endmacro()

macro(sdl3eis_global_options)
  if(sdl3eis_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    sdl3eis_enable_ipo()
  endif()

  sdl3eis_supports_sanitizers()

  if(sdl3eis_ENABLE_HARDENING AND sdl3eis_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR sdl3eis_ENABLE_SANITIZER_UNDEFINED
       OR sdl3eis_ENABLE_SANITIZER_ADDRESS
       OR sdl3eis_ENABLE_SANITIZER_THREAD
       OR sdl3eis_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message("${sdl3eis_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${sdl3eis_ENABLE_SANITIZER_UNDEFINED}")
    sdl3eis_enable_hardening(sdl3eis_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(sdl3eis_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(sdl3eis_warnings INTERFACE)
  add_library(sdl3eis_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  sdl3eis_set_project_warnings(
    sdl3eis_warnings
    ${sdl3eis_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  include(cmake/Linker.cmake)
  # Must configure each target with linker options, we're avoiding setting it globally for now

  if(NOT EMSCRIPTEN)
    include(cmake/Sanitizers.cmake)
    sdl3eis_enable_sanitizers(
      sdl3eis_options
      ${sdl3eis_ENABLE_SANITIZER_ADDRESS}
      ${sdl3eis_ENABLE_SANITIZER_LEAK}
      ${sdl3eis_ENABLE_SANITIZER_UNDEFINED}
      ${sdl3eis_ENABLE_SANITIZER_THREAD}
      ${sdl3eis_ENABLE_SANITIZER_MEMORY})
  endif()

  set_target_properties(sdl3eis_options PROPERTIES UNITY_BUILD ${sdl3eis_ENABLE_UNITY_BUILD})

  if(sdl3eis_ENABLE_PCH)
    target_precompile_headers(
      sdl3eis_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(sdl3eis_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    sdl3eis_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(sdl3eis_ENABLE_CLANG_TIDY)
    sdl3eis_enable_clang_tidy(sdl3eis_options ${sdl3eis_WARNINGS_AS_ERRORS})
  endif()

  if(sdl3eis_ENABLE_CPPCHECK)
    sdl3eis_enable_cppcheck(${sdl3eis_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  if(sdl3eis_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    sdl3eis_enable_coverage(sdl3eis_options)
  endif()

  if(sdl3eis_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(sdl3eis_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(sdl3eis_ENABLE_HARDENING AND NOT sdl3eis_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR sdl3eis_ENABLE_SANITIZER_UNDEFINED
       OR sdl3eis_ENABLE_SANITIZER_ADDRESS
       OR sdl3eis_ENABLE_SANITIZER_THREAD
       OR sdl3eis_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    sdl3eis_enable_hardening(sdl3eis_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()
