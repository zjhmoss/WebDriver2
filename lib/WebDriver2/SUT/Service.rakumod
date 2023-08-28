use WebDriver2;
use WebDriver2::SUT::Tree;
#use WebDriver2::Test::Adapter;
use WebDriver2::Test::Debugging;
use WebDriver2::SUT::Navigator;
#use WebDriver2::SUT::Service::Loader;

unit role WebDriver2::SUT::Service; # does WebDriver2;

#has WebDriver2::Browser-Actions:D $!browser-actions is required handles <
#		start session maximize-window set-window-rect refresh title
#		alert-text accept-alert dismiss-alert send-alert-text
#		execute-script timeouts switch-to-parent top window-handles
#		curr-frame url delete-session stop
#>;
has WebDriver2::SUT::Tree::SUT $!sut;
has WebDriver2:D $!driver is required;
has WebDriver2::SUT::Tree::URL $.url is rw;
has WebDriver2::SUT::Tree::ANode %.elements is rw;

has Str:D $.prefix = '';
has Str:D $.key-prefix = '';

method name ( --> Str:D ) { ... }

method add-element ( Str $k, WebDriver2::SUT::Tree::ANode $v ) {
	warn "overwriting $k" if %!elements{ $k }:exists;
	%!elements{ $k } = "$!prefix$v";
}

method get ( Str:D $name --> WebDriver2::SUT::Tree::ANode:D ) {
	die "no element named $name" unless %!elements{ $name }:exists;
	%!elements{ $name };
}
