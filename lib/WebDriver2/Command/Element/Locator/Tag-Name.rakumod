use v6;

use WebDriver2::Command::Element::Locator::CSS;

unit class WebDriver2::Command::Element::Locator::Tag-Name is WebDriver2::Command::Element::Locator;

method new( $selector ) {
	self.bless( strategy => 'tag name', :$selector );
}

# vim: set sw=4:
# vim: set ts=4:

