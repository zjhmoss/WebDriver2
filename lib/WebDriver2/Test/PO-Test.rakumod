use WebDriver2::Test;
use WebDriver2::Test::PO-TestR;

unit class WebDriver2::Test::PO-Test
		is WebDriver2::Test
		does WebDriver2::Test::PO-TestR;

submethod BUILD (
		Str:D :$!sut-name,
) { }

method test { !!! }
