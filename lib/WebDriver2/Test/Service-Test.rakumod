use Test;

use MIME::Base64;

use WebDriver2;
use WebDriver2::Test::Config-From-File;
use WebDriver2::Test::PO-Test;
use WebDriver2::SUT::Service;
use WebDriver2::SUT::Service::Loader;

unit role WebDriver2::Test::Service-Test does WebDriver2::Test::PO-Test;

has WebDriver2::SUT::Service::Loader $!loader;

method loader ( --> WebDriver2::SUT::Service::Loader:D ) {
	$!loader ||= WebDriver2::SUT::Service::Loader.new:
			:$.sut,
			:$.debug,
			test-root => self.test-root;
}

method new ( Str $browser is copy, Int:D :$debug = 0 ) {
	self.set-from-file: $browser;
	my WebDriver2 $driver = .driver with WebDriver2::Driver::Provider.new: :$browser, :$debug;
	my $self = self.bless: :$browser, :$driver, :$debug;
	$self.sut = WebDriver2::SUT::Build.page: { $driver.top }, $self.sut-name, :$debug;
	$self.services;
	$self;
}

method services { ... }
