use v6;

use WebDriver2::Command::Element::Locator;

unit class WebDriver2::Command::Element::Locator::CSS is WebDriver2::Command::Element::Locator;

method new( $selector ) {
	self.bless( strategy => 'css selector', :$selector );
}

# vim: set sw=4:
# vim: set ts=4:
