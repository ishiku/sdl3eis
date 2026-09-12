#ifndef SDL3EIS_FOO_HPP
#define SDL3EIS_FOO_HPP

#include <sdl3eis/sdl3eis_export.hpp>

[[nodiscard]] SDL3EIS_EXPORT int foo() noexcept;

[[nodiscard]] constexpr int constexpr_foo() noexcept { return 0; }

#endif  // SDL3EIS_FOO_HPP
