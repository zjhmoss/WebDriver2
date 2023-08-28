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



class Page-Link-From-Service does WebDriver2::SUT::Service {
	my IO::Path $html-file =
			.add: 'page-from.html' with $*PROGRAM.parent.parent.add: 'content';
	
	submethod BUILD ( WebDriver2::Driver:D :$!driver ) { }
	
	method html-file ( --> IO::Path ) { $html-file }

	method name ( --> Str:D ) { 'page-from' } # lists

	method top-retry {
		WebDriver2::Until::Command::Stale.new:
				element => self.get( 'h2' ).resolve,
				duration => 2,
				interval => 1 / 10,
				:!soft;
	}
	method nav {
		my $url = WebDriver2::SUT::Tree::URL.new: 'file://' ~ $html-file;
		$!driver.navigate: $url.Str;
	}
	method page-h2-text {
		.resolve.text with self.get: 'h2';
	}

	method page-link {
		.resolve with self.get: 'a';
	}
}

class Page-Link-To-Service does WebDriver2::SUT::Service {
	
	submethod BUILD ( WebDriver2::Driver:D :$!driver ) { }

	method name ( --> Str:D ) { 'page-to' } # lists

	method top-retry {
		WebDriver2::Until::Command::Stale.new:
			element => self.get( 'h2-page' ).resolve,
			duration => 2,
			interval => 1 / 10,
			:!soft;
	}

	method inner-h2-text {
		.resolve.text with self.get: 'h2-inner';
	}


	method item {
		.resolve with self.get: 'item';
	}

	method each-repeated ( &action ) {
		&action( self ) for self.get( 'item' ).iterator;
	}
	method first-repeated ( --> Page-Link-From-Service ) {
		self.repeated: { True }
	}
	method repeated ( &selector --> Page-Link-From-Service ) {
		for self.get( 'content' ).iterator {
			return self if &selector(self);
		}
		return;
	}
}

class Frames-Test
		does WebDriver2::Test::Service-Test
		does WebDriver2::Test::Config-From-File # TODO : why include again ?
{
	has Page-Link-From-Service $!from-service;
	has Page-Link-To-Service $!to-service;
	has Str @!expected = 'to page first', 'to page second';
	
	submethod BUILD (
			Str   :$!browser,
			Str:D :$!name,
			Str:D :$!description,
			Str:D :$!sut-name,
			Int   :$!plan,
			Int   :$!debug = 0
	) { }
	
	submethod TWEAK (
			#			Str   :$browser is copy,
			Str:D :$name,
			Str:D :$description,
			Str:D :$sut-name,
			Int   :$plan,
			Int   :$debug
	) {
		$!sut = WebDriver2::SUT::Build.page: { self.driver.top }, $!sut-name, debug => self.debug;
		$!loader =
				WebDriver2::SUT::Service::Loader.new:
						driver => self.driver,
						:$!browser,
						:$sut-name,
						:$debug;
	}

	method new ( Str $browser? is copy, Int:D :$debug = 0 ) {
		self.set-from-file: $browser; # , $debug;
		my Frames-Test:D $self =
				callwith
						:$browser,
						:$debug,
						sut-name => 'page-to',
						name => 'page-to',
						description => 'tests nesting frames',
						plan => 7;
		$self.init;
		$self.services;
		$self;
	}

	method services {
		$!loader.load-elements: $!from-service = Page-Link-From-Service.new: :$.driver;
		$!loader.load-elements: $!to-service = Page-Link-To-Service.new: :$.driver;
	}
	
	method test {
		$!from-service.nav;
		self.is: 'page title', 'iframe test', $.driver.title;

		self.is: 'page h2 test', 'iframe test', $!from-service.page-h2-text;

		my $stale = $!from-service.page-link;
		my WebDriver2::Until $until-stale =
				WebDriver2::Until::Command::Stale.new:
						element => $stale,
						duration => 10,
						interval => 1 / 10;
		$stale.click;
		$until-stale.retry;

		self.is: 'content available', 'internal frame', $!to-service.inner-h2-text;

		$!to-service.each-repeated: {
			self.is:
				'deeply nested list',
				@!expected.shift,
				.item.text;
		}
		self.is: 'all items seen', 0, +@!expected;
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Frames-Test.new: $browser, :$debug;
}
