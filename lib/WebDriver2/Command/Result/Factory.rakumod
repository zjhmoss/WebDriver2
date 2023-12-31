use JSON::Fast;

use WebDriver2::HTTP::Response;

use WebDriver2::Command::Result;

use WebDriver2::Command::Execution-Status;

unit role WebDriver2::Command::Result::Factory;

#method .execution-status-args( $data, $type ) { # PRIVATE OKAY
#	\(
#	code => $data<value><error>,
#	:$type,
#	message => $data<value><message>
#)
#}

method execution-status( $data, Cool $code --> WebDriver2::Command::Execution-Status ) { ... }

method basic( WebDriver2::HTTP::Response $response ) { ... }

method single-value( WebDriver2::HTTP::Response $response ) { ... }



method url ( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::URL ) {
	WebDriver2::Command::Result::URL.new( |self.single-value( $response ) )
}

method status( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Status ) {
	...
#	my $data = from-json( $response.content );
#	return WebDriver2::Command::Result::Status.new(
#			str => $response.content,
#			version => $data<value><build><version>,
#			ready => $data<value><ready>,
#			message => $data<value><message>,
#			execution-status => self.execution-status( $data, $response.code )
#	);
}

method session( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Session ) {
	...
#	my $data = from-json( $response.content );
#	return WebDriver2::Command::Result::Session.new(
#			str => $response.content,
#			execution-status => self.execution-status( $data, $response.code ),
#			value => $data<value><sessionId>,
#			message => $data<value><message> // Str
#	);
}

method maximize-window (
		WebDriver2::HTTP::Response $response
		--> WebDriver2::Command::Result::Maximize-Window
) {
	WebDriver2::Command::Result::Maximize-Window.new( |self.basic( $response ) )
}

method set-window-rect(
		WebDriver2::HTTP::Response $response
		--> WebDriver2::Command::Result::Set-Window-Rect
) {
	WebDriver2::Command::Result::Set-Window-Rect.new( |self.basic( $response ) )
}

method navigate( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Navigate ) {
	WebDriver2::Command::Result::Navigate.new( |self.basic( $response ) )
}

method back ( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Back ) {
	WebDriver2::Command::Result::Back.new( |self.basic( $response ) )
}

method forward ( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Forward ) {
	WebDriver2::Command::Result::Forward.new( |self.basic( $response ) )
}

method refresh( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Refresh ) {
	WebDriver2::Command::Result::Refresh.new( |self.basic( $response ) )
}

method screenshot( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Screenshot ) {
	WebDriver2::Command::Result::Screenshot.new( |self.single-value( $response ) )
}

method element-screenshot(
		WebDriver2::HTTP::Response $response
		--> WebDriver2::Command::Result::Element-Screenshot
) {
	WebDriver2::Command::Result::Element-Screenshot.new( |self.single-value( $response ) )
}

method title( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Title ) {
	WebDriver2::Command::Result::Title.new( |self.single-value( $response ) )
}

method alert-text( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Alert-Text ) {
	WebDriver2::Command::Result::Alert-Text.new( |self.single-value( $response ) )
}

method accept-alert(
		WebDriver2::HTTP::Response $response
		--> WebDriver2::Command::Result::Accept-Alert
) {
	WebDriver2::Command::Result::Accept-Alert.new( |self.basic( $response ) )
}

method dismiss-alert(
		WebDriver2::HTTP::Response $response
		--> WebDriver2::Command::Result::Dismiss-Alert
) {
	WebDriver2::Command::Result::Dismiss-Alert.new( |self.basic( $response ) )
}

method send-alert-text(
		WebDriver2::HTTP::Response $response
		--> WebDriver2::Command::Result::Send-Alert-Text
) {
	WebDriver2::Command::Result::Send-Alert-Text.new( |self.basic( $response ) )
}

method element( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Element ) {
	...
#	my $data = from-json( $response.content );
#	# FIXME : status 7 for no such element
#	my WebDriver2::Command::Execution-Status $execution-status = self.execution-status( $data, $response.code );
#	return WebDriver2::Command::Result::Element.new(
#			str => $response.content,
#			:$execution-status,
#			value => $data<value>{ ELEMENT-ID } // Str
#	);
}

method subelement( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::SubElement ) {
	...
#	my $data = from-json( $response.content );
#	# FIXME : status 7 for no such element
#	return WebDriver2::Command::Result::SubElement.new(
#			str => $response.content,
#			execution-status => self.execution-status( $data, $response.code ),
#			value => $data<value>{ ELEMENT-ID } // Str
#	);
}

method elements( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Elements ) {
	...
#	my $data = from-json( $response.content );
#	# FIXME : status 7 for no such element
#	my Str @el;
#	@el.push: $_{ ELEMENT-ID } for $data<value>[*];
#	WebDriver2::Command::Result::Elements.new(
#			str => $response.content,
#			execution-status => self.execution-status( $data, $response.code ),
#			values => @el
#	);
}

