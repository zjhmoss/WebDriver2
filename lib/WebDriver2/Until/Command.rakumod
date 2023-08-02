use v6;

use WebDriver2;
use WebDriver2::Until;
use WebDriver2::Command::Execution-Status;
use WebDriver2::Command::Result;
#use WebDriver2::Command::Element::Locator;

role WebDriver2::Until::Command::Throwable #`( [::T] is T ) {
	method new (
			:&operation,
			WebDriver2::Command::Execution-Status::Type :$type,
			:&cleanup,
			Real :$duration,
			Real :$interval,
			Bool :$soft,
			Int :$debug
	) {
		callwith
				:&operation,
				exception => WebDriver2::Command::Result::X,
				matcher => -> $exception { $exception.status.type == $type },
				:&cleanup,
				:$duration,
				:$interval,
				:$soft,
				:$debug;
	}
}

#class WebDriver2::Until::Command::Throws does WebDriver2::Until::Command::Throwable[WebDriver2::Until::Throws] { }
#
#class WebDriver2::Until::Command::No-Throw does WebDriver2::Until::Command::Throwable[WebDriver2::Until::No-Throw] {
#
#}

class WebDriver2::Until::Command::Frame # is WebDriver2::Until::Command::No-Throw
		does WebDriver2::Until::Command::Throwable
{
	method new (
			WebDriver2:D :$driver,
			:&operation,
			:&cleanup,
			Real :$duration,
			Bool :$soft
	) {
		callwith
				:&operation,
				type => WebDriver2::Command::Execution-Status::Type::Frame,
				cleanup => {
					$driver.top;
					.() with &cleanup;
				},
				:$duration,
				:$soft;
	}
}

class WebDriver2::Until::Command::Displayed is WebDriver2::Until {
	method new(
			WebDriver2::Model::Element :$element,
			Real :$duration,
			Real :$interval,
			Bool :$soft,
			Int :$debug
	) {
		callwith
				operation => { $element.displayed; },
				:$duration,
				:$interval,
				:$soft,
				:$debug;
	}
}

class WebDriver2::Until::Command::Not-Displayed is WebDriver2::Until {
	method new(
			WebDriver2::Model::Element :$element,
			Real :$duration,
			Real :$interval,
			Bool :$soft,
			Int :$debug
	) {
		callwith
				operation => { not $element.displayed; },
				:$duration,
				:$interval,
				:$soft,
				:$debug;
	}
}

class WebDriver2::Until::Command::Value-Not-Empty is WebDriver2::Until {
	method new(
			WebDriver2::Model::Element :$element,
			Real :$duration,
			Real :$interval,
			Bool :$soft,
			Int :$debug
	) {
		callwith
				operation => { $element.value; },
				:$duration,
				:$interval,
				:$soft,
				:$debug;
	}
}

class WebDriver2::Until::Command::Value-To-Be is WebDriver2::Until {
	method new(
			WebDriver2::Model::Element :$element,
			Str :$value,
			Real :$duration,
			Real :$interval,
			Int :$debug
	) {
		callwith
				operation => { $element.value eq $value },
				:$duration,
				:$interval,
				:!soft,
				:$debug;
	}
}

class WebDriver2::Until::Command::Text-To-Be is WebDriver2::Until {
	method new(
			WebDriver2::Model::Element :$element,
			Str :$value,
			Real :$duration,
			Real :$interval,
			Int :$debug
	) {
		callwith
				operation => { $element.text eq $value },
				:$duration,
				:$interval,
				:!soft,
				:$debug;
	}
}

class WebDriver2::Until::Command::Stale is WebDriver2::Until {
	method new(
			WebDriver2::Model::Element :$element,
			Real :$duration,
			Real :$interval,
			Bool :$soft,
			Int :$debug = 0
	) {
		callwith
				operation => { $element.stale; },
				:$duration,
				:$interval,
				:$soft,
				:$debug;
	}
}

#class WebDriver2::Until::Command::Not-Stale is WebDriver2::Until {
#	method new(
#			WebDriver2::Model::Context :$context,
#			WebDriver2::Command::Element::Locator :$locator,
#			Real :$duration,
#			Real :$interval,
#			Bool :$soft,
#			Int :$debug
#	) {
#		callwith
#				operation => { not $context.element( $locator ).stale; },
#				:$duration,
#				:$interval,
#				:$soft,
#				:$debug;
#	}
#}
