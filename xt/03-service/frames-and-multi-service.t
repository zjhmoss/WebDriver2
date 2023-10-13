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
#		does WebDriver2::Test::Config-From-File # TODO : why include again ?
{
	has Str:D $.sut-name = 'page-to';
	has Int:D $.plan = 1;
	has Str:D $.name = 'frames';
	has Str:D $.description = 'tests nesting frames';
	
	has From-Test-Service $!from;
	has To-Test-Service $!to;
	has Frames-Test-Service $!frames;

	method services {
		$.loader.load-elements: $!from = From-Test-Service.new: :$.driver;
		$.loader.load-elements: $!to = To-Test-Service.new: :$.driver;
		$.loader.load-elements: $!frames = Frames-Test-Service.new: :$.driver;
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
	.execute with Frames-Test.new: $browser, :$debug, test-root => 'xt'.IO;
}
