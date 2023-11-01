use WebDriver2::HTTP::UserAgent;
use WebDriver2::HTTP::Request;
use JSON::Fast;
use URI::Encode;
use WebDriver2::Driver::Server;
use WebDriver2;
use WebDriver2::Driver;
use WebDriver2::Command::Param::Factory;
use WebDriver2::Command::Param::Factory::Safari;
use WebDriver2::Command::Result::Factory;
use WebDriver2::Command::Result::Factory::Safari;

unit class WebDriver2::Driver::Safari is WebDriver2::Driver;

method new(
		:$server = WebDriver2::Driver::Server.new( host => 'localhost', port => 7055 ),
		:$debug = 0
) {
	self.bless(
			:$server,
			:$debug
	)
}

method param-factory( --> WebDriver2::Command::Param::Factory ) {
	$.param // WebDriver2::Command::Param::Factory::Safari.new
}

method factory( --> WebDriver2::Command::Result::Factory ) {
	$.result // WebDriver2::Command::Result::Factory::Safari.new
}

method displayed ( WebDriver2::Model::Element:D $element --> Bool ) {
	say 'DISPLAYED OVERRIDDEN';
	return Bool;
}
