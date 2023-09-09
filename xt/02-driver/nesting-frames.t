use Test;

use lib <lib t/lib>;

use WebDriver2::Test::Template;

use WebDriver2::Command::Element::Locator;
use WebDriver2::Command::Element::Locator::ID;
use WebDriver2::Command::Element::Locator::Tag-Name;

my $file = .add: 'lists.html' with $*PROGRAM.parent.parent.add: 'content';

class Test-Nav-To-Frame does WebDriver2::Test::Template {
	has Int:D $.plan = 3;
	has Str:D $.name = 'nesting frames';
	has Str:D $.description = 'nesting frames test';
	
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
		Int:D :$debug = 0
) {
	.execute with Test-Nav-To-Frame.new: $browser, :$debug;
}
