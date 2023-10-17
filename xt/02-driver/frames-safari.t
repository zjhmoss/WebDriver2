use Test;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Command::Element::Locator::ID;
use WebDriver2::Command::Element::Locator::Tag-Name;
use WebDriver2::Test::Template;
use WebDriver2::Test::Locating-Test;
use WebDriver2::SUT::Tree;

# can be file path or web address
my WebDriver2::SUT::Tree::URL:D $page =
		WebDriver2::SUT::Tree::URL.new: 'file://xt/content/lists.html';

class Local does WebDriver2::Test::Template {
	has Bool $!screenshot;
	
	has Int:D $.plan = 4;
	has Str:D $.name = 'nested frames';
	has Str:D $.description = 'basic frame navigation test for safari';
	
	# WebDriver2::Test::Template provides method new, which
	#   sets the browser / loads from file if not passed
	#   and instantiates the corresponding driver
	
	method test {
		$.driver.navigate: $page.Str;

		self.is: 'at page', 'test', .text with self.element-by-tag: 'h2';
#		is $.driver.title, 'test', 'page title';

		my WebDriver2::Model::Element $el = self.element-by-tag: 'iframe';
		$el.frame.switch-to;
		self.is: 'in first frame', 'list frame test', .text with self.element-by-tag: 'h2';
		$el = self.element-by-tag: 'iframe';
		$el.frame.switch-to;
		$el = self.element-by-tag: 'h2';
		self.is: 'in deepest frame', 'internal frame', $el.text;
		$.driver.switch-to-parent;
		$el = self.element-by-tag: 'h2';
		self.is: 'up one frame', 'list frame test', $el.text;
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
	.execute with Local.new: $browser, :$debug, test-root => 'xt'.IO;
}
