use WebDriver2::Command::Element::Locator;
use WebDriver2::Command::Element::Locator::ID;
use WebDriver2::Command::Element::Locator::Tag-Name;

unit role WebDriver2::Test::Locating-Test;

method locate-element ( WebDriver2::Command::Element::Locator $locator ) {
	self.driver.element: $locator;
}

method element-by-id ( Str:D $id ) {
	self.locate-element: WebDriver2::Command::Element::Locator::ID.new: $id;
}

method element-by-tag-name ( Str:D $tag ) {
	self.locate-element: WebDriver2::Command::Element::Locator::Tag-Name.new: $tag;
}
