use Test;

use MIME::Base64;

use WebDriver2::Test::PO-Test;
use WebDriver2::SUT::Service::Loader;

unit role WebDriver2::Test::Service-Test does WebDriver2::Test::PO-Test;

has WebDriver2::SUT::Service::Loader $!loader;

method loader ( --> WebDriver2::SUT::Service::Loader:D ) {
	$!loader ||= WebDriver2::SUT::Service::Loader.new:
			:$.sut,
			:$.debug,
			:$.test-root;
}

multi method new ( WebDriver2::Test::Service-Test:U: Str $browser is copy, IO::Path:D :$test-root, Int:D :$debug is copy = 0 ) {
	my $self = callsame;
	$self.services;
	$self;
}

method services { ... }
