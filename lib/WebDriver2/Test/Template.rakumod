use Test;

use MIME::Base64;
use WebDriver2::Test::Adapter;
use WebDriver2::Test::Debugging;
use WebDriver2::Driver::Provider;
use WebDriver2::Test::Config-From-File;

unit role WebDriver2::Test::Template
		does WebDriver2::Test::Adapter
		does WebDriver2::Test::Debugging
		does WebDriver2::Test::Config-From-File;

my constant $PLAN = 2;
has IO::Path:D $.test-root is required;
has Int:D $.close-delay is rw = 3;
has Str $.browser;
has WebDriver2::Driver:D $.driver is required;

method plan ( --> Int ) { Int; }
method name ( --> Str:D ) { ... }
method description ( --> Str:D ) { ... }

multi method new ( WebDriver2::Test::Template:U: Str $browser is copy, IO::Path:D :$test-root, Int:D :$debug is copy = 0 ) {
	self.set-from-file: $browser, :$test-root, :$debug;
	self.bless:
			:$browser,
			:$test-root,
			:$debug,
			driver => WebDriver2::Driver::Provider.new( :$browser, :$debug ).driver;
}

method !init {
	self.lives-ok: 'session created', { $.driver.session };
	$.driver.set-window-rect: 1200, 750, 8, 8
		if $.browser eq 'chrome' | 'safari';
}
method pre-test { }
method test { ... }
method post-test { }
method !close {
	say "\nclosing in";
	.say, sleep 1 for ( 1 .. $.close-delay ).reverse;
	
	$.driver.delete-session;
}
#method !done-testing { done-testing }
method cleanup { }

method execute {
	try {
		plan $PLAN;
		self!init;
		
		self.subtest: Pair.new: $.name, {
			plan $.plan with $.plan;
			self.pre-test;
			self.test;
			self.post-test;
		};
		
		self!close;
		CATCH {
			default {
				.note;
				self.handle-error: $_;
				self.cleanup;
			}
		}
	}
	done-testing without $.plan;
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
