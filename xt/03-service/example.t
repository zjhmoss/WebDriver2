use Test;
use MIME::Base64;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Test::Config-From-File;

use WebDriver2::SUT::Build;
use WebDriver2::SUT::Navigator;
use WebDriver2::SUT::Service;
use WebDriver2::Test::Service-Test;
use WebDriver2::Until;
use WebDriver2::Until::SUT;
use WebDriver2::Until::Command;



class Root-Content does WebDriver2::SUT::Service {
	my IO::Path $html-file =
			.add: 'example.html' with $*PROGRAM.parent.parent.add: 'content';
	
	submethod BUILD ( WebDriver2::Driver:D :$!driver ) { }
	
	method name (--> Str:D) {
		'example';
	}

	method heading ( --> Str:D ) {
		.resolve.text with self.get: 'the-h2';
	}

	method each-list-item ( &action ) {
		for self.get( 'a-mli' ).iterator {
			&action( self );
		}
	}

	method li {
		.resolve with self.get: 'a-mli';
	}

	method open {
			my $url =
					WebDriver2::SUT::Tree::URL.new:
							'file://' ~ $html-file;
			$!driver.navigate: $url.Str;
	}

	method open-other-frame {
		$!driver.top;
#		my WebDriver2::Until $stale =
#				WebDriver2::Until::Command::Stale.new:
#						duration => 3,
#						interval => 1 / 10,
#						element => .resolve with self.get: 'the-button';
		.resolve.click with self.get: 'the-button';
#		$stale.retry;
	}
}



class Original-Frame does WebDriver2::SUT::Service {
	
	submethod BUILD ( WebDriver2::Driver:D :$!driver ) { }
	
	method name (--> Str:D) {
			'example-original-frame'
	}

	method heading ( --> Str:D ) {
		.resolve.text with self.get: 'orig-h2';
	}

	method each-list-item ( &action ) {
		for self.get( 'a-fli' ).iterator {
			&action( self );
		}
	}

	method li {
		.resolve with self.get: 'a-fli';
	}
}

class Replacement-Frame does WebDriver2::SUT::Service {
	
	submethod BUILD ( WebDriver2::Driver:D :$!driver ) { }
	
	method name (--> Str:D) {
			'example-replacement-frame'
	}

	method heading ( --> Str:D ) {
		.resolve.text with self.get: 'rep-h2';
	}

	method each-list-item ( &action ) {
		for self.get( 'rep-li' ).iterator {
			&action( self );
		}
	}

	method li ( --> WebDriver2::Model::Element:D ) {
		.resolve with self.get: 'rep-li';
	}
	method loaded {
			my WebDriver2::Until $input-present =
					WebDriver2::Until::SUT::Present.new:
							duration => 10,
							interval => 1 / 10,
							element => self.get: 'rep-li';
			$input-present.retry;
	}
}

class Nested-Frame does WebDriver2::SUT::Service {
	
	submethod BUILD ( WebDriver2::Driver:D :$!driver ) { }
	
	method name ( --> Str:D ) {
		'example-nested-frame'
	}

	method heading ( --> Str:D ) {
		.resolve.text with self.get: 'nested-h2';
	}

	method each-list-item ( &action ) {
		for self.get( 'nested-li' ).iterator {
			&action( self );
		}
	}

	method li ( --> WebDriver2::Model::Element:D ) {
		.resolve with self.get: 'nested-li';
	}
}

class Example-Test
	does WebDriver2::Test::Service-Test
	does WebDriver2::Test::Config-From-File
{
	has Root-Content $!mls;
	has Original-Frame $!of;
	has Replacement-Frame $!rf;
	has Nested-Frame $!nf;
	
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
			my Example-Test:D $self =
					callwith
							:$browser,
							:$debug,
							sut-name => 'example',
							name => 'example test name',
							description => 'example test description',
							plan => 19;
		$self.init;
		$self.services;
		$self;
	}

	method services {
		$!loader.load-elements: $!mls = Root-Content.new: :$.driver;
		$!loader.load-elements: $!of = Original-Frame.new: :$.driver;
		$!loader.load-elements: $!rf = Replacement-Frame.new: :$.driver;
		$!loader.load-elements: $!nf = Nested-Frame.new: :$.driver;
	}

	method test {
		my Str:D @results =
				'main - uno',
				'main - due',
				'main - tre',
				'initial-frame - uno',
				'initial-frame - due',
				'initial-frame - tre',
				'replacement-frame - uno',
				'replacement-frame - due',
				'replacement-frame - tre',
				'nested-frame - uno',
				'nested-frame - due',
				'nested-frame - tre',
				;
		$!mls.open;
		self.is: 'main title', 'ml test', $.driver.title;
		self.is: 'main heading', 'example', $!mls.heading;
		$!mls.each-list-item: -> Root-Content $frame {
			self.is: 'main li', @results.shift, $frame.li.text;
		};

		self.is: 'original frame heading', 'example frame', $!of.heading;
		$!of.each-list-item: -> Original-Frame $frame {
			self.is: 'original frame li', @results.shift, $frame.li.text;
		};

		$!mls.open-other-frame;

		self.is: 'replacement frame heading', 'navigated frame', $!rf.heading;
		$!rf.each-list-item: -> Replacement-Frame $frame {
			self.is: 'replacement frame li', @results.shift, $frame.li.text;
		};

		self.is: 'nested frame heading', 'nested frame', $!nf.heading;
		$!nf.each-list-item: -> Nested-Frame $frame {
			self.is: 'nested frame li', @results.shift, $frame.li.text;
		};

		self.nok: 'all items found', @results.elems;

		$.driver.refresh;
	}
}

sub MAIN(
	Str $browser?,
	Int:D :$debug = 0
) {
	.execute with Example-Test.new: $browser, :$debug;
}
