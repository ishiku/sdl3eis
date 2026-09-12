include(cmake/CPM.cmake)

function(sdl3eis_setup_dependencies)

  if(NOT TARGET Catch2::Catch2WithMain)
    cpmaddpackage(
      NAME
      Catch2
      VERSION
      3.16.0
      GITHUB_REPOSITORY
      "catchorg/Catch2"
      SYSTEM
      YES)
  endif()

  if(NOT TARGET SDL3::SDL3)
    cpmaddpackage(
      NAME 
      SDL3 
      GITHUB_REPOSITORY 
      "libsdl-org/SDL" 
      GIT_TAG
      "release-3.4.14"
      SYSTEM
      YES
      OPTIONS
      "SDL_STATIC ON")
  endif()
    
endfunction()
