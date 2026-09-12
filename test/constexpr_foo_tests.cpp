#include <catch2/catch_test_macros.hpp>

#include "sdl3eis/foo.hpp"

TEST_CASE("Dummy constexpr foo test", "[foo]") { STATIC_REQUIRE(constexpr_foo() == 0); }
