use WebDriver2::SUT::Tree;
use WebDriver2::SUT::Build;
use WebDriver2::Test;
use WebDriver2::Driver::Provider;

#use WebDriver2::Test;

unit role WebDriver2::Test::PO-Test does WebDriver2::Test;
#		is WebDriver2::Test
#		does WebDriver2::Test::PO-TestR;

has Str:D $.sut-name is required;
has WebDriver2::SUT::Tree::SUT $!sut;

#submethod BUILD (
#		Str:D :$!sut-name,
#) { }

method test { !!! }

#method new ( #`[ Str:D :$sut-name is required, Int :$debug = 0 ] ) {
#	$!sut = WebDriver2::SUT::Build.page: { self.driver }, $!sut-name, debug => self.debug;
#}
