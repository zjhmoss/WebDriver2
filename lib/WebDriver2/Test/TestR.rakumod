use WebDriver2::Test::Template;

use WebDriver2;
use WebDriver2::Driver::Provider;

unit role WebDriver2::Test::TestR does WebDriver2::Test::Template does WebDriver2::Driver::Provider;

has Int:D $.debug = 0;
has Str:D $.browser is required;

#has WebDriver2:D $.driver is required;

has Int $.close-delay is rw = 3;
