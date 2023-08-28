use Test;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Test::Config-From-File;

use WebDriver2::Test;
use WebDriver2::Command::Result;
use WebDriver2::Command::Execution-Status;

class Status-Test does WebDriver2::Test does WebDriver2::Test::Config-From-File {
	
	method new ( Str $browser? is copy, Int:D :$debug = 0 ) {
		self.set-from-file: $browser; # , $debug;
		my Status-Test:D $self =
				self.bless:
						:$browser,
						:$debug,
						plan => 7,
						name => 'status',
						description => 'status test';
		$self.init;
		$self;
	}
	
	method test {
		my WebDriver2::Command::Result::Status $status = $.driver.status;
		self.ok: 'version defined: ' ~ $status.version, $status.version.defined;
		if $.browser eq 'firefox' {
			skip 'firefox readiness is false';
		} else {
			self.ok: 'session ready', $status.ready;
		}
		self.is: 'execution status code 200', 200, $status.execution-status.code;
		self.is: 'execution status OK', WebDriver2::Command::Execution-Status::Type::OK, $status.execution-status.type;
		self.ok: 'execution status message defined: ' ~ $status.execution-status.message,
				$status.execution-status.message.defined;
		self.ok: 'message defined: ' ~ $status.message, $status.message.defined;
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Status-Test.new: $browser, :$debug;
}
