use Test;
use MIME::Base64;

use WebDriver2::Command::Element::Locator;
use WebDriver2::Test::Locating-Test;
use WebDriver2::Driver::Provider;
use WebDriver2::Test::Adapter;
use WebDriver2::Test::Template;
use WebDriver2::Test::Debugging;

unit role WebDriver2::Test
		does WebDriver2::Test::Adapter
		does WebDriver2::Test::Template
		does WebDriver2::Driver::Provider
		does WebDriver2::Test::Locating-Test
		does WebDriver2::Test::Debugging;

method init {
	self.lives-ok: 'session created', { $.driver.session };
	$.driver.set-window-rect: 1200, 750, 8, 8
		if $.browser eq 'chrome' | 'safari';
}

method handle-test-failure ( Str $descr ) {
	self.screenshot: $descr;
}

method handle-error ( Exception $x ) {
	.raku.say for $.driver.frames;
	self.screenshot: $x.WHAT.Str;
}

multi method screenshot {
	$.driver.screenshot;
}

multi method screenshot ( Str:D $name ) {
	my $screenshot = self.screenshot;
	unless $screenshot {
		warn "no screenshot for $name";
		return;
	}
	my Instant $now = now;
	my $fn = $name.subst: /<-[a..zA..Z0..9_-]>+/, '-', :g;
	IO::Path.new( $fn ~ '-' ~ $now.Date ~ '-' ~ $now.to-posix[0] ~ '.png' )
			.spurt: MIME::Base64.decode: $screenshot;
}



method cleanup {
	self.close;
}

method close {
	say "\nclosing in";
	.say, sleep 1 for ( 1 .. $.close-delay ).reverse;
	
	$.driver.delete-session;
}
