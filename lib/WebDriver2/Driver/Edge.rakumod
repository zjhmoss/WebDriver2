use WebDriver2::HTTP::UserAgent;
use WebDriver2::HTTP::Request;
use JSON::Tiny;
use URI::Encode;
use WebDriver2::Driver::Server;
use WebDriver2;
use WebDriver2::Driver;
use WebDriver2::Command::Param::Factory;
use WebDriver2::Command::Param::Factory::Edge;
use WebDriver2::Command::Result::Factory;
use WebDriver2::Command::Result::Factory::Edge;

unit class WebDriver2::Driver::Edge is WebDriver2::Driver;

method new(
		:$server = WebDriver2::Driver::Server.new( host => 'localhost', port => 9515 ),
		:$debug = 0
) {
	self.bless(
			:$server,
			:$debug
	)
}

method param-factory( --> WebDriver2::Command::Param::Factory ) {
	$.param // WebDriver2::Command::Param::Factory::Edge.new
}

method factory( --> WebDriver2::Command::Result::Factory ) {
	$.result // WebDriver2::Command::Result::Factory::Edge.new
#	$.result // WebDriver2::Command::Result::Factory.new
}
