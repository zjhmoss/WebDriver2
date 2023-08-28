use Test;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Command::Element::Locator::ID;
use WebDriver2::Command::Element::Locator::Tag-Name;

use WebDriver2::SUT::Tree;
use WebDriver2::SUT::Build;
use WebDriver2::SUT::Service;

use WebDriver2::Test::Service-Test;
use WebDriver2::Test::Config-From-File;

my IO::Path $html-file =
		.add: 'lists.html' with $*PROGRAM.parent.parent.add: 'content';

class Frames-Test-Service does WebDriver2::SUT::Service {
	
	submethod BUILD ( WebDriver2::Driver:D :$!driver, WebDriver2::SUT::Tree::SUT:D :$!sut ) { }

	method name ( --> Str:D ) { 'frames' }

	method nav {
		my $url = WebDriver2::SUT::Tree::URL.new: 'file://' ~ $html-file;
		$!driver.navigate: $url.Str;
	}

	method page {
		$!sut.get: self.name;
	}

	method page-frame {
		 self.get: 'page-frame';
	}

	method page-h2 {
		self.get: 'page-h2';
	}

	method frame-h2 {
		 self.get: 'frame-h2';
	}

	method basic-nesting {
		 self.get: 'basic';
	}

	method basic-item {
		 self.get: 'basic-item';
	}

	method outer-item {
		 self.get: 'outer-item';
	}

	method inner-item {
		 self.get: 'inner-item';
	}

	method each-basic ( &action ) {
		for self.get( 'basic-item' ).iterator {
			&action( self );
		}
	}

	method each-outer ( &action ) {
		for self.get( 'outer-item' ).iterator {
			&action( self );
		}
	}

	method each-inner ( &action ) {
		for self.get( 'inner-item' ).iterator {
			&action( self );
		}
	}

	method iframe {
		self.get: 'frame-frame';
	}

	method iframe-h2 {
		 self.get: 'iframe-h2';
	}

	method iframe-item {
		self.get: 'iframe-item';
	}

	method iframe-list-h2 {
		 self.get: 'iframe-list-h2';
	}

	method iframe-item-h2 {
		 self.get: 'iframe-list-h2';
	}

	method iframe-item-p {
		 self.get: 'iframe-list-p';
	}

	method each-iframe-item ( &action ) {
		for self.get( 'iframe-item' ).iterator {
			&action( self );
		}
	}
}

class Frames-Test
		does WebDriver2::Test::Service-Test
		does WebDriver2::Test::Config-From-File # TODO : why include again ?
{
	has Frames-Test-Service $!service;
	has Str @!expected = <hey hi bye oye hola adios 喂 你好 再見>;
	
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

	method services {
		$!loader.load-elements: $!service = Frames-Test-Service.new: :$.driver, :$!sut;
	}

	method new ( Str $browser? is copy, Int:D :$debug = 0 ) {
		self.set-from-file: $browser; # , $debug;
		my Frames-Test:D $self=
				callwith
						:$browser,
						:$debug,
						sut-name => 'frames',
						name => 'frames',
						description => 'tests nesting frames',
						plan => 36;
		$self.init;
		$self.services;
		$self;
	}
	
	method test {
		$!service.nav;

		self.is:
				'mainline content parent frame is page and context is body element',
#				$!service.page,
				'body',
				$!service.page-h2.parent-frame.resolve.tag-name;
		self.is:
				'page match',
				$!service.page.raku,
				$!service.page-h2.parent-frame.raku;
		self.is:
				'basic content parent frame is page and context is body element',
				$!service.page.raku,
#				'body',
				$!service.basic-item.parent-frame.raku; # .resolve.tag-name;
		
		self.is:
				'internal node parent frame is page',
				$!service.page.raku,
#				'body',
				$!service.basic-nesting.parent-frame.raku; # .resolve.tag-name;
		
		$!service.each-basic: {
			self.is:
					'basic items',
					$!service.page.raku,
					.basic-item.parent-frame.raku;
		};
		
		$!service.each-outer: {
			$!service.each-inner: {
				self.is:
						'inner frame content correct',
						@!expected.shift,
						.inner-item.resolve.text;
				self.is:
						'inner item parent frame is page',
						$!service.page.raku,
						.inner-item.parent-frame.raku; # .resolve;

			}
		}
		self.is:
				'basic frame content parent frame is page',
				$!service.page.raku,
				$!service.page-frame.parent-frame.raku; # .resolve;
		self.is:
				'subframe content parent is frame',
				$!service.page-frame.raku,
				$!service.frame-h2.parent-frame.raku;
		self.is:
				'iframe beneath frame parent frame is frame',
				$!service.page-frame.raku,
				$!service.iframe.parent-frame.raku;
		self.is:
				'iframe h2 parent frame is iframe',
				$!service.iframe.raku,
				$!service.iframe-h2.parent-frame.raku;
		
		$!service.each-iframe-item: {
			self.is:
					'iframe list item parent frame is iframe',
					$!service.iframe.raku,
					.iframe-item.parent-frame.raku;
			self.is:
					'iframe list item h2 parent frame is iframe',
					$!service.iframe.raku,
					.iframe-item-h2.parent-frame.raku;
			self.is:
					'iframe list item p parent frame is iframe',
					$!service.iframe.raku,
					.iframe-item-p.parent-frame.raku;
		};
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Frames-Test.new: $browser, :$debug;
}
