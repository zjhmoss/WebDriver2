use v6;

unit class WebDriver2::Driver::Server;

has Str $.host;
has int $.port;

submethod BUILD( :$!host = '127.0.0.1', :$!port ) {
	;
}

# vim: set sw=4:
# vim: set ts=4:
