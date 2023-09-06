use WebDriver2;

use WebDriver2::SUT::Build;
use WebDriver2::SUT::Tree;
use WebDriver2::SUT::Service;
use WebDriver2::Test::Debugging;

use WebDriver2::SUT::Navigator;
#use WebDriver2::Test::Service-Test;

unit class WebDriver2::SUT::Service::Loader does WebDriver2::Test::Debugging;


my WebDriver2::SUT::Service::Loader $instance;

#my class Provider {
##	has Str:D $.browser is required;
#	has Int $.debug = 0;
#};

has IO::Path:D $!test-root is required;
has IO::Path:D $!def-dir is required;
has WebDriver2 $.driver;
has WebDriver2::SUT::Tree::SUT $!sut;

submethod BUILD (
#		:$!driver,
		:$!sut,
		:$!debug,
		:$!test-root,
		:$!def-dir
) { }



method new (
		WebDriver2::SUT::Tree::SUT :$sut,
		IO::Path:D :$test-root,
		Int:D :$debug = 0
#		WebDriver2:D :$driver
) {
	if $instance {
		note 'service loader instance exists; ignoring args.  ';
		#				~ "updating debug to $debug";
		#		$instance.debug = $debug;
		return $instance;
	}
	my IO::Path $def-dir = $test-root.add: 'def';
	$instance = self.bless: #`[ :$driver, ] :$sut, :$debug, :$test-root, :$def-dir;
}

method load-elements ( WebDriver2::SUT::Service:D $svc ) {
	my Str:D $prefix = $svc.prefix;
	my Str:D $key-prefix = $svc.key-prefix;
	my Str ( $k, $v );
	my WebDriver2::SUT::Tree::APage $page;
	my WebDriver2::SUT::Navigator $nav;
	my WebDriver2::SUT::Tree::ANode %elements;
#	my WebDriver2::SUT::Tree::URL $url;
	my Str $svc-fn = .[*- 1] with $svc.name.lc.split: '::';
	say 'LOADING ', $svc-fn if $!debug;
	for $!def-dir.add( "$svc-fn.service" ).lines -> Str $line {
		if $line ~~ /^\s*\#page\:\s*\S+/ {
			$page = $!sut.get: $line.split(/\:/, 2)[1].trim;
#			$url = $page.url;
			$nav = WebDriver2::SUT::Navigator.new: tree => $page, :$!debug;
			next;
		}
		next if $line ~~ /^\s*[\#.*]?\s*$/;
		die 'no page set' unless $nav and $page;
		($k, $v) = $line.split(/\:/, 2)>>.trim;
		$k = $key-prefix ~ '-' ~ $k if $key-prefix;
		die "element named $k already set" if %elements{$k}:exists;
		%elements{$k} = $nav.traverse: "$prefix$v";
	}
	$svc.elements = %elements;
}