method subelements(
		WebDriver2::HTTP::Response $response
		--> WebDriver2::Command::Result::SubElements
) {
	...
#	my $data = from-json( $response.content );
#	# FIXME : status 7 for no such element
#	my Str @el;
#	@el.push: $_{ ELEMENT-ID } for $data<value>[*];
#	WebDriver2::Command::Result::SubElements.new(
#			str => $response.content,
#			execution-status => self.execution-status( $data, $response.code ),
#			values => @el
#	);
}

method element-rect(
		WebDriver2::HTTP::Response $response
		--> WebDriver2::Command::Result::Element-Rect
) {
	...
#	my $data = from-json $response.content;
#	WebDriver2::Command::Result::Element-Rect.new:
#			x => $data<value><x> ?? $data<value><x>.Int !! Int,
#			y => $data<value><y> ?? $data<value><y>.Int !! Int,
#			width => $data<value><width> ?? $data<value><width>.Int !! Int,
#			height => $data<value><height> ?? $data<value><height>.Int !! Int
}



method window-handle (
		WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Window-Handle
) {
	WebDriver2::Command::Result::Window-Handle.new: |self.single-value: $response;
}

method window-handles (
		WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Window-Handles
) {
	...
#	my $data = from-json $response.content;
#	my Str @wh;
##	@wh.push: $_{ WINDOW-ID } for $data<value><handles>[*];
#	@wh.append: $data<value>[*];
#	WebDriver2::Command::Result::Window-Handles.new:
#			str => $response.content,
#			values => @wh,
#			execution-status => self.execution-status: $data, $response.code;
}

method new-window (
		WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::New-Window
) {
	...
#	my $data = from-json $response.content;
#	my Str %values = $data<value><>:kv;
#	WebDriver2::Command::Result::New-Window.new:
#			str => $response.content,
#			:%values,
#			execution-status => self.execution-status: $data, $response.code;
}

method switch-to-window (
		WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Switch-to-Window
) {
	WebDriver2::Command::Result::Switch-to-Window.new: |self.basic: $response;
}

method close-window (
		WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Close-Window
) {
	WebDriver2::Command::Result::Close-Window.new: |self.basic: $response;
}

method execute-script(
		WebDriver2::HTTP::Response $response
		--> WebDriver2::Command::Result::Execute-Script
) {
	#	my $data = from-json $response.content;
	WebDriver2::Command::Result::Execute-Script.new: |self.single-value: $response;
}

method active( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Active ) {
	...
#	my $data = from-json( $response.content );
#	WebDriver2::Command::Result::Active.new(
#			str => $response.content,
#			execution-status => self.execution-status( $data, $response.code ),
#			value => $data<value>{ ELEMENT-ID } // Str
#	)
}

method tag-name( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Tag-Name ) {
	WebDriver2::Command::Result::Tag-Name.new( |self.single-value( $response ) )
}

method switch-to( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Switch-To ) {
	# FIXME : status 8 for no such frame
	WebDriver2::Command::Result::Switch-To.new( |self.basic( $response ) );
}

method switch-to-parent(
		WebDriver2::HTTP::Response $response
		--> WebDriver2::Command::Result::Switch-To-Parent
) {
	WebDriver2::Command::Result::Switch-To-Parent.new( |self.basic( $response ) )
}

method property( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Property ) {
	WebDriver2::Command::Result::Property.new( |self.single-value( $response ) )
}

method attribute( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Attribute ) {
	WebDriver2::Command::Result::Attribute.new( |self.single-value( $response ) )
}

method text( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Text ) {
	WebDriver2::Command::Result::Text.new( |self.single-value( $response ) )
}

method enabled( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Enabled ) {
	WebDriver2::Command::Result::Enabled.new( |self.single-value( $response ) )
}

method displayed( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Displayed ) {
	WebDriver2::Command::Result::Displayed.new( |self.single-value( $response ) )
}

method selected( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Selected ) {
	WebDriver2::Command::Result::Selected.new( |self.single-value( $response ) )
}

method css-value( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::CSS-Value ) {
	WebDriver2::Command::Result::CSS-Value.new( |self.single-value( $response ) )
}

method send-keys( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Send-Keys ) {
	WebDriver2::Command::Result::Send-Keys.new( |self.basic( $response ) )
}

method timeouts( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Timeouts ) {
	WebDriver2::Command::Result::Timeouts.new( |self.basic( $response ) )
}

method clear( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Clear ) {
	WebDriver2::Command::Result::Clear.new( |self.basic( $response ) )
}

method click( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Click ) {
	WebDriver2::Command::Result::Click.new( |self.basic( $response ) )
}

method delete-session(
		WebDriver2::HTTP::Response $response
		--> WebDriver2::Command::Result::Delete-Session
) {
	WebDriver2::Command::Result::Delete-Session.new( |self.basic( $response ) )
}
