use WebDriver2::Command::Element::Locator;

unit class WebDriver2::Command::Element::Locator::Xpath is WebDriver2::Command::Element::Locator;

method new( $selector ) {
	self.bless( strategy => 'xpath', :$selector );
}
