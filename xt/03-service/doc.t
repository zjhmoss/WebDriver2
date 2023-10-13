use Test;

use lib <lib t/lib>;

#use WebDriver2::Test::Template;
use WebDriver2::Test::Service-Test;
#use WebDriver2::SUT::Service::Loader;
use WebDriver2::SUT::Service;
use WebDriver2::SUT::Tree;

class Login-Service does WebDriver2::SUT::Service {
	has Str:D $.name = 'doc-login';
	
	my IO::Path $html-file = $*CWD.add: <xt content doc-login.html>;
	
	my WebDriver2::SUT::Tree::URL $url =
			WebDriver2::SUT::Tree::URL.new: 'file://' ~ $html-file.Str;
	
	submethod BUILD ( WebDriver2::Driver:D :$!driver ) { }
	
	method log-in ( Str:D $username, Str:D $password ) {
		$!driver.navigate: $url.Str;
		.resolve.send-keys: $username with self.get: 'username';
		.resolve.send-keys: $password with self.get: 'password';
		.resolve.click with self.get: 'login-button';
	}
}

class Main-Service does WebDriver2::SUT::Service {
	has Str:D $.name = 'doc-main';
	
	submethod BUILD ( WebDriver2::Driver:D :$!driver ) { }
	
	method question ( --> Str:D ) {
		.resolve.text with self.get: 'question';
	}
	
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
	
	submethod BUILD ( WebDriver2::Driver:D :$!driver, Str:D :$!prefix = '' ) {}
	
	method value ( --> Str:D ) {
		.resolve.value with self.get: 'input';
	}
	method first ( &cb ) {
		for self.get('form').iterator {
			return self if &cb( self );
		}
		return Form-Service;
	}
	method each ( &action ) {
		for self.get( 'form' ).iterator {
			&action( self );
		}
	}
}

class Frame-Service does WebDriver2::SUT::Service {
	has Str:D $.name = 'doc-frame';
	
	submethod BUILD ( WebDriver2::Driver:D :$!driver ) { }
	
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

class Readme-Test does WebDriver2::Test::Service-Test {
	has Str:D $.sut-name = 'doc-site';
	has Int:D $.plan = 26;
	has Str:D $.name = 'readme example';
	has Str:D $.description = 'service / page object test example';
#	has IO::Path:D $.test-root = $*CWD.add: 'xt';
	has Login-Service $!ls;
	has Main-Service $!ms;
	has Form-Service $!fs-main;
	has Form-Service $!fs-div;
	has Form-Service $!fs-frame;
	has Frame-Service $!frs;
	
	method services {
		$.loader.load-elements: $!ls = Login-Service.new: :$.driver;
		$.loader.load-elements: $!ms = Main-Service.new: :$.driver;
		
		$.loader.load-elements: $!fs-main = Form-Service.new: :$.driver, prefix => '';
		$.loader.load-elements: $!fs-frame = Form-Service.new: :$.driver, prefix => '/iframe';
		$.loader.load-elements: $!fs-div = Form-Service.new: :$.driver, prefix => '/iframe/div';
		
		$.loader.load-elements: $!frs = Frame-Service.new: :$.driver;
	}
	
	method test {
		$!ls.log-in: 'user', 'pass';
		
		self.is: 'sub xpath', 'subelement test', .resolve.text with $!ms.get: 'subelement';
		
		my Int:D $i = 3;
		self.is:
				'correct object returned by find first',
				'main-3',
				.value with $!fs-main.first: { not --$i };
		
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
		self.is: '$els decremented', 0, $els;
		self.is: '@results empty', 0, @results.elems;
		
		@results = 'main-1', 'main-2', 'main-3', 'main-4';
		
		$!fs-main.each: { self.is: 'correct form element', @results.shift, .value };
		self.is: '@results empty', 0, @results.elems;
		
		self.is: 'first frame form is head', 'head', $!fs-frame.value;
		self.is: 'main page form', 'main-1', $!fs-main.first({ True; }).value;
		self.is: 'final frame form is foot', 'foot', $!fs-div.value;
	}
}

sub MAIN (
		Str $browser? is copy,
		Int :$debug = 0
) {
	.execute with Readme-Test.new: $browser, test-root => 'xt'.IO, :$debug;
}
