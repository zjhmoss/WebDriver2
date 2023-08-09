use lib <lib t/lib>;

use Test;

plan 47;

use-ok 'WebDriver2::SUT::Service::Loader';
use-ok 'WebDriver2::SUT::Build::Page';
use-ok 'WebDriver2::SUT::Tree';
use-ok 'WebDriver2::SUT::Service';
use-ok 'WebDriver2::SUT::ProviderR';
use-ok 'WebDriver2::SUT::Provider';
use-ok 'WebDriver2::SUT::Navigator';
use-ok 'WebDriver2::SUT::Build';
#use-ok 'WebDriver2::Command::Result::Factory::Chrome';
#use-ok 'WebDriver2::Command::Result::Factory::Edge';
#use-ok 'WebDriver2::Command::Result::Factory::Firefox';
use-ok 'WebDriver2::Command::Result::Factory::Safari';
use-ok 'WebDriver2::Command::Result::Factory';
use-ok 'WebDriver2::Command::Param::Factory::Chrome';
use-ok 'WebDriver2::Command::Param::Factory::Edge';
use-ok 'WebDriver2::Command::Param::Factory::Firefox';
use-ok 'WebDriver2::Command::Param::Factory::Safari';
use-ok 'WebDriver2::Command::Param::Factory';
use-ok 'WebDriver2::Command::Element::Locator::Xpath';
use-ok 'WebDriver2::Command::Element::Locator::Tag-Name';
use-ok 'WebDriver2::Command::Element::Locator::Link-Text';
use-ok 'WebDriver2::Command::Element::Locator::ID';
use-ok 'WebDriver2::Command::Element::Locator::CSS';
use-ok 'WebDriver2::Command::Element::Locator';
use-ok 'WebDriver2::Command::Result';
use-ok 'WebDriver2::Command::Param';
use-ok 'WebDriver2::Command::Keys';
use-ok 'WebDriver2::Command::Execution-Status';
use-ok 'WebDriver2::Driver::Server';
use-ok 'WebDriver2::Driver::Safari';
use-ok 'WebDriver2::Driver::Provider';
use-ok 'WebDriver2::Driver::Firefox';
use-ok 'WebDriver2::Driver::Edge';
use-ok 'WebDriver2::Driver::Chrome';

use-ok 'WebDriver2::Test::Config-From-File';
use-ok 'WebDriver2::Test::Locating-Test';
use-ok 'WebDriver2::Test::PO-Test';
use-ok 'WebDriver2::Test::PO-TestR';
use-ok 'WebDriver2::Test::Service-Test';
use-ok 'WebDriver2::Test::Service-TestR';
use-ok 'WebDriver2::Test::Template';
use-ok 'WebDriver2::Test::TestR';

use-ok 'WebDriver2::Until::SUT';
use-ok 'WebDriver2::Until::Command';
use-ok 'WebDriver2::Until';
use-ok 'WebDriver2::Test';
use-ok 'WebDriver2::Driver';
use-ok 'WebDriver2::Constants';
use-ok 'WebDriver2::Command';
use-ok 'WebDriver2';

done-testing;
