use JSON::Fast;
use WebDriver2::HTTP::Response;
use WebDriver2;

use WebDriver2::Command::Result;
use WebDriver2::Command::Execution-Status;
use WebDriver2::Command::Element::Locator;
use WebDriver2::Command::Param;

role WebDriver2::Command[::T] {
	method execute-with( WebDriver2 $driver --> T ) { ... }
	method !request(
			WebDriver2 $driver,
			Str $method,
			*@command
			--> WebDriver2::HTTP::Request
	) {
		my $host = $driver.server.host;
		my $port = $driver.server.port;
		my Str $url = "http://$host:$port/" ~ @command.join( '/' );
say "$method $url" if $driver.debug > 2;
		given $method {
			when 'GET' { return WebDriver2::HTTP::Request.new( :GET( $url ) ); }
			when 'POST' { return WebDriver2::HTTP::Request.new( :POST( $url ) ); }
			when 'DELETE' { return WebDriver2::HTTP::Request.new( :DELETE( $url ) ); }
		}
	}
	
	method !session-request(
			WebDriver2 $driver,
			Str $method,
			*@command
			--> WebDriver2::HTTP::Request
	) {
		my Str @new-command = 'session', $driver.session-id, |@command;
		return self!request: $driver, $method, @new-command;
	}
	
	method get-request (
			WebDriver2 $driver,
			*@command
			--> WebDriver2::HTTP::Response
	) {
		$driver.ua.request( self!request( $driver, 'GET', @command ) )
	}
	
	method get-session-request(
			WebDriver2 $driver,
			*@command
			--> WebDriver2::HTTP::Response
	) {
		$driver.ua.request: self!session-request: $driver, 'GET', @command;
	}
	
	method post-request(
			WebDriver2 $driver,
			$data,
			*@command
			--> WebDriver2::HTTP::Response
	) {
		my WebDriver2::HTTP::Request $req = self!request( $driver, 'POST', @command );
say to-json $data if $driver.debug > 2;
		$req.add-content( to-json( $data ) );
		return $driver.ua.request( $req );
	}
	
	method post-session-request(
			WebDriver2 $driver,
			$data,
			*@command
			--> WebDriver2::HTTP::Response
	) {
		my WebDriver2::HTTP::Request $req =
				self!session-request: $driver, 'POST', @command;
say to-json $data if $driver.debug > 2;
		$req.add-content: to-json $data;
		return $driver.ua.request: $req;
	}
	
	method delete-request (
			WebDriver2 $driver,
			*@command
			--> WebDriver2::HTTP::Response
	) {
		$driver.ua.request( self!request( $driver, 'DELETE', @command ) )
	}
	
	method delete-session-request(
			WebDriver2 $driver,
			*@command
			--> WebDriver2::HTTP::Response
	) {
		$driver.ua.request: self!session-request: $driver, 'DELETE', @command;
	}
}

class WebDriver2::Command::Accept-Alert does WebDriver2::Command[WebDriver2::Command::Result::Accept-Alert] {
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Accept-Alert
	) {
		$driver.result.accept-alert:
				self.post-session-request:
						$driver,
						$driver.param.accept-alert,
						'alert',
						'accept';
	}
}

class WebDriver2::Command::Active does WebDriver2::Command[WebDriver2::Command::Result::Active] {
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Active
	) {
		$driver.result.active:
				self.get-session-request:
						$driver,
						'element',
						'active';
	}
}

class WebDriver2::Command::Alert-Text does WebDriver2::Command[WebDriver2::Command::Result::Alert-Text] {
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Alert-Text
	) {
		$driver.result.alert-text:
				self.get-session-request:
						$driver,
						'alert',
						'text';
	}
}

class WebDriver2::Command::Attribute does WebDriver2::Command[WebDriver2::Command::Result::Attribute] {
	has Str $!element;
	has Str $!attribute;
	
	submethod BUILD( :$!element, :$!attribute ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Attribute
	) {
		$driver.result.attribute:
				self.get-session-request:
						$driver,
						'element',
						$!element,
						'attribute',
						$!attribute;
	}
}

class WebDriver2::Command::Back does WebDriver2::Command[WebDriver2::Command::Result::Back] {
	method execute-with(
			WebDriver2 $driver,
			--> WebDriver2::Command::Result::Back
	) {
		$driver.result.back:
				self.post-session-request:
						$driver,
						$driver.param.back,
						'back';
	}
}

class WebDriver2::Command::Clear does WebDriver2::Command[WebDriver2::Command::Result::Clear] {
	has Str $!element;
	
	submethod BUILD( :$!element ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Clear
	) {
		$driver.result.clear:
				self.post-session-request:
						$driver,
						$driver.param.clear,
						'element',
						$!element,
						'clear';
	}
}

