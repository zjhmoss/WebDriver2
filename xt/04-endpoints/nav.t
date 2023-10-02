use Test;

use lib <lib t/lib>;

use PostCocoon::Url;

use WebDriver2;
use WebDriver2::Test::Config-From-File;

use WebDriver2::Until;
use WebDriver2::Test::Locating-Test;
use WebDriver2::Test::Template;
use WebDriver2::Command::Result;
use WebDriver2::Command::Execution-Status;

my IO::Path $html-from-file =
		.add: 'doc-login.html'
			with $*PROGRAM.parent.parent.add: 'content';
my IO::Path $html-to-file =
		.add: 'doc-main.html' with $*PROGRAM.parent.parent.add: 'content';

class Nav-Test
		does WebDriver2::Test::Template
		does WebDriver2::Test::Locating-Test
{
	has Int:D $.plan = 2;
	has Str:D $.name = 'URL tests';
	has Str:D $.description = 'test nav to URL and get URL';
	
	method test {
		$.driver.navigate: 'file://' ~ $html-from-file.absolute;
		
		self.is: 'navigation url result', self.prep-path( $html-from-file ),  url-decode $.driver.url; 
		my WebDriver2::Until $title =
				WebDriver2::Until::Title-Is.new:
						:$.driver,
						title => 'simple example';
		.click with self.element-by-tag: 'button';
		$title.retry;
		self.is:
				'browser follows link',
				self.prep-path( $html-to-file ) ~ '?user=&pass=&k=v',
				url-decode $.driver.url;
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
	.execute with Nav-Test.new: $browser, :$debug;
}
