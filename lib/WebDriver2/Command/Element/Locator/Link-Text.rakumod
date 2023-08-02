use v6;

use WebDriver2::Command::Element::Locator;

unit class WebDriver2::Command::Element::Locator::Link-Text is WebDriver2::Command::Element::Locator;

method new( $selector ) {
	self.bless( strategy => 'link text', :$selector );
}
