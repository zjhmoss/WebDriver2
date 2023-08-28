use Test;

use lib <lib t/lib>;

use WebDriver2::Test;
use WebDriver2::Test::Config-From-File;

my IO::Path $html-file =
		.add: 'alerts.html' with $*PROGRAM.parent.parent.add: 'content';

class Alerts does WebDriver2::Test does WebDriver2::Test::Config-From-File {
	
	method new ( Str $browser? is copy, Int:D :$debug = 0 ) {
		self.set-from-file: $browser;
		my Alerts:D $self =
				self.bless:
						:$browser,
						:$debug,
						plan => 9,
						name => 'alerts',
						description => 'js alerts';
		$self.init;
		$self;
	}
	
	method test {
		$.driver.navigate: 'file://' ~ $html-file.absolute;

		sleep 1;

		is $.driver.alert-text, 'one', 'alert text one';

		$.driver.accept-alert;
		sleep 1;

		is $.driver.alert-text, 'two', 'alert text two';

		$.driver.dismiss-alert;
		sleep 1;

		is $.driver.alert-text, 'yes', 'confirm text yes';

		$.driver.accept-alert;
		sleep 1;

		is $.driver.alert-text, 'no', 'confirm text no';

		$.driver.dismiss-alert;
		sleep 1;

		is $.driver.alert-text, 'ok', 'prompt text ok';

		$.driver.send-alert-text: 'ok response';
		sleep 1;
		$.driver.accept-alert;
		sleep 1;

		is $.driver.alert-text, 'ok response', 'response recorded';

		$.driver.accept-alert;
		sleep 1;

		is $.driver.alert-text, 'cancel', 'prompt text cancel';

		sleep 1;
		$.driver.send-alert-text: 'cancel response';
		sleep 1;
		$.driver.dismiss-alert;

		sleep 1;

		is $.driver.alert-text, 'null', 'response not recorded';

		$.driver.dismiss-alert;
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Alerts.new: $browser, :$debug;
}

