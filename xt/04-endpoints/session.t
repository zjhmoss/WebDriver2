use Test;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Test::Config-From-File;
use WebDriver2::Driver::Provider;

use WebDriver2::Test::Adapter;
use WebDriver2::Test::Debugging;

use WebDriver2::Command::Result;
use WebDriver2::Command::Execution-Status;

my IO::Path $html-file = .add: 'doc-main.html' with $*PROGRAM.parent.parent.add: 'content';

class Session-Test does WebDriver2::Test::Config-From-File does WebDriver2::Test::Adapter {
	has WebDriver2::Driver $.driver;
	has Str $.browser;
	has Int:D $.plan = 5;
	has Str:D $.name = 'status';
	has Str:D $.description = 'status test';
	has IO::Path:D $.test-root = $*CWD.add: 'xt';
	
	method new ( Str $browser is copy, Int:D :$debug = 0 ) {
		self.set-from-file: $browser;
		self.bless:
				:$browser,
				driver => WebDriver2::Driver::Provider.new( :$browser, :$debug ).driver,
				:$debug;
	}
	
	method execute {
		plan $!plan;
		if $.browser eq 'firefox' {
			skip 'geckodriver does not return valid JSON before session creation';
		} else {
			self.throws-like:
					'no title before session',
					WebDriver2::Command::Result::X:D,
					{ $.driver.title };
		}
		self.lives-ok: 'session created', { $.driver.session };
		self.nok: 'no title before navigation', $.driver.title;
		$.driver.navigate: 'file://' ~ $html-file.absolute;
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
	.execute with Session-Test.new: $browser, :$debug;
}