class WebDriver2::Command::Click does WebDriver2::Command[WebDriver2::Command::Result::Click] {
	has Str $!element;
	
	submethod BUILD( :$!element ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Click
	) {
		
		$driver.result.click:
				self.post-session-request:
						$driver,
						$driver.param.click,
						'element',
						$!element,
						'click';
	}
}

class WebDriver2::Command::CSS-Value does WebDriver2::Command[WebDriver2::Command::Result::CSS-Value] {
	has Str $!element;
	has Str $!property;
	
	submethod BUILD( :$!element, :$!property ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::CSS-Value
	) {
		$driver.result.css-value:
				self.get-session-request:
						$driver,
						'element',
						$!element,
						'css',
						$!property
	}
}

class WebDriver2::Command::Delete-Session does WebDriver2::Command[WebDriver2::Command::Result::Delete-Session] {
	method execute-with(
			WebDriver2 $driver --> WebDriver2::Command::Result::Delete-Session
	) {
		return $driver.result.delete-session:
				self.delete-request: $driver, 'session', $driver.session-id;
	}
}

class WebDriver2::Command::Dismiss-Alert does WebDriver2::Command[WebDriver2::Command::Result::Dismiss-Alert] {
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Dismiss-Alert
	) {
		$driver.result.dismiss-alert(
				self.post-session-request(
						$driver,
						$driver.param.dismiss-alert,
						'alert',
						'dismiss'
				)
		)
	}
}

class WebDriver2::Command::Displayed does WebDriver2::Command[WebDriver2::Command::Result::Displayed] {
	has Str $!element;
	
	submethod BUILD( :$!element ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Displayed
	) {
		$driver.result.displayed(
				self.get-session-request(
						$driver,
						'element',
						$!element,
						'displayed'
				)
		)
	}
}

class WebDriver2::Command::Element does WebDriver2::Command[WebDriver2::Command::Result::Element] {
	has WebDriver2::Command::Element::Locator $!locator;
	
	submethod BUILD( :$!locator ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Element
	) {
		$driver.result.element(
				self.post-session-request(
						$driver,
						$driver.param.element( $!locator ),
						'element'
				)
		)
	}
}

class WebDriver2::Command::Element-Screenshot
		does WebDriver2::Command[WebDriver2::Command::Result::Element-Screenshot]
{
	has Str $!element;
	
	submethod BUILD( :$!element ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Element-Screenshot
	) {
		$driver.result.element-screenshot:
				self.get-session-request:
						$driver,
						'element',
						$!element,
						'screenshot';
	}
}

class WebDriver2::Command::Elements does WebDriver2::Command[WebDriver2::Command::Result::Elements] {
	has WebDriver2::Command::Element::Locator $!locator;
	
	submethod BUILD( :$!locator ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Elements
	) {
		$driver.result.elements(
				self.post-session-request(
						$driver,
						$driver.param.elements( $!locator ),
						'elements'
				)
		)
	}
}

class WebDriver2::Command::Enabled does WebDriver2::Command[WebDriver2::Command::Result::Enabled] {
	has Str $!element;
	
	submethod BUILD( :$!element ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Enabled
	) {
		$driver.result.enabled(
				self.get-session-request(
						$driver,
						'element',
						$!element,
						'enabled'
				)
		)
	}
}

class WebDriver2::Command::Element-Rect does WebDriver2::Command[WebDriver2::Command::Result::Element-Rect] {
	has Str $!element;

	submethod BUILD( :$!element ) { }

	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Element-Rect
	) {

		$driver.result.element-rect(
				self.get-session-request(
						$driver,
						$driver.param.element-rect,
						'element',
						$!element,
						'rect'
				)
		)
	}
}

class WebDriver2::Command::Execute-Script does WebDriver2::Command[WebDriver2::Command::Result::Execute-Script] {
	has Str $!script;
	has @!args;

	submethod BUILD( :$!script, :@!args ) { }

	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Execute-Script
	) {
		$driver.result.execute-script(
				self.post-session-request(
						$driver,
						$driver.param.execute-script( $!script, @!args ),
						'execute',
						'sync'
				)
		)
	}
}

class WebDriver2::Command::Forward does WebDriver2::Command[WebDriver2::Command::Result::Forward] {
	method execute-with(
			WebDriver2 $driver,
			--> WebDriver2::Command::Result::Forward
	) {
		$driver.result.forward:
				self.post-session-request:
						$driver,
						$driver.param.forward,
						'forward';
	}
}

class WebDriver2::Command::ID is WebDriver2::Command::Attribute {
	method new( :$element ) {
		self.bless( :$element, attribute => 'id' )
	}
}

