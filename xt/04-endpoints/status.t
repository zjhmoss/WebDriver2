use Test;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Test::Config-From-File;

use WebDriver2::Test::Template;
use WebDriver2::Command::Result;
use WebDriver2::Command::Execution-Status;

class Status-Test does WebDriver2::Test::Template {
	has Int:D $.plan = 6;
	has Str:D $.name = 'status';
	has Str:D $.description = 'status test';
	has IO::Path:D $.test-root = $*CWD.add: 'xt';
	
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
