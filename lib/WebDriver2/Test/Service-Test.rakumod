use Test;

use MIME::Base64;

use WebDriver2;
use WebDriver2::Test::Config-From-File;
use WebDriver2::Test::PO-Test;
use WebDriver2::SUT::Service;
use WebDriver2::SUT::Service::Loader;

unit role WebDriver2::Test::Service-Test
		does WebDriver2::Test::PO-Test
		does WebDriver2::Test::Config-From-File
#		does WebDriver2::Test::Adapter
		does WebDriver2::Test::Debugging
		does WebDriver2::Driver::Provider;

has WebDriver2::SUT::Service::Loader $!loader;

method loader ( --> WebDriver2::SUT::Service::Loader:D ) {
	$!loader ||= WebDriver2::SUT::Service::Loader.new:
			:$.driver,
			:$.sut,
			:$.debug,
			:$.def-dir;
}

#method new (
##		Str   :$!browser,
##		Str:D :$!name,
##		Str:D :$!description,
##		Str:D :$!sut-name,
##		Int   :$!plan,
##		Int   :$!debug = 0,
#) {
##	callwith;
##	self.set-from-file: self.browser, self.debug;
##	self.init-sut: $!sut-name;
#	self.bless:
#		loader => WebDriver2::SUT::Service::Loader.new:
#				driver => self.driver,
#				browser => self.browser,
#				sut => self.sut,
#				debug => self.debug;
#}

method sut-name ( --> Str:D ) { !!! }

#method services ( WebDriver2::SUT::Service $service, Str:D $prefix = '', Str:D $key-prefix = '' ) {
##	return if $!loader;
##	self.services: $loader;
#	$service.elements = $!loader.load-elements: $service.name, $prefix, $key-prefix;
#}

#method init {
#	self.lives-ok: 'session created', { $.driver.session };
#	$.driver.set-window-rect: 1200, 750, 8, 8
#	if $.browser eq 'chrome' | 'safari';
#}

method pre-test { }
method test { ... }
method post-test { }
method close {
	say "\nclosing in";
	.say, sleep 1 for ( 1 .. $.close-delay ).reverse;
	
	$.driver.delete-session;
}
#multi method screenshot {
#	$.driver.screenshot;
#}
#
#multi method screenshot ( Str:D $name ) {
#	my $screenshot = self.screenshot;
#	unless $screenshot {
#		warn "no screenshot for $name";
#		return;
#	}
#	my Instant $now = now;
#	my $fn = $name.subst: /<-[a..zA..Z0..9_-]>+/, '-', :g;
#	IO::Path.new( $fn ~ '-' ~ $now.Date ~ '-' ~ $now.to-posix[0] ~ '.png' )
#			.spurt: MIME::Base64.decode: $screenshot;
#}
method handle-test-failure ( Str $descr ) {
	self.screenshot: $descr;
}

method handle-error ( Exception $x ) {
	$x.message.Str.note;
	self.screenshot: $x.message.Str;
}

#method done-testing { done-testing; }
method cleanup { self.close; }
