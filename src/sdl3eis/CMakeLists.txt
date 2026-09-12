include(GenerateExportHeader)


add_library(sdl3eis foo.cpp)



add_library(sdl3eis::sdl3eis ALIAS sdl3eis)

target_link_libraries(sdl3eis PRIVATE sdl3eis_options sdl3eis_warnings SDL3::SDL3)

target_include_directories(sdl3eis ${WARNING_GUARD} PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
                                                                  $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>)

target_compile_features(sdl3eis PUBLIC cxx_std_${CMAKE_CXX_STANDARD})

sdl3eis_configure_linker(sdl3eis)

set_target_properties(
  sdl3eis
  PROPERTIES VERSION ${PROJECT_VERSION}
             CXX_VISIBILITY_PRESET hidden
             VISIBILITY_INLINES_HIDDEN YES)

generate_export_header(sdl3eis EXPORT_FILE_NAME ${PROJECT_BINARY_DIR}/include/sdl3eis/sdl3eis_export.hpp)

if(NOT BUILD_SHARED_LIBS)
  target_compile_definitions(sdl3eis PUBLIC SDL3EIS_STATIC_DEFINE)
endif()
