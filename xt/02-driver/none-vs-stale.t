use Test;

use lib <lib t/lib>;

use WebDriver2::Test::Template;
use WebDriver2::Command::Execution-Status;
use WebDriver2::Command::Element::Locator::ID;
use WebDriver2::Command::Element::Locator::Tag-Name;

my IO::Path $html-file =
		.add: 'test.html' with $*PROGRAM.parent.parent.add: 'content';

class Local
		does WebDriver2::Test::Template
		does WebDriver2::Test::Config-From-File
{
	
	has Int:D $.plan = 3;
	has Str:D $.name = 'none vs stale';
	has Str:D $.description = 'none and stale both handled';
	
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
		Int:D :$debug = 0
) {
	.execute with Local.new: $browser, :$debug;
}
