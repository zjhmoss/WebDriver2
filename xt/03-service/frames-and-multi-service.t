use Test;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Until;
use WebDriver2::Until::Command;
use WebDriver2::Command::Element::Locator::ID;
use WebDriver2::Command::Element::Locator::Tag-Name;

use WebDriver2::SUT::Build;
use WebDriver2::SUT::Service;
use WebDriver2::SUT::Tree;

use WebDriver2::Test::Service-Test;
use WebDriver2::Test::Config-From-File;

my IO::Path $html-file =
		.add: 'page-from.html' with $*PROGRAM.parent.parent.add: 'content';

class From-Test-Service does WebDriver2::SUT::Service {
	
	submethod BUILD ( WebDriver2::Driver:D :$!driver ) { }

	method nav {
		my $url = WebDriver2::SUT::Tree::URL.new: 'file://' ~ $html-file;
		$!driver.navigate: $url.Str;
	}

	method name ( --> Str:D ) { 'page-from' } # lists

	method page-link {
		my WebDriver2::Until $stale =
				WebDriver2::Until::Command::Stale.new:
						duration => 10,
						interval => 1 / 10,
						element => .resolve with self.get: 'a';
		.resolve.click with self.get: 'a';
		$stale.retry;
	}
}

class To-Test-Service does WebDriver2::SUT::Service {
	
	submethod BUILD ( WebDriver2::Driver:D :$!driver ) { }

	method name ( --> Str:D ) { 'page-to' } # lists

	method item-text {
		.resolve.text with self.get: 'item';
	}
}

class Frames-Test-Service does WebDriver2::SUT::Service {
	
	submethod BUILD ( WebDriver2::Driver:D :$!driver ) { }
	
	method name ( --> Str:D ) { 'page-to-frame' } # lists

	method refresh {
		$!driver.refresh;
	}

	method top {
		$!driver.top;
	}


	method inner-h2-text {
		.resolve.text with self.get: 'inner-h2';
	}
}

class Frames-Test
		does WebDriver2::Test::Service-Test
		does WebDriver2::Test::Config-From-File # TODO : why include again ?
{
	has From-Test-Service $!from;
	has To-Test-Service $!to;
	has Frames-Test-Service $!frames;
	
	submethod BUILD (
			Str   :$!browser,
			Str:D :$!name,
			Str:D :$!description,
			Str:D :$!sut-name,
			Int   :$!plan,
			Int:D :$!debug = 0
	) { }
	
	submethod TWEAK (
			#			Str   :$browser is copy,
			Str:D :$name,
			Str:D :$description,
			Str:D :$sut-name,
			Int   :$plan,
			Int:D :$debug = 0
	) {
		$!sut = WebDriver2::SUT::Build.page: { self.driver.top }, $!sut-name, debug => self.debug;
		$!loader =
				WebDriver2::SUT::Service::Loader.new:
						driver => self.driver,
						:$!browser,
						:$sut-name,
						:$debug;
	}

	method services {
		$!loader.load-elements: $!from = From-Test-Service.new: :$.driver;
		$!loader.load-elements: $!to = To-Test-Service.new: :$.driver;
		$!loader.load-elements: $!frames = Frames-Test-Service.new: :$.driver;
	}

	method new ( Str $browser? is copy, Int :$debug is copy ) {
		self.set-from-file: $browser; # , $debug;
		my Frames-Test:D $self =
				callwith
						:$browser,
						:$debug,
						sut-name => 'page-to',
						name => 'frames',
						description => 'tests nesting frames',
						plan => 2;
		$self.init;
		$self.services;
		$self;
	}
	
	method test {
		$!from.nav;
		$!from.page-link;
		$!frames.refresh;
		$!frames.top;
		self.is: 'get content from nested frame', 'internal frame', $!frames.inner-h2-text;
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Frames-Test.new: $browser, :$debug;
}
