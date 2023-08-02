use Test;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Test;
use WebDriver2::Test::Config-From-File;
use WebDriver2::Command::Execution-Status;
use WebDriver2::Command::Element::Locator::ID;
use WebDriver2::Command::Element::Locator::Tag-Name;

my IO::Path $html-file =
		.add: 'test.html' with $*PROGRAM.parent.parent.add: 'content';

class Local is WebDriver2::Test does WebDriver2::Test::Config-From-File {
	has Bool $!screenshot;
	
	method new ( Str $browser is copy, Int :$debug is copy ) {
		self.set-from-file: $browser, $debug;
		self.bless:
				:$browser,
				:$debug,
				plan => 4,
				name => 'none vs stale',
				description => 'none and stale both handled';
	}
	
	method test {
		$.driver.set-window-rect( 1200, 750, 8, 8 ) if $.browser eq 'safari';
		$.driver.navigate: 'file://' ~ $html-file.absolute;
		
		ok
			self.element-by-id( 'outer' )
			~~ self.element-by-tag( 'ul' ),
			'same element found different ways';
		
		throws-like
				{ self.element-by-id: 'not here' },
				WebDriver2::Command::Result::X,
				'not found',
				execution-status => { .type ~~ WebDriver2::Command::Execution-Status::Type::Element };
		
		my $outer = self.element-by-id: 'outer';
		$outer.click;
		
		throws-like
				{ $outer.click },
				WebDriver2::Command::Result::X,
				'stale',
				execution-status => { .type ~~ WebDriver2::Command::Execution-Status::Type::Stale };
		
	}
	method element-by-tag( Str $tag-name ) {
		$.driver.element( WebDriver2::Command::Element::Locator::Tag-Name.new: $tag-name )
	}

	method element-by-id( Str $id ) {
		$.driver.element( WebDriver2::Command::Element::Locator::ID.new: $id )
	}
}

sub MAIN(
		Str $browser?,
		Int :$debug
) {
	.execute with Local.new: $browser, :$debug;
}