class WebDriver2::Command::Maximize-Window does WebDriver2::Command[WebDriver2::Command::Result::Maximize-Window] {
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Maximize-Window
	) {
		$driver.result.maximize-window(
				self.post-session-request(
						$driver,
						$driver.param.maximize-window,
						'window',
						'maximize'
				)
		)
	}
}

class WebDriver2::Command::Navigate does WebDriver2::Command[WebDriver2::Command::Result::Navigate] {
	has Str $!url is required;
	
	submethod BUILD( :$!url ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Navigate
	) {
		$driver.result.navigate(
				self.post-session-request(
						$driver,
						$driver.param.navigate( $!url ),
						'url'
				)
		)
	}
}

class WebDriver2::Command::Property does WebDriver2::Command[WebDriver2::Command::Result::Property] {
	has Str $!element;
	has Str $!property;
	
	submethod BUILD( :$!element, :$!property ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Property
	) {
		$driver.result.property(
				self.get-session-request(
						$driver,
						'element',
						$!element,
						'property',
						$!property
				)
		)
	}
}

class WebDriver2::Command::Refresh does WebDriver2::Command[WebDriver2::Command::Result::Refresh] {
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Refresh
	) {
		$driver.result.refresh(
				self.post-session-request(
						$driver,
						$driver.param.refresh,
						'refresh'
				)
		)
	}
}

class WebDriver2::Command::Screenshot does WebDriver2::Command[WebDriver2::Command::Result::Screenshot] {
	method execute-with( WebDriver2 $driver --> WebDriver2::Command::Result::Screenshot ) {
		$driver.result.screenshot:
				self.get-session-request:
						$driver,
						'screenshot';
	}
}

class WebDriver2::Command::Selected does WebDriver2::Command[WebDriver2::Command::Result::Selected] {
	has Str $!element;
	
	submethod BUILD( :$!element ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Selected
	) {
		$driver.result.selected(
				self.get-session-request(
						$driver,
						'element',
						$!element,
						'selected'
				)
		)
	}
}

class WebDriver2::Command::Send-Alert-Text does WebDriver2::Command[WebDriver2::Command::Result::Send-Alert-Text] {
	has Str $!text;
	
	submethod BUILD( :$!text ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Send-Alert-Text
	) {
		$driver.result.send-alert-text(
				self.post-session-request(
						$driver,
						$driver.param.send-alert-text( $!text ),
						'alert',
						'text'
				)
		)
	}
}

class WebDriver2::Command::Send-Keys does WebDriver2::Command[WebDriver2::Command::Result::Send-Keys] {
	has Str $!element;
	has Str $!keys;
	
	submethod BUILD( :$!element, :$!keys ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Send-Keys
	) {
		$driver.result.send-keys(
				self.post-session-request(
						$driver,
						$driver.param.send-keys( $!keys ),
						'element',
						$!element,
						'value'
				)
		)
	}
}

class WebDriver2::Command::Session does WebDriver2::Command[WebDriver2::Command::Result::Session] {
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Session
	) {
		my $data = $driver.param.session;
		my WebDriver2::Command::Result::Session $session-result =
				$driver.result.session:
						self.post-request: $driver, $data, 'session';
		$driver.session-id = $session-result.value;
		return $session-result;
	}
}

class WebDriver2::Command::Set-Window-Rect does WebDriver2::Command[WebDriver2::Command::Result::Set-Window-Rect] {
	has Int $!width;
	has Int $!height;
	has Int $!x;
	has Int $!y;

	submethod BUILD( :$!width, :$!height, :$!x, :$!y ) { }

	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Set-Window-Rect
	) {
		$driver.result.set-window-rect(
				self.post-session-request(
						$driver,
						$driver.param.set-window-rect(
								$!width, $!height, $!x, $!y
						),
						'window',
						'rect'
				)
		)
	}
}

class WebDriver2::Command::Status does WebDriver2::Command[WebDriver2::Command::Result::Status] {
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Status
	) {
		$driver.result.status( self.get-request( $driver, 'status' ) )
	}
}

class WebDriver2::Command::SubElement does WebDriver2::Command[WebDriver2::Command::Result::SubElement] {
	has Str $!context;
	has WebDriver2::Command::Element::Locator $!locator;
	
	submethod BUILD( :$!context, :$!locator ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::SubElement
	) {
		$driver.result.subelement(
				self.post-session-request(
						$driver,
						$driver.param.subelement( $!locator ),
						'element',
						$!context,
						'element'
				)
		)
	}
}

class WebDriver2::Command::SubElements does WebDriver2::Command[WebDriver2::Command::Result::SubElements] {
	has Str $!context;
	has WebDriver2::Command::Element::Locator $!locator;
	
