use WebDriver2::SUT::Tree;
use WebDriver2::SUT::Build;

unit role WebDriver2::Test::PO-TestR does WebDriver2::Driver::Provider;

has Str:D $.sut-name is required;
has WebDriver2::SUT::Tree::SUT $!sut;

submethod BUILD ( Str:D :$sut-name is required ) {
	$!sut = WebDriver2::SUT::Build.page: { $!driver }, $sut-name, :$debug;
}
