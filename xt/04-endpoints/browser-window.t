use Test;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Test::Config-From-File;

use WebDriver2::Test::Template;
use WebDriver2::Command::Result;
use WebDriver2::Command::Execution-Status;

class Browser-Window-Test does WebDriver2::Test::Template does WebDriver2::Test::Config-From-File {
	has Int:D $.plan = 10;
	has Str:D $.name = 'window';
	has Str:D $.description = 'multi-window test';
	has IO::Path:D $.test-root = $*CWD.add: 'xt';
	
#	method new ( Str $browser? is copy, Int:D :$debug = 0 ) {
#		self.set-from-file: $browser; # , $debug;
#		my Browser-Window-Test:D $self =
#				self.bless:
#						:$browser,
#						:$debug,
#						plan => 10,
#						name => 'status',
#						description => 'status test';
#		$self.init;
#		$self;
#	}
	
	method test {
		my Str $original-window = $.driver.original-window;
		self.is: 'current handle matches original', $original-window, $.driver.window-handle;
		my Str @windows = $.driver.window-handles;
		self.is: 'only one open', 1, @windows.elems;
		self.is: 'only one open matches original', $original-window, @windows[0];
		my %new-window = $.driver.new-window;
		self.is: 'new tab', 'tab', %new-window<type>;
		self.ok: 'new handle different from original',
				%new-window<handle> && ( %new-window<handle> ne $original-window );
		@windows = $.driver.window-handles;
		self.is: 'number of handles', 2, @windows.elems;
		my %windows = @windows.map: * => True;
		self.ok: 'original included', %windows{ $original-window }:exists;
		self.ok: 'new one included', %windows{ %new-window<handle> }:exists;
		$.driver.switch-to-window: %new-window<handle>;
		# TODO : check content
		$.driver.close-window;
		@windows = $.driver.window-handles;
		self.is: 'only one open again', 1, @windows.elems;
		self.is: 'only one open matches original', $original-window, @windows[0];
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Browser-Window-Test.new: $browser, :$debug;
}
