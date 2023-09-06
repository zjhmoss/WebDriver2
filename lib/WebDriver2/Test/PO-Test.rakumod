use WebDriver2::SUT::Build;
use WebDriver2::SUT::Tree;
use WebDriver2::Test::Template;

#use WebDriver2::Test;

unit role WebDriver2::Test::PO-Test does WebDriver2::Test::Template;
#		is WebDriver2::Test
#		does WebDriver2::Test::PO-TestR;

#has Str:D $.sut-name is required;
has WebDriver2::SUT::Tree::SUT $.sut is rw;

method sut-name ( --> Str:D ) { ... }
method test-root ( --> IO::Path:D ) { ... }

#submethod BUILD (
#		Str:D :$!sut-name,
#) { }

#method test { !!! }

#method new ( #`[ Str:D :$sut-name is required, Int :$debug = 0 ] ) {
#	$!sut = WebDriver2::SUT::Build.page: { self.driver }, $!sut-name, debug => self.debug;
#}

method new ( Str $browser is copy, Int:D :$debug = 0 ) {
	self.set-from-file: $browser;
	my WebDriver2 $driver = .driver with WebDriver2::Driver::Provider.new: $browser, :$debug;
	my $self = self.bless: :$browser, :$driver, :$debug;
	$self.sut = WebDriver2::SUT::Build.page: { $driver.top }, $self.sut-name, :$debug;
	$self;
}
