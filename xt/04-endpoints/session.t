use Test;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Test::Template;
use WebDriver2::Driver::Provider;

use WebDriver2::Test::Adapter;
use WebDriver2::Test::Debugging;

use WebDriver2::Command::Result;
use WebDriver2::Command::Execution-Status;

my IO::Path $html-file = .add: 'doc-main.html' with 'content'.IO;

class Session-Test does WebDriver2::Test::Template {
#	has WebDriver2::Driver $.driver;
#	has Str $.browser;
	has Str:D $.sut-name = 'session';
	has Int:D $.plan = 3;
	has Str:D $.name = 'session';
	has Str:D $.description = 'session test';
	
	method test {
#		plan $!plan;
#		if $.browser eq 'firefox' {
#			skip 'geckodriver does not return valid JSON before session creation';
#		} else {
##			self.throws-like:
#			self.nok:
#					'no title before session',
#					$.driver.title;
##					WebDriver2::Command::Result::X:D,
##					{ $.driver.title };
#		}
#		self.lives-ok: 'session created', { $.driver.session };
		my IO::Path:D $html-file = $!test-root.add: <content doc-main.html>;
		my Str:D $url = 'file://' ~ $html-file.absolute;
		self.nok: 'no title before navigation', $.driver.title;
		$.driver.navigate: $url;
		self.is: 'title after navigation', 'simple example', $.driver.title;
		$.driver.delete-session;
		if $.browser eq 'firefox' {
			self.throws-like:
					'no title after session deletion',
					WebDriver2::Command::Result::X:D,
					{ $.driver.title },
					message => rx:m :s/.*error\"\s*\:\s*\"invalid session id.*/;
		} elsif $.browser eq 'safari' {
			self.throws-like:
					'no title after session deletion',
					WebDriver2::Command::Result::X:D,
					{ $.driver.title },
					message => *.contains: 'invalid session id';
		} else {
			self.throws-like:
					'no title after session deletion',
					WebDriver2::Command::Result::X:D,
					{ $.driver.title },
					message => "Session\ninvalid session id";
		}
		$.driver.session;
		done-testing;
	}
	
	method handle-test-failure ( Str:D $description ) {
#		warn $description;
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Session-Test.new: $browser, :$debug, test-root => 'xt'.IO;
}
