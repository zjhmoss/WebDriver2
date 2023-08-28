use WebDriver2::HTTP::UserAgent;
use WebDriver2::HTTP::Message;
use WebDriver2::HTTP::Request;
use JSON::Tiny;
use URI::Encode;
use WebDriver2::Driver::Server;
use WebDriver2;

use WebDriver2::Command;
use WebDriver2::Command::Param;
use WebDriver2::Command::Result;
use WebDriver2::Command::Param::Factory;
use WebDriver2::Command::Result::Factory;

use WebDriver2::Constants;

my class WebDriver2::Internal-Element does WebDriver2::Model::Element { ... }
my class WebDriver2::Internal-Frame does WebDriver2::Model::Frame { ... }

class WebDriver2::Driver does WebDriver2 {
	
	trusts WebDriver2::Internal-Element;
	trusts WebDriver2::Internal-Frame;
	
	# TODO : keep result queue when debugging ?
	
	has Str $.original-window;

	has WebDriver2::Driver::Server $.server is required;
	has WebDriver2::Command::Param::Factory $.param = self.param-factory;
	has WebDriver2::Command::Result::Factory $.result = self.factory;
	has WebDriver2::Command::Param::ID-or-Index @.frames; # FIXME : make private

	submethod BUILD(
			:$!server,
			Int :$!debug = 2
	) {
		my Bool $throw-exceptions = ( $!debug >= 4 );
		$!ua = (
			$!debug
				?? WebDriver2::HTTP::UserAgent.new( #`( :$throw-exceptions, ) :$!debug )
				!! WebDriver2::HTTP::UserAgent.new
		);
	}
	
	method param-factory( --> WebDriver2::Command::Param::Factory ) { ... }
	
	method factory( --> WebDriver2::Command::Result::Factory ) { ... }

	method start { }

	multi method debug( WebDriver2::Command::PreResult $result, *@data ) {
		say $result.Str if $!debug >= 1;
		if $!debug { .say for @data };
	}

	multi method debug( WebDriver2::Command::Result $result, *@data ) {
		callsame;
		say $result.execution-status if $!debug;
	}

	method !ready( --> Bool ) {
		my WebDriver2::Command::Result::Status $status =
				WebDriver2::Command::Status.new
				.execute-with: self;
		self.debug( $status, $status.version, $status.ready );
		return $status.ready;
	}
	
	method curr-frame( --> WebDriver2::Command::Param::ID-or-Index ) {
		@!frames ?? @!frames[ * - 1 ] !! WebDriver2::Command::Param::ID-or-Index
	}
	
	method push-frame ( WebDriver2::Command::Param::ID-or-Index:D $frame ) {
		say "pushing $frame onto", @!frames.join: '\n' if $!debug;
		@!frames.push: $frame;
	}

	method session {
		for 1 .. 3 {
			if self!ready() {
				my WebDriver2::Command::Result::Session $session =
					WebDriver2::Command::Session.new
						.execute-with: self;
				self.debug: $session, $session.value;
				$!session-id = $session.value;
				$!original-window = self.window-handle;
				return $!session-id;
			}
		}
	}
	
	method status {
		my WebDriver2::Command::Result::Status $status =
				WebDriver2::Command::Status.new.execute-with: self;
		self.debug: $status;
		$status;
	}

	method maximize-window {
		my WebDriver2::Command::Result::Maximize-Window $max-win =
			WebDriver2::Command::Maximize-Window.new.execute-with: self;
		self.debug: $max-win;
	}

	method set-window-rect( Int $width, Int $height, Int $x, Int $y ) {
		my WebDriver2::Command::Result::Set-Window-Rect $wind-rect =
			WebDriver2::Command::Set-Window-Rect.new( :$width, :$height, :$x, :$y )
				.execute-with: self;
		self.debug: $wind-rect;
	}

	method navigate( Str:D $url ) {
		@!frames = Empty;
		my WebDriver2::Command::Result::Navigate $navigate =
			WebDriver2::Command::Navigate.new( :$url )
				.execute-with: self;
		self.debug: $navigate;
	}
	
	method refresh {
		my WebDriver2::Command::Result::Refresh $refresh =
			WebDriver2::Command::Refresh.new
				.execute-with: self;
		self.debug: $refresh;
	}
	
	multi method screenshot( WebDriver2: --> Str:D ) {
		my WebDriver2::Command::Result::Screenshot $screenshot =
			WebDriver2::Command::Screenshot.new
				.execute-with: self;
		self.debug: $screenshot; # , $screenshot.value;
		return $screenshot.value;
	}
	
	method !screenshot( Str:D $element --> Str:D ) {
		my WebDriver2::Command::Result::Element-Screenshot $screenshot =
			WebDriver2::Command::Element-Screenshot.new( :$element )
				.execute-with: self
		;
		self.debug: $screenshot; # , $screenshot.value;
		return $screenshot.value;
	}
	
	multi method screenshot( WebDriver2::Model::Element:D $element --> Str:D ) {
		$element.screenshot
	}

	method title( --> Str:D ) {
		my WebDriver2::Command::Result::Title $title =
			WebDriver2::Command::Title.new
				.execute-with: self;
		self.debug: $title, $title.value;
		return $title.value;
	}
	
	method alert-text( --> Str:D ) {
		my WebDriver2::Command::Result::Alert-Text $alert-text =
			WebDriver2::Command::Alert-Text.new
				.execute-with: self;
		self.debug: $alert-text, $alert-text.value;
		return $alert-text.value;
	}
	
	method accept-alert {
		my WebDriver2::Command::Result::Accept-Alert $accept-alert =
			WebDriver2::Command::Accept-Alert.new
				.execute-with: self;
		self.debug: $accept-alert
	}
	
	method dismiss-alert {
		my WebDriver2::Command::Result::Dismiss-Alert $dismiss-alert =
			WebDriver2::Command::Dismiss-Alert.new
				.execute-with: self;
		self.debug: $dismiss-alert
	}
	
	method send-alert-text( Str:D $text ) {
		my WebDriver2::Command::Result::Send-Alert-Text $send-alert-text =
			WebDriver2::Command::Send-Alert-Text.new( :$text )
				.execute-with: self;
		self.debug: $send-alert-text
	}
	
	multi method element(
			WebDriver2::Command::Element::Locator:D $locator
			--> WebDriver2::Model::Element:D
	) {
		my WebDriver2::Command::Result::Element $element =
			WebDriver2::Command::Element.new( :$locator )
				.execute-with: self;
#		$element.raku.say;
		self.debug: $element, $element.value;
		return WebDriver2::Internal-Element.new(
				driver => self,
				internal-id => $element.value
		);
	}

	method !element(
			Str:D $context,
			WebDriver2::Command::Element::Locator:D $locator
			--> WebDriver2::Model::Element:D
	) {
		my WebDriver2::Command::Result::SubElement $element =
			WebDriver2::Command::SubElement.new( :$context, :$locator )
				.execute-with: self;
		self.debug: $element, $element.value;
		return WebDriver2::Internal-Element.new(
				driver => self,
				internal-id => $element.value
		);
	}

	multi method element(
			WebDriver2::Model::Context:D $context,
			WebDriver2::Command::Element::Locator:D $locator
			--> WebDriver2::Model::Element:D
	) {
		$context.element( $locator )
	}
	
	multi method elements(
			WebDriver2::Command::Element::Locator:D $locator
			--> Array of WebDriver2::Model::Element
	) {
		my WebDriver2::Command::Result::Elements $element =
			WebDriver2::Command::Elements.new( :$locator )
				.execute-with: self;
		self.debug: $element, $element.values;
		my WebDriver2::Model::Element @el;
		@el.push: WebDriver2::Internal-Element.new(
				driver => self,
				internal-id => $_
		) for $element.values[*];
		return @el;
	}

	method !elements(
			Str:D $context,
			WebDriver2::Command::Element::Locator:D $locator
			--> Array of WebDriver2::Model::Element
	) {
		my WebDriver2::Command::Result::SubElements $element =
			WebDriver2::Command::SubElements.new( :$context, :$locator )
				.execute-with: self;
		self.debug: $element, $element.values;
		my WebDriver2::Model::Element @el;
		@el.push: WebDriver2::Internal-Element.new(
				driver => self,
				internal-id => $_
		) for $element.values[*];
		return @el;
	}

	multi method elements(
			WebDriver2::Model::Context:D $context,
			WebDriver2::Command::Element::Locator:D $locator
			--> Array of WebDriver2::Model::Element
	) {
		$context.elements: $locator
	}

	method !element-rect( Str:D $element --> Hash of Int ) {
		my WebDriver2::Command::Result::Element-Rect $rect =
			WebDriver2::Command::Element-Rect.new( :$element ).execute-with: self;
		self.debug: $rect, $rect.x, $rect.y, $rect.width, $rect.height;
		my Int %rect;
		%rect<x> = $rect.x;
		%rect<y> = $rect.y;
		%rect<width> = $rect.width;
		%rect<height> = $rect.height;
		%rect
	}

	method element-rect( WebDriver2::Model::Element:D $element --> Hash of Int ) {
		$element.rect
	}

	method execute-script( Str:D $script, @args ) {
		my WebDriver2::Command::Result::Execute-Script $script-result =
			WebDriver2::Command::Execute-Script.new( :$script, :@args )
				.execute-with: self;
		self.debug: $script-result, $script-result.value.flat;
	}
	
	method active( --> WebDriver2::Model::Element:D ) {
		my WebDriver2::Command::Result::Active $active =
			WebDriver2::Command::Active.new
				.execute-with: self;
		self.debug: $active, $active.value;
		return WebDriver2::Internal-Element.new(
				driver => self,
				internal-id => $active.value
		);
	}
	
	method frame( WebDriver2::Model::Element $element --> WebDriver2::Model::Frame ) {
		if $element.tag-name.lc eq 'frame' | 'iframe' {
#			self.push-frame: $element.internal-id;
.say for @!frames;
			return WebDriver2::Internal-Frame.new: $element, $!debug;
		}
		note 'no conversion to frame';
		# TODO : raise exception
	}
	
	method !tag-name( Str:D $element --> Str:D ) {
		say "getting tag name for $element" if $!debug;
		my WebDriver2::Command::Result::Tag-Name $tag-name =
			WebDriver2::Command::Tag-Name.new( :$element )
				.execute-with: self;
		self.debug: $tag-name, $tag-name.value;
		return $tag-name.value;
	}
	
	method tag-name( WebDriver2::Model::Element:D $element --> Str:D ) {
		$element.tag-name.lc
	}
	
	method !property(
			Str:D $element,
			Str:D $property
			--> WebDriver2::Command::Result::Property::Prop-Val
	) {
		my WebDriver2::Command::Result::Property $property-value =
			WebDriver2::Command::Property.new( :$element, :$property )
				.execute-with: self;
		self.debug: $property-value, $property-value.value;
		return $property-value.value;
	}

	method property( WebDriver2::Model::Element:D $element, Str:D $property --> Str ) {
		$element.property( $property )
	}

	method !attribute( Str:D $element, Str:D $attribute --> Str ) {
		my WebDriver2::Command::Result::Attribute $attribute-value =
			WebDriver2::Command::Attribute.new( :$element, :$attribute )
				.execute-with: self;
		self.debug: $attribute-value, $attribute-value.value;
		return $attribute-value.value;
	}

	method attribute( WebDriver2::Model::Element:D $element, Str:D $attribute --> Str ) {
		$element.attribute: $attribute
	}

	method !id( Str:D $element --> Str ) {
		self!attribute: $element, 'id'
	}

	method id( WebDriver2::Model::Element:D $element --> Str ) {
		$element.id
	}
	
	method !value( Str:D $element --> Str ) {
		self!property: $element, 'value'
	}

	method value( WebDriver2::Model::Element:D $element --> Str ) {
		$element.value
	}
	
	method !text( Str:D $element --> Str:D ) {
		my WebDriver2::Command::Result::Text $text =
			WebDriver2::Command::Text.new( :$element )
				.execute-with: self;
		self.debug: $text, $text.value;
		return $text.value;
	}
	
	method text( WebDriver2::Model::Element:D $element --> Str:D ) {
		$element.text
	}

	method !displayed( Str:D $element --> Bool ) {
		return Bool if $.browser eq 'safari';
		my WebDriver2::Command::Result::Displayed $displayed =
			WebDriver2::Command::Displayed.new( :$element )
				.execute-with: self;
		self.debug: $displayed, $displayed.value;
		return $displayed.value;
	}

	method displayed( WebDriver2::Model::Element:D $element --> Bool ) {
		$element.displayed
	}
	
	method !enabled( Str:D $element --> Bool:D ) {
		my WebDriver2::Command::Result::Enabled $enabled =
			WebDriver2::Command::Enabled.new( :$element )
				.execute-with: self;
		self.debug: $enabled, $enabled.value ~ ' VALUE';
		return $enabled.value;
	}
	
	method enabled( WebDriver2::Model::Element:D $element --> Bool:D ) {
		$element.enabled
	}
	
	method !selected( Str:D $element --> Bool:D ) {
		my WebDriver2::Command::Result::Selected $selected =
			WebDriver2::Command::Selected.new( :$element )
				.execute-with: self;
		self.debug: $selected, $selected.value;
		return $selected.value;
	}
	
	method selected( WebDriver2::Model::Element:D $element --> Bool:D ) {
		$element.selected
	}
	
	method !css-value( Str:D $element, Str:D $property --> Str ) {
		my WebDriver2::Command::Result::CSS-Value $css-value =
			WebDriver2::Command::CSS-Value.new( :$element, :$property )
				.execute-with: self;
		self.debug: $css-value, $css-value.value;
		return $css-value.value;
	}
	
	method css-value( WebDriver2::Model::Element:D $element, Str:D $property --> Str ) {
		$element.css-value: $property
	}

	method !send-keys( Str:D $element, Str:D $keys ) {
		my WebDriver2::Command::Result::Send-Keys $send-keys =
			WebDriver2::Command::Send-Keys.new( :$element, :$keys )
				.execute-with: self;
		self.debug: $send-keys;
	}

	method send-keys( WebDriver2::Model::Element:D $element, Str:D $keys ) {
		$element.send-keys: $keys;
	}
	
	method timeouts( Int :$script, Int :$pageLoad, Int :$implicit ) {
		my WebDriver2::Command::Result::Timeouts $timeouts =
			WebDriver2::Command::Timeouts.new( :$script, :$pageLoad, :$implicit )
					.execute-with: self;
		self.debug: $timeouts;
	}
	
	method !clear( Str:D $element ) {
		my WebDriver2::Command::Result::Clear $clear =
			WebDriver2::Command::Clear.new( :$element )
				.execute-with: self;
		self.debug: $clear;
	}
	
	method clear( WebDriver2::Model::Element:D $element ) {
		$element.clear
	}

	method !click( Str:D $element ) {
		my WebDriver2::Command::Result::Click $click =
			WebDriver2::Command::Click.new( :$element )
				.execute-with: self;
		self.debug: $click;
	}

	method click( WebDriver2::Model::Element:D $element ) {
		$element.click
	}
	
	method !switch-to( WebDriver2::Command::Param::ID-or-Index $frame ) {
		say 'SWITCH TO  ' ~ $frame.gist if $!debug;
		( @!frames.say, ( .say for @!frames ) ) if $!debug;
		my WebDriver2::Command::Result::Switch-To $switch =
			WebDriver2::Command::Switch-To.new( :$frame )
				.execute-with: self;
		self.push-frame: $frame;
		say 'PUSH ' ~ @!frames.gist if $!debug;
		self.debug: $switch;
	}
	
	multi method switch-to( WebDriver2::Model::Frame:D $frame ) {
		$frame.switch-to
	}
	
	multi method switch-to( Int:D $frame ) {
		warn "JUMPING TO FRAME $frame" if $!debug;
		self!switch-to: $frame
	}
	
	method switch-to-parent {
		my WebDriver2::Command::Result::Switch-To-Parent $switch =
			WebDriver2::Command::Switch-To-Parent.new
				.execute-with: self;
		@!frames.pop;
		say 'POP ' ~ @!frames if $!debug;
		self.debug: $switch;
	}
	
	method top {
		say 'TOP' if $!debug;
		@!frames = Empty;
		my WebDriver2::Command::Result::Switch-To $switch =
			WebDriver2::Command::Switch-To.new( frame => Str )
				.execute-with: self;
		self.debug: $switch;
		self
	}

	method url ( --> Str ) {
		my WebDriver2::Command::Result::URL $url =
			WebDriver2::Command::URL.new
				.execute-with: self;
		self.debug: $url;
		$url.value
	}
	
	method window-handle ( --> Str ) {
		my WebDriver2::Command::Result::Window-Handle $wh =
			WebDriver2::Command::Window-Handle.new.execute-with: self;
		self.debug: $wh;
		$wh.value;
	}
	
	method window-handles ( --> Array[Str] ) {
		my WebDriver2::Command::Result::Window-Handles $wh =
			WebDriver2::Command::Window-Handles.new.execute-with: self;
		self.debug: $wh;
		my Str @wh;
		@wh.push: $_ for $wh.values;
		@wh;
	}
	
	method new-window {
		my WebDriver2::Command::Result::New-Window $nw =
			WebDriver2::Command::New-Window.new.execute-with: self;
		self.debug: $nw;
		$nw.values;
	}
	
	method close-window {
		my WebDriver2::Command::Result::Close-Window $cw =
			WebDriver2::Command::Close-Window.new.execute-with: self;
		self.debug: $cw;
	}
	
	method switch-to-window ( Str:D $wh ) {
		my WebDriver2::Command::Result::Switch-to-Window $sw =
			WebDriver2::Command::Switch-to-Window.new( handle => $wh ).execute-with: self;
		self.debug: $sw;
	}
	
	

	method delete-session {
		my WebDriver2::Command::Result::Delete-Session $delete-session =
			WebDriver2::Command::Delete-Session.new
				.execute-with: self;
		self.debug: $delete-session;
	}

	method stop {
		
	}
}

my class WebDriver2::Internal-Element does WebDriver2::Model::Element {
	
	trusts WebDriver2::Internal-Frame;

	has WebDriver2::Driver $!driver;
	has Str $!internal-id is required;
	has Str $!tag-name;
	has Int $.debug;
	
	method !driver( --> WebDriver2::Driver:D ) {
		$!driver
	}
	method internal-id( --> Str ) {
		$!internal-id
	}
	
	submethod BUILD( :$!driver, :$!internal-id, :$!debug = 0 ) { }
	
	method screenshot( WebDriver2: --> Str:D ) {
		$!driver!WebDriver2::Driver::screenshot: $!internal-id
	}
	
	method stale ( --> Bool:D ) {
#		try { self.enabled }
		try self.enabled;
#		$!id.say;
		$!.throw if $!
				and (
				( $! !~~ WebDriver2::Command::Result::X )
						or ( $!.execution-status.type !~~
				WebDriver2::Command::Execution-Status::Type::Stale )
				);
		so ( $! and $!.execution-status.type ~~ WebDriver2::Command::Execution-Status::Type::Stale )
	}
	
	method element(
			WebDriver2::Command::Element::Locator:D $locator
			--> WebDriver2::Model::Element:D
	) {
		$!driver!WebDriver2::Driver::element( $!internal-id, $locator )
	}
	method elements(
			WebDriver2::Command::Element::Locator:D $locator
			--> Array of WebDriver2::Model::Element
	) {
		$!driver!WebDriver2::Driver::elements: $!internal-id, $locator;
	}
	method rect( --> Hash of Int ) {
		$!driver!WebDriver2::Driver::element-rect: $!internal-id;
	}
	method tag-name( --> Str:D ) {
		$!tag-name //= $!driver!WebDriver2::Driver::tag-name: $!internal-id;
		say "TAG NAME $!tag-name" if $!debug;
		return $!tag-name;
#		return (
#				$!tag-name
#				or ( $!tag-name =
#						$!driver!WebDriver2::Driver::tag-name( $!internal-id )
#				)
#		);
	}
	method top( WebDriver2::Model::Context:D ) {
		$!driver.top;
		$!driver
	}
	method frame( --> WebDriver2::Model::Frame:D ) {
		die 'self not a frame' unless self.tag-name.lc eq 'iframe' | 'frame';
		$!driver.WebDriver2::Driver::frame: self;
	}
	method property( Str:D $property --> WebDriver2::Command::Result::Property::Prop-Val ) {
		$!driver!WebDriver2::Driver::property( $!internal-id, $property )
	}
	method attribute( Str:D $attribute --> Str ) {
		$!driver!WebDriver2::Driver::attribute( $!internal-id, $attribute )
	}
	method id( --> Str ) {
		$!driver!WebDriver2::Driver::id( $!internal-id )
	}
	method value( --> Str ) {
		$!driver!WebDriver2::Driver::value( $!internal-id )
	}
	method text( --> Str:D ) {
		$!driver!WebDriver2::Driver::text( $!internal-id )
	}
	method css-value( Str:D $property --> Str ) {
		$!driver!WebDriver2::Driver::css-value( $!internal-id, $property )
	}
	method enabled( --> Bool:D ) {
		$!driver!WebDriver2::Driver::enabled( $!internal-id )
	}
	method displayed( --> Bool:D ) {
		$!driver!WebDriver2::Driver::displayed( $!internal-id )
	}
	method selected( --> Bool:D ) {
		$!driver!WebDriver2::Driver::selected( $!internal-id )
	}
	method send-keys( Str:D $text ) {
		$!driver!WebDriver2::Driver::send-keys( $!internal-id, $text )
	}
	method clear( --> WebDriver2::Model::Element:D ) {
		$!driver!WebDriver2::Driver::clear( $!internal-id );
		self
	}
	method click( --> WebDriver2::Model::Element:D ) {
		$!driver!WebDriver2::Driver::click( $!internal-id );
		self
	}
	method execute-script ( Str:D $script, *@args ) {
		my @self-args = @args;
		my Hash[Str] $element = Hash[Str].new: %( ELEMENT-ID, $!internal-id );
		@self-args.unshift: $element;
		$!driver.execute-script: $script, @self-args;
	}
#	method debug ( --> Str ) {
#		$!internal-id
#	}

	multi method ACCEPTS( WebDriver2::Internal-Element:D: $other ) {
		$!internal-id eq $other.internal-id;
	}
}

my class WebDriver2::Internal-Frame
		is WebDriver2::Internal-Element
		does WebDriver2::Model::Frame
{
	
	multi method new( WebDriver2::Driver:D $driver, Int $debug = 0 ) {
		self.bless: :$driver, internal-id => Str, :$debug
	}
	
	multi method new( WebDriver2::Internal-Element:D $element, Int $debug = 0 ) {
		self.bless:
				driver => $element!WebDriver2::Internal-Element::driver,
				internal-id => $element.internal-id,
				:$debug
		;
	}
	
	method is-curr-frame( --> Bool:D ) {
self!WebDriver2::Internal-Element::driver.curr-frame.say;
self.internal-id.say;
say so self.stale;
		self!WebDriver2::Internal-Element::driver.curr-frame ~~
				self.internal-id
			and not self.stale
	}

	method stale ( --> Bool:D ) {
		my WebDriver2::Driver $driver = self!WebDriver2::Internal-Element::driver;
		return True if not $driver.curr-frame
				or $driver.curr-frame !~~ self.internal-id;
#		callsame
		False;
	}
	
	method switch-to( --> WebDriver2::Model::Frame ) {
say 'SELF SWITCH-TO';
		my WebDriver2::Driver $driver = self!WebDriver2::Internal-Element::driver;
		my Str $iid = self.internal-id;
		if self.debug {
			my Str $msg = 'switch to ' ~ $iid.gist;
			$msg ~= " from { $driver.curr-frame }" if $driver.curr-frame;
			$msg.say;
		}

#		$driver!WebDriver2::Driver::switch-to( $iid )
			if (
				$driver.curr-frame.defined and $iid and $driver.curr-frame ne $iid
				or not $driver.curr-frame.defined # and $iid
#				or not $iid and $driver.curr-frame.defined;
)				{ $driver!WebDriver2::Driver::switch-to: $iid; };
		self;
#		$driver;
	}

	method context( --> WebDriver2::Model::Context:D ) {
say 'CONTEXT CHECK ', so self.is-curr-frame;
		self.switch-to unless self.is-curr-frame;
#		self!WebDriver2::Internal-Element::driver
#		self;
		self!WebDriver2::Internal-Element::driver
	}
}
