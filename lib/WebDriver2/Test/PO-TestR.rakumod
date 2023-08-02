use WebDriver2::Test::TestR;
use WebDriver2::SUT::Tree;

unit role WebDriver2::Test::PO-TestR does WebDriver2::Test::TestR;

has Str:D $.sut-name is required;
