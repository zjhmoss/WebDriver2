unit class WebDriver2::Command::Element::Locator;

subset Strategy of Str where any(
		'css selector',
		'link text',
		'partial link text',
		'tag name',
		'xpath'
);

has Strategy $!strategy is required;
has Str $!selector is required;

submethod BUILD( :$!strategy, :$!selector ) { }

method as-data() {
say "using => $!strategy, value => $!selector";
	{ using => $!strategy.Str, value => $!selector }
}

method Str( --> Str ) {
	return self.raku if not self.defined;
	"$!strategy : $!selector"
}

# vim: set sw=4:
# vim: set ts=4:
