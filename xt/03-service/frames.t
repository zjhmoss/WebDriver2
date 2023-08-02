use Test;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Command::Element::Locator::ID;
use WebDriver2::Command::Element::Locator::Tag-Name;

use WebDriver2::SUT::Build;
use WebDriver2::SUT::Service;

use WebDriver2::Test::Service-Test;
use WebDriver2::Test::Config-From-File;

my IO::Path $html-file =
		.add: 'lists.html' with $*PROGRAM.parent.parent.add: 'content';

class Frames-Test-Service does WebDriver2::SUT::Service {

	method name ( --> Str:D ) { 'frames' }

	method nav {
		my $url = WebDriver2::SUT::Tree::URL.new: 'file://' ~ $html-file;
		$!driver.navigate: $url.Str;
	}

	method page {
		$!driver;
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
		is WebDriver2::Test::Service-Test
		does WebDriver2::Test::Config-From-File # TODO : why include again ?
{
	has Frames-Test-Service $!service;
	has Str @!expected = <hey hi bye oye hola adios 喂 你好 再見>;

	method services ( WebDriver2::SUT::Service::Loader $loader ) {
		$!service = Frames-Test-Service.new: $loader;
	}

	method new ( Str $browser? is copy, Int :$debug is copy ) {
		self.set-from-file: $browser, $debug;
		callwith
				:$browser,
				:$debug,
				sut-name => 'frames',
				name => 'frames',
				description => 'tests nesting frames',
				plan => 35;
	}
	
	method test {
		$!service.nav;

		self.is:
				'mainline content parent frame is page',
				$!service.page,
				$!service.page-h2.parent-frame.resolve;
		self.is:
				'basic content parent frame is page',
				$!service.page,
			$!service.basic-item.parent-frame.resolve;
		self.is:
				'internal node parent frame is page',
				$!service.page,
				$!service.basic-nesting.parent-frame.resolve;
		$!service.each-basic: {
			self.is:
					'basic items',
					$!service.page,
					.basic-item.parent-frame.resolve;
		};
		$!service.each-outer: {
			$!service.each-inner: {
				self.is:
						'inner frame content correct',
						@!expected.shift,
						.inner-item.resolve.text;
				self.is:
						'inner item parent frame is page',
						$!service.page,
						.inner-item.parent-frame.resolve;

			}
		}
		self.is:
				'basic frame content parent frame is page',
				$!service.page,
				$!service.page-frame.parent-frame.resolve;
		self.is:
				'subframe content parent is frame',
				$!service.page-frame,
				$!service.frame-h2.parent-frame;
		self.is:
				'iframe beneath frame parent frame is frame',
				$!service.page-frame,
				$!service.iframe.parent-frame;
		self.is:
				'iframe h2 parent frame is iframe',
				$!service.iframe,
				$!service.iframe-h2.parent-frame;
		$!service.each-iframe-item: {
			self.is:
					'iframe list item parent frame is iframe',
					$!service.iframe,
					.iframe-item.parent-frame;
			self.is:
					'iframe list item h2 parent frame is iframe',
					$!service.iframe,
					.iframe-item-h2.parent-frame;
			self.is:
					'iframe list item p parent frame is iframe',
					$!service.iframe,
					.iframe-item-p.parent-frame;
		};
	}
}

sub MAIN(
		Str $browser?,
		Int :$debug
) {
	.execute with Frames-Test.new: $browser, :$debug;
}
