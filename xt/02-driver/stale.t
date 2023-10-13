use Test;

use lib 'lib', 't/lib';

use WebDriver2;
use WebDriver2::Until;
use WebDriver2::Until::Command;
use WebDriver2::Test::Template;
use WebDriver2::Test::Locating-Test;

my $html-file = .add: 'test.html' with $*CWD.add: <xt content>;

class Stale
		does WebDriver2::Test::Template
		does WebDriver2::Test::Locating-Test
{
	has Str:D $.sut-name = 'stale';
	has Int:D $.plan = 6;
	has Str:D $.name = 'stale';
	has Str:D $.description = 'stale handling';
	
	method test {
		self.driver.navigate: 'file://' ~ $html-file.absolute;
		is self.driver.title, 'test', 'page title';
		my WebDriver2::Model::Element $stale = self.element-by-id: 'cb';
		my WebDriver2::Model::Element $stale2 = self.element-by-id: 'text';
		my WebDriver2::Model::Element $stale3 = self.element-by-id: 'button';
		my WebDriver2::Model::Element $iframe = self.element-by-id: 'iframe';
		my WebDriver2::Model::Element $reachable = self.element-by-id: 'link-to-page';
		self.ok: 'element in iframe reachable from containing page', $reachable.enabled;
		$iframe.frame.switch-to;
		if $.browser ne 'firefox' {
			self.ok:
					'stale',
					.retry with WebDriver2::Until::Command::Stale.new: element => $stale, duration => 3,
			interval => 1 / 10;
			throws-like
					{
						$stale.click;
						$stale2.send-keys: 'hello';
						$stale3.value.say;
					},
					WebDriver2::Command::Result::X,
					'stale',
					execution-status => { .type ~~ WebDriver2::Command::Execution-Status::Type::Stale };
		} else {
			skip 'firefox stale / frame interaction', 2;
		}
		self.driver.top;
		$stale = self.element-by-id: 'link-to-page';
		my WebDriver2::Until $until-stale =
				WebDriver2::Until::Command::Stale.new:
						element => $stale,
						duration => 3,
						interval => 1 / 10;
		$stale.click;
		self.ok: 'link turned stale', $until-stale.retry;
#		$iframe.frame.switch-to;
		self.is:
				'new content available',
				'to page first',
				.text with self.element-by-id: 'page-to-heading-2';
	}
}

sub MAIN (
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Stale.new: $browser, :$debug, test-root => 'xt'.IO;
}
