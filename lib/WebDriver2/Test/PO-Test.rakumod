use WebDriver2::SUT::Build;
use WebDriver2::Test::Template;

unit role WebDriver2::Test::PO-Test does WebDriver2::Test::Template;

has WebDriver2::SUT::Tree::SUT $.sut is rw;

method sut-name ( --> Str:D ) { ... }

multi method new ( WebDriver2::Test::PO-Test:U: Str $browser is copy, IO::Path:D :$test-root, Int:D :$debug is copy = 0 ) {
	my $self = callsame;
	$self.sut = WebDriver2::SUT::Build.page: { $self.driver.top }, $self.sut-name, :$debug;
	$self;
}
