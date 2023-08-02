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

my IO::Path $html-file =
		.add: 'test.html' with $*PROGRAM.parent.parent.add: 'content';

class Multi-Outer does WebDriver2::SUT::Service {
	method name ( --> Str:D ) { 'multi-outer' }

	method navigate {
		my $url = WebDriver2::SUT::Tree::URL.new: 'file://' ~ $html-file;
		$!driver.navigate: $url.Str;
	}

	method title {
		$!driver.title;
	}

	method inner-first {
		.resove.text with self.get: 'inner-first';
	}
}

class Multi-Form does WebDriver2::SUT::Service {
	method name ( --> Str:D ) { 'multi-form' }
	
	method form-text {
		.resolve.text with self.get: 'form-text';
	}
	method three-one {
		.resolve.text with self.get: 'iframe-three-one';
	}
}

class Multi-Service-Test
		is WebDriver2::Test::Service-Test
		does WebDriver2::Test::Config-From-File
{
	
	has Multi-Outer $!outer-service;
	has Multi-Form $!form-service;

	method new ( Str $browser? is copy, Int :$debug is copy ) {
		self.set-from-file: $browser, $debug;
		callwith
				:$browser,
				:$debug,
				sut-name => 'multi-service',
				name => 'multi-service',
				description => 'tests resolve and frames',
				plan => 5;
	}
	
	method services ( WebDriver2::SUT::Service::Loader $loader ) {
		$!outer-service = Multi-Outer.new: $loader;
		$!form-service = Multi-Form.new: $loader;
	}
	
	method test {
		$!outer-service.navigate;
		
		self.is: 'page title', 'test', $!outer-service.title;

		# test get main page element - retry before access
		my WebDriver2::Until $present = WebDriver2::Until::SUT::Present.new:
				element => $!outer-service.get( 'inner-first' ),
				duration => 5,
				interval => 1/100,
				:soft;
		$present.retry;

		# test get main page element - retry immediately after access
		$present = WebDriver2::Until::SUT::Present.new:
				element => $!outer-service.get( 'inner-first' ),
				duration => 5,
				interval => 1/100,
				:soft;

		# test get main page element - retry completely after access
		self.is:
				'inner first',
				'three - one',
				$!outer-service.get( 'inner-first' ).resolve.text;
		$present.retry;
		
		$present = WebDriver2::Until::SUT::Present.new:
				element => $!outer-service.get( 'inner-first' ),
				duration => 5,
				interval => 1/100,
				:soft;
		$present.retry;
		
		

		# test get inner element, outside frame - retry before access
		$present = WebDriver2::Until::SUT::Present.new:
				element => $!form-service.get( 'iframe-three-one' ),
				duration => 5,
				interval => 1/100,
				:soft;
		$present.retry;

		# test get inner element, outside frame - immediately after access
		$present = WebDriver2::Until::SUT::Present.new:
				element => $!form-service.get( 'iframe-three-one' ),
				duration => 5,
				interval => 1/100,
				:soft;
		
		self.is:
				'inner, outside frame',
				'tre - uno',
				$!form-service.get( 'iframe-three-one' ).resolve.text;
		$present.retry;
		
		# test get inner element, outside frame - completely after access
		$present = WebDriver2::Until::SUT::Present.new:
				element => $!form-service.get( 'iframe-three-one' ),
				duration => 5,
				interval => 1/100,
				:soft;
		$present.retry;
		
		

		# test get element inside frame - retry before access
		$present = WebDriver2::Until::SUT::Present.new:
				element => $!form-service.get( 'iframe-three-one' ),
				duration => 5,
				interval => 1/100,
				:soft;
		$present.retry;
		
		# test get element inside frame - retry immediately after access
		$present = WebDriver2::Until::SUT::Present.new:
				element => $!form-service.get( 'iframe-three-one' ),
				duration => 5,
				interval => 1/100,
				:soft;
		
		self.is:
				'inner, outside frame',
				'tre - uno',
				$!form-service.get( 'iframe-three-one' ).resolve.text;
		$present.retry;
		
		# test get element inside frame - retry before completely after access
		$present = WebDriver2::Until::SUT::Present.new:
				element => $!outer-service.get( 'inner-first' ),
				duration => 5,
				interval => 1/100,
				:soft;
		$present.retry;
	}
}

sub MAIN(
		Str $browser?,
		Int :$debug
) {
	.execute with Multi-Service-Test.new: $browser, :$debug;
}
