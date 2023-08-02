use v6;

use WebDriver2::Command::Param::Factory;

unit class WebDriver2::Command::Param::Factory::Firefox is WebDriver2::Command::Param::Factory;

method session {
	{
#		desiredCapabilities => { 'unhandledPromptBehavior' => 'ignore' },
#		requiredCapabilities => {}
		capabilities => { alwaysMatch => { browserName => 'firefox' } }
	}
}
