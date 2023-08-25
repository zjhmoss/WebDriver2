use Test;

use lib <lib t/lib>;

use WebDriver2::Test::Service-Test;
use WebDriver2::SUT::Service::Loader;
use WebDriver2::SUT::Service;
use WebDriver2::SUT::Tree;

class Login-Service does WebDriver2::SUT::Service {
	has Str:D $.name = 'doc-login';

	my IO::Path $html-file =
			.add: 'doc-login.html'
	with $*PROGRAM.parent.parent.add: 'content';
	
	my WebDriver2::SUT::Tree::URL $url =
			WebDriver2::SUT::Tree::URL.new: 'file://' ~ $html-file.Str;

	method log-in ( Str:D $username, Str:D $password ) {
		$!driver.navigate: $url.Str;
		.resolve.send-keys: $username with self.get: 'username';
		.resolve.send-keys: $password with self.get: 'password';
		.resolve.click with self.get: 'login-button';
	}
}

class Main-Service does WebDriver2::SUT::Service {
	has Str:D $.name = 'doc-main';

	method interesting-text ( --> Str:D ) {
		my Str @text;
		@text.push: .resolve.text with self.get: 'heading';
		@text.push: .resolve.text with self.get: 'pf';
		@text.push: .resolve.text with self.get: 'pl';
		@text.join: "\n";
	}
	
	
}

class Form-Service does WebDriver2::SUT::Service {
	has Str:D $.name = 'doc-form';
	method value ( --> Str:D ) {
		.resolve.value with self.get: 'input';
	}
}

class Frame-Service does WebDriver2::SUT::Service {
	has Str:D $.name = 'doc-frame';
	
	method each-outer ( &cb ) {
		for self.get( 'outer' ).iterator {
			&cb( self );
		}
	}
	
	method each-inner ( &cb ) {
		for self.get( 'inner' ).iterator {
			&cb( self );
		}
	}
	
	method item-text ( --> Str:D ) {
		.resolve.text with self.get: 'inner';
	}
}

class Readme-Test is WebDriver2::Test::Service-Test {
	has Login-Service $!ls;
	has Main-Service $!ms;
	has Form-Service $!fs-main;
	has Form-Service $!fs-div;
	has Form-Service $!fs-frame;
	has Frame-Service $!frs;

	method new ( Str:D $browser = 'chrome', Int :$debug = 0 ) {
		callwith
				:$browser,
				:$debug,
				sut-name => 'doc-site',
				name => 'readme example',
				description => 'service / page object example',
				plan => 15;
	}

	method services ( WebDriver2::SUT::Service::Loader $loader ) {
		$!ls = Login-Service.new: $loader;
		$!ms = Main-Service.new: $loader;
		$!fs-main = Form-Service.new: $loader, '/iframe', 'iframe';
		$!fs-div = Form-Service.new: $loader, '/iframe/div', 'ifd';
		
		$!frs = Frame-Service.new: $loader;
	}

	method test {
		$!ls.log-in: 'user', 'pass';
		
		

		self.is:
				'interesting text',
				q:to /END/.trim,
				simple example
				text
				more text
				END
				$!ms.interesting-text;
		
		my Str:D @results =
				'Mirzakhani',
				'Noether',
				'Oh',
				'Delta',
				'Echo',
				'Foxtrot',
				'apple',
				'banana',
				'cantaloupe',
				;
		my Int $els = 9;
		my Bool:D $list-seen = False;
		$!frs.each-outer: {
			$list-seen = True;
			self.is: "correct number of elements left", $els, @results.elems;
			$!frs.each-inner: {
				self.is: "correct inner element : @results[0]", @results.shift,
					.item-text;
			}
			$els -= 3;
		}
		self.ok: 'outer', $list-seen;
	}
}

sub MAIN(
		Str:D $browser = 'chrome',
		Int :$debug = 0
) {
	.execute with Readme-Test.new: $browser, :$debug;
}
