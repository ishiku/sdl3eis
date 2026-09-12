cmake_minimum_required(VERSION 4.3)

set(CMAKE_CXX_SCAN_FOR_MODULES OFF) 

if (NOT DEFINED CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 23)
endif()

set(CMAKE_CXX_EXTENSIONS OFF)

project(
  sdl3eis
  VERSION 0.0.1
  LANGUAGES CXX)

include(cmake/PreventInSourceBuilds.cmake)
include(ProjectOptions.cmake)


sdl3eis_setup_options()
sdl3eis_global_options()
include(Dependencies.cmake)
sdl3eis_setup_dependencies()
sdl3eis_local_options()

set(CMAKE_CXX_VISIBILITY_PRESET hidden)

set(GIT_SHA
    "Unknown"
    CACHE STRING "SHA this build was generated from")
string(
  SUBSTRING "${GIT_SHA}"
            0
            8
            GIT_SHORT_SHA)

target_compile_features(sdl3eis_options INTERFACE cxx_std_${CMAKE_CXX_STANDARD})

add_library(sdl3eis::sdl3eis_options ALIAS sdl3eis_options)
add_library(sdl3eis::sdl3eis_warnings ALIAS sdl3eis_warnings)

#add_library(sdl3eis::sdl3eis_options INTERFACE IMPORTED)
#add_library(sdl3eis::sdl3eis_warnings INTERFACE IMPORTED)

add_subdirectory(configured_files)

add_subdirectory(src)

if(NOT PROJECT_IS_TOP_LEVEL)
  return()
endif()

include(CTest)

if(BUILD_TESTING)
  add_subdirectory(test)
endif()

