use WebDriver2::Driver::Server;

use WebDriver2::Driver;
use WebDriver2::Command::Param::Factory;
use WebDriver2::Command::Param::Factory::Chrome;
use WebDriver2::Command::Result::Factory;
#use WebDriver2::Command::Result::Factory::Chrome;

unit class WebDriver2::Driver::Chrome is WebDriver2::Driver;

method new(
		:$debug = 0,
		:$server = WebDriver2::Driver::Server.new: host => '127.0.0.1', port => 9515
) {
	self.bless:
			:$server,
			:$debug;
}

method param-factory( --> WebDriver2::Command::Param::Factory ) {
	$.param // WebDriver2::Command::Param::Factory::Chrome.new
}

method factory( --> WebDriver2::Command::Result::Factory ) {
#	$.result // WebDriver2::Command::Result::Factory::Chrome.new
	$.result // WebDriver2::Command::Result::Factory.new
}
