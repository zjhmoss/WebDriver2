use WebDriver2::HTTP::UserAgent;
use WebDriver2::HTTP::Request;
use JSON::Tiny;
use URI::Encode;
use WebDriver2::Driver::Server;
use WebDriver2;
use WebDriver2::Driver;
use WebDriver2::Command::Param::Factory;
use WebDriver2::Command::Param::Factory::Firefox;
use WebDriver2::Command::Result::Factory;
use WebDriver2::Command::Result::Factory::Firefox;

unit class WebDriver2::Driver::Firefox is WebDriver2::Driver;

method new(
		:$server = WebDriver2::Driver::Server.new( host => '127.0.0.1', port => 4444 ),
		:$debug = 0
) {
	self.bless(
			:$server,
			:$debug
	)
}

method param-factory( --> WebDriver2::Command::Param::Factory ) {
	$.param // WebDriver2::Command::Param::Factory::Firefox.new
}

method factory( --> WebDriver2::Command::Result::Factory ) {
	$.result // WebDriver2::Command::Result::Factory::Firefox.new
#	$.result // WebDriver2::Command::Result::Factory.new
}