	submethod BUILD( :$!context, :$!locator ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::SubElements
	) {
		$driver.result.subelements(
				self.post-session-request(
						$driver,
						$driver.param.subelements( $!locator ),
						'element',
						$!context,
						'elements'
				)
		)
	}
}

class WebDriver2::Command::Window-Handle does WebDriver2::Command[WebDriver2::Command::Result::Window-Handle] {
	method execute-with( WebDriver2 $driver --> WebDriver2::Command::Result::Window-Handle ) {
		$driver.result.window-handle:
				self.get-session-request:
						$driver,
						$driver.param.window-handle,
						'window';
	}
}

class WebDriver2::Command::Window-Handles does WebDriver2::Command[WebDriver2::Command::Result::Window-Handles] {
	method execute-with( WebDriver2 $driver --> WebDriver2::Command::Result::Window-Handles ) {
		$driver.result.window-handles:
				self.get-session-request:
						$driver,
						$driver.param.window-handles,
						'window',
						'handles';
	}
}

class WebDriver2::Command::New-Window does WebDriver2::Command[WebDriver2::Command::Result::New-Window] {
	method execute-with( WebDriver2 $driver --> WebDriver2::Command::Result::New-Window ) {
		$driver.result.new-window:
				self.post-session-request:
						$driver,
						$driver.param.new-window,
						'window',
						'new';
	}
}

class WebDriver2::Command::Switch-to-Window does WebDriver2::Command[WebDriver2::Command::Result::Switch-to-Window] {
	has Str $!handle;
	submethod BUILD ( :$!handle ) { }
	method execute-with( WebDriver2 $driver --> WebDriver2::Command::Result::Switch-to-Window ) {
		$driver.result.switch-to-window:
				self.post-session-request:
						$driver,
						$driver.param.switch-to-window( $!handle ),
						'window';
	}
}

class WebDriver2::Command::Close-Window does WebDriver2::Command[WebDriver2::Command::Result::Close-Window] {
	method execute-with ( WebDriver2 $driver --> WebDriver2::Command::Result::Close-Window ) {
		$driver.result.close-window:
				self.delete-session-request:
						$driver,
						$driver.param.close-window,
						'window';
	}
}


class WebDriver2::Command::Switch-To does WebDriver2::Command[WebDriver2::Command::Result::Switch-To] {
	has WebDriver2::Command::Param::ID-or-Index $!frame;
	
	submethod BUILD( :$!frame ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Switch-To
	) {
		$driver.result.switch-to(
				self.post-session-request(
						$driver,
						$driver.param.switch-to( $!frame ),
						# { id => $!frame },
						# { id => 0 },
						'frame'
				)
		)
	}
}

class WebDriver2::Command::Switch-To-Parent
		does WebDriver2::Command[WebDriver2::Command::Result::Switch-To-Parent]
{
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Switch-To-Parent
	) {
		$driver.result.switch-to-parent(
				self.post-session-request(
						$driver,
						$driver.param.switch-to-parent,
						'frame',
						'parent'
				)
		)
	}
}

class WebDriver2::Command::Tag-Name does WebDriver2::Command[WebDriver2::Command::Result::Tag-Name] {
	has Str $!element;
	
	submethod BUILD( :$!element ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Tag-Name
	) {
		$driver.result.tag-name(
				self.get-session-request(
						$driver,
						'element',
						$!element,
						'name'
				)
		)
	}
}

class WebDriver2::Command::Text does WebDriver2::Command[WebDriver2::Command::Result::Text] {
	has Str $!element;
	
	submethod BUILD( :$!element ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Text
	) {
		$driver.result.text(
				self.get-session-request(
						$driver,
						'element',
						$!element,
						'text'
				)
		)
	}
}

class WebDriver2::Command::Timeouts does WebDriver2::Command[WebDriver2::Command::Result::Timeouts] {
	has Int $!script;
	has Int $!pageLoad;
	has Int $!implicit;
	
	submethod BUILD( :$!script, :$!pageLoad, :$!implicit ) { }
	
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Timeouts
	) {
		$driver.result.timeouts(
				self.post-session-request(
						$driver,
						{ :$!script, :$!pageLoad, :$!implicit },
						'timeouts'
				)
		)
	}
}

class WebDriver2::Command::Title does WebDriver2::Command[WebDriver2::Command::Result::Title] {
	method execute-with(
			WebDriver2 $driver
			--> WebDriver2::Command::Result::Title
	) {
		$driver.result.title: self.get-session-request: $driver, 'title';
	}
}

class WebDriver2::Command::URL does WebDriver2::Command[WebDriver2::Command::Result::URL] {
	method execute-with (
			WebDriver2 $driver
			--> WebDriver2::Command::Result::URL
	) {
		$driver.result.url: self.get-session-request: $driver, 'url';
	}
}
