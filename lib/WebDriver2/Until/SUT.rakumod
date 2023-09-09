use WebDriver2::Until;
use WebDriver2::SUT::Tree;

class WebDriver2::Until::SUT::Present is WebDriver2::Until {
	method new(
			WebDriver2::SUT::Tree::Resolvable :$element,
			Real :$duration,
			Real :$interval,
			Bool :$soft,
			Int :$debug
	) {
		callwith
				operation => { $element.present },
				:$duration,
				:$interval,
				:$soft,
				:$debug;
	}
}
