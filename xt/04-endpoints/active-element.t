use Test;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Until;
use WebDriver2::Test::Locating-Test;
use WebDriver2::Test::Template;
use WebDriver2::Command::Result;
use WebDriver2::Command::Execution-Status;
use WebDriver2::Command::Keys;

my IO::Path $html-file = .add: 'focus.html'
	with $*PROGRAM.parent.parent.add: 'content';

class Focus-Test
		does WebDriver2::Test::Template
		does WebDriver2::Test::Locating-Test
{
	has Int:D $.plan = 6;
	has Str:D $.name = 'focused element test';
	has Str:D $.description = 'tests active element endpoint';

	method test {
		$.driver.navigate: 'file://' ~ $html-file.absolute;
		
		self.cmp-ok: 'second input starts focused', self.element-by-id( 'two' ), &[~~], $.driver.active;
		self.cmp-ok: 'first input starts blurred', self.element-by-id( 'one' ), &[!~~], $.driver.active;
		self.cmp-ok: 'third input starts blurred', self.element-by-id( 'three' ), &[!~~], $.driver.active;
		self.cmp-ok: 'second input still focused', self.element-by-id( 'two' ), &[~~], $.driver.active;
		
		$.driver.active.send-keys: "2$WebDriver2::Command::Keys::TAB";
		self.cmp-ok: 'tab to third input', self.element-by-id( 'three' ), &[~~], $.driver.active;
		
		self.is: 'input received', '2', .value with self.element-by-id: 'two';
	}
	
	method prep-path ( IO::Path $path ) {
		return 'file://' ~ $path.absolute if $.browser eq 'safari';
		'file:///' ~ $path.absolute.subst: '\\', '/', :g;
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Focus-Test.new: $browser, :$debug;
}

