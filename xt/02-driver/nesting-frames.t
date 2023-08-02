use Test;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Test;
use WebDriver2::Test::Config-From-File;

use WebDriver2::Command::Element::Locator;
use WebDriver2::Command::Element::Locator::ID;
use WebDriver2::Command::Element::Locator::Tag-Name;

my $file = .add: 'lists.html' with $*PROGRAM.parent.parent.add: 'content';

class Test-Nav-To-Frame
		is WebDriver2::Test
		does WebDriver2::Test::Config-From-File
{
	method new ( Str $browser? is copy, Int :$debug is copy ) {
		self.set-from-file: $browser, $debug;
		self.bless:
				:$browser,
				:$debug,
				plan => 4,
				name => 'nesting frames',
				description => 'nesting frames tests';
	}
	method test {
		$.driver.navigate: 'file://' ~ $file.absolute;

		my WebDriver2::Model::Element $el = self.element-by-tag: 'h2';
		self.is: 'page h2', 'test', $el.text;

		my WebDriver2::Model::Element $frame0 =
				.frame with self.element-by-id: 'frame';
		$frame0.switch-to;

		$el = self.element-by-tag: 'h2';
		self.is: 'frame h2', 'list frame test', $el.text;

		my WebDriver2::Model::Element $frame1 =
				.frame with self.element-by-tag: 'iframe';
		$frame1.switch-to;

		$el = self.element-by-tag: 'h2';
		self.is: 'inner frame h2', 'internal frame', $el.text;

#		$frame0.switch-to;
#
#		$el = self.element-by-tag: 'h2';
#		self.is: 'frame h2', 'list frame test', $el.text;
#
#		self.top;
#
#		$el = self.element-by-tag: 'h2';
#		self.is: 'page h2', 'test', $el.text;
	}

	method element-by-id( Str $id ) {
		$.driver.element: WebDriver2::Command::Element::Locator::ID.new: $id
	}
	method element-by-tag( Str $tag ) {
		$.driver.element: WebDriver2::Command::Element::Locator::Tag-Name.new: $tag
	}
}

sub MAIN(
		Str $browser?,
		Int :$debug
) {
	.execute with Test-Nav-To-Frame.new: $browser, :$debug;
}
