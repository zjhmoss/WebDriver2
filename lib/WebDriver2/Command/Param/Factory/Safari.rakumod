use v6;

use WebDriver2::Command::Param::Factory;

unit class WebDriver2::Command::Param::Factory::Safari is WebDriver2::Command::Param::Factory;

method session {
	{
		capabilities => { alwaysMatch => {
#			:nativeEvents,
#			:javascriptEnabled,
			pageLoadStrategy => 'normal',
			timeouts =>
				{ script => 30_000, pageLoad => 300_000, implicit => 10_000 }
		} }
	}
}
