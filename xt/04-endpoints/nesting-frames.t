use Test;

use lib <lib t/lib>;

use WebDriver2::Test::Template;
use WebDriver2::Test::Locating-Test;

my $file = .add: 'lists.html' with $*PROGRAM.parent.parent.add: 'content';

class Test-Nav-To-Frame
		does WebDriver2::Test::Template
		does WebDriver2::Test::Locating-Test
{
	has Int:D $.plan = 35;
	has Str:D $.name = 'nesting frames';
	has Str:D $.description = 'nesting frames test';
	
	method test {
		$.driver.navigate: 'file://' ~ $file.absolute;
		
		self.nok: 'at page; no parent frame', $.driver.switch-to-parent.defined;
		self.page-content;
		
		# descend using tag
		.frame.switch-to with self.element-by-tag: 'iframe';
		self.frame0-content;
		
		.frame.switch-to with self.element-by-tag: 'iframe';
		self.frame1-content;
		
		$.driver.switch-to-parent;
		if $.browser eq 'safari' {
			skip 'safaridriver switch to parent frame bug', 2;
		} else {
			self.frame0-content;
		}
		
		$.driver.switch-to-parent;
		self.page-content;
		
		# at top and make sure frame switching stops at page
		self.nok: 'at page; no parent frame', $.driver.switch-to-parent.defined;
		self.page-content;
		
		# descend using id
		.frame.switch-to with self.element-by-id: 'frame';
		self.frame0-content;
		
		.frame.switch-to with self.element-by-id: 'internal';
		self.frame1-content;
		
		$.driver.switch-to-parent.switch-to-parent;
		# at top but no check for parent to make sure it doesn't affect results
		self.page-content;
		
		# descend using tag
		.frame.switch-to with self.element-by-tag: 'iframe';
		self.frame0-content;
		
		.frame.switch-to with self.element-by-tag: 'iframe';
		self.frame1-content;
		
		# TOP
		$.driver.top;
		self.nok: 'at page; no parent frame', $.driver.switch-to-parent.defined;
		self.page-content;
		
		# descend using id
		.frame.switch-to with self.element-by-id: 'frame';
		self.frame0-content;
		
		.frame.switch-to with self.element-by-id: 'internal';
		self.frame1-content;
		
		# TOP
		$.driver.top;
		# at top but no check for parent to make sure it doesn't affect results
		
		# descend using tag
		.frame.switch-to with self.element-by-tag: 'iframe';
		self.frame0-content;
		
		.frame.switch-to with self.element-by-tag: 'iframe';
		self.frame1-content;
	}
	
	method page-content {
		self.is: 'page h2', 'test', .text with self.element-by-tag: 'h2';
		self.is: 'li text', 'one', .text with self.element-by-tag: 'li';
	}
	
	method frame0-content {
		self.is:
				'frame h2',
				'list frame test',
				.text
				with self.element-by-tag: 'h2';
		self.is:
				'label text',
				'text input:',
				.text.trim
				with self.element-by-tag: 'label';
	}
	
	method frame1-content {
		self.is:
				'inner frame h2',
				'internal frame',
				.text
				with self.element-by-tag: 'h2';
		self.is: 'p text', 'first', .text with self.element-by-tag: 'p';
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Test-Nav-To-Frame.new: $browser, :$debug, test-root => 'xt'.IO;
}
