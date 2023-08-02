use Test;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Test::Config-From-File;

use WebDriver2::Test;
use WebDriver2::Command::Result;
use WebDriver2::Command::Execution-Status;

class Browser-Window-Test is WebDriver2::Test does WebDriver2::Test::Config-From-File {
	method new ( Str $browser? is copy, Int :$debug is copy ) {
		self.set-from-file: $browser, $debug;
		self.bless:
				:$browser,
				:$debug,
				plan => 11,
				name => 'status',
				description => 'status test';
	}
	
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
		Int :$debug
) {
	.execute with Browser-Window-Test.new: $browser, :$debug;
}
