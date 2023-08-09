use v6;

use WebDriver2::Command::Element::Locator::CSS;

unit class WebDriver2::Command::Element::Locator::ID
		is WebDriver2::Command::Element::Locator::CSS;

method new( $selector ) {
	self.bless( strategy => 'css selector', selector => "#$selector" );
}

# vim: set sw=4:
# vim: set ts=4:
