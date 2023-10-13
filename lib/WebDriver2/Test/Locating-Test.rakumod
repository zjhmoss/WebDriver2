use WebDriver2::Command::Element::Locator;
use WebDriver2::Command::Element::Locator::ID;
use WebDriver2::Command::Element::Locator::Tag-Name;
use WebDriver2::Command::Element::Locator::CSS;

unit role WebDriver2::Test::Locating-Test;

method locate-element ( WebDriver2::Command::Element::Locator $locator ) {
	self.driver.element: $locator;
}

method element-by-id ( Str:D $id ) {
	self.locate-element: WebDriver2::Command::Element::Locator::ID.new: $id;
}

method element-by-tag ( Str:D $tag ) {
	self.locate-element: WebDriver2::Command::Element::Locator::Tag-Name.new: $tag;
}

method elements-by-tag ( Str:D $tag ) {
	self.driver.elements: WebDriver2::Command::Element::Locator::Tag-Name.new: $tag;
}

method element-by-css-selector ( Str:D $selector ) {
	self.driver.element: WebDriver2::Command::Element::Locator::CSS.new: $selector;
}
