macro(sdl3eis_configure_linker project_name)
  set(sdl3eis_USER_LINKER_OPTION
    "DEFAULT"
      CACHE STRING "Linker to be used")
    set(sdl3eis_USER_LINKER_OPTION_VALUES "DEFAULT" "SYSTEM" "LLD" "GOLD" "BFD" "MOLD" "SOLD" "APPLE_CLASSIC" "MSVC")
  set_property(CACHE sdl3eis_USER_LINKER_OPTION PROPERTY STRINGS ${sdl3eis_USER_LINKER_OPTION_VALUES})
  list(
    FIND
    sdl3eis_USER_LINKER_OPTION_VALUES
    ${sdl3eis_USER_LINKER_OPTION}
    sdl3eis_USER_LINKER_OPTION_INDEX)

  if(${sdl3eis_USER_LINKER_OPTION_INDEX} EQUAL -1)
    message(
      STATUS
        "Using custom linker: '${sdl3eis_USER_LINKER_OPTION}', explicitly supported entries are ${sdl3eis_USER_LINKER_OPTION_VALUES}")
  endif()

  set_target_properties(${project_name} PROPERTIES LINKER_TYPE "${sdl3eis_USER_LINKER_OPTION}")
endmacro()
