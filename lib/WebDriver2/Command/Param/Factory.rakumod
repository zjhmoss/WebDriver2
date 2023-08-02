use WebDriver2::Command::Param;
use WebDriver2::Command::Element::Locator;
use WebDriver2::Constants;

unit class WebDriver2::Command::Param::Factory;

method session {
	{
#		desiredCapabilities => {},
#		requiredCapabilities => {}
		capabilities => {}
	}
}
method status { { } }
method current-url { { } }
method navigate( Str $url ) {
	{ :$url }
}
method refresh() { { } }
method maximize-window { { } }
method set-window-rect( Int $width, Int $height, Int $x, Int $y ) {
	{ :$width, :$height, :$x, :$y }
}
method accept-alert() { {} }
method dismiss-alert() { {} }
method send-alert-text( Str $text ) {
	{ :$text, data => $text, value => $text }
}
method element( WebDriver2::Command::Element::Locator $locator ) {
	$locator.as-data
}
method subelement( WebDriver2::Command::Element::Locator $locator ) {
	self.element( $locator )
}
method elements( WebDriver2::Command::Element::Locator $locator ) {
	self.element( $locator )
}
method subelements( WebDriver2::Command::Element::Locator $locator ) {
	self.subelement( $locator )
}
method element-rect { { } }
method execute-script ( Str $script, *@args ) {
	{ :$script, :@args }
}
method switch-to( WebDriver2::Command::Param::ID-or-Index $frame ) {
	 $frame.defined
			?? (
					$frame ~~ Int
							?? { id => $frame }
#							!! { id => { ELEMENT => $frame } }
							!! { id => Pair.new: ELEMENT-ID, $frame }
			)
			!! { id => Str }
}
method switch-to-parent { {} }
method send-keys( Str $keys ) {
	# FIXME : handle spec
	{ type => 'key', value => [ $keys.comb ], text => $keys }
}
method timeouts ( Int :$script, Int :$pageLoad, Int :$implicit ) {
	{
		:$script,
		:$pageLoad,
		:$implicit
	}
}
method clear { {} }
method click { {} }

method window-handle { {} }
method window-handles { {} }
method close-window { {} }
method switch-to-window ( Str:D $handle ) { { :$handle } }
method new-window { { 'type hint' => 'tab' } }
