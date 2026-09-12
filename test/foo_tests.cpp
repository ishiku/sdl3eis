#include <catch2/catch_test_macros.hpp>

#include <sdl3eis/foo.hpp>

TEST_CASE("Dummy foo test", "[foo]") { REQUIRE(foo() == 0); }
