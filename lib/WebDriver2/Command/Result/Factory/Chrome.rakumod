use WebDriver2::Command::Result::Factory::Chromium;

unit class WebDriver2::Command::Result::Factory::Chrome is WebDriver2::Command::Result::Factory::Chromium;

#method !status-args( WebDriver2::HTTP::Response $response, $type ) { # PRIVATE OKAY
#	my $data = from-json $response.content;
#	\(
#			code => $data<value><error>,
#			:$type,
#			message => $data<value><message>
#	)
#}
#
#method execution-status( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Execution-Status ) {
#	my $data = from-json $response.content;
#	return
#			WebDriver2::Command::Execution-Status.new:
#						code => $response.code,
#						type => WebDriver2::Command::Execution-Status::Type::OK,
#						message => $data<value><message> // Str
#			unless $data<value><error>:exists;
#	given $data<value><error> {
#	when 'no such element' {
#		WebDriver2::Command::Result::X.new( execution-status =>
#				WebDriver2::Command::Execution-Status.new(
#						|self!status-args(
#								$response,
#								WebDriver2::Command::Execution-Status::Type::Element
#						)
#				)
#		).throw;
#	}
#	when 'invalid session id' {
#		WebDriver2::Command::Result::X.new( execution-status =>
#				WebDriver2::Command::Execution-Status.new:
#						|self!status-args:
#								$response,
#								WebDriver2::Command::Execution-Status::Type::Session
#		).throw;
#	}
#	when 7 {
#		WebDriver2::Command::Result::X.new( execution-status =>
#				WebDriver2::Command::Execution-Status.new(
#						|self!status-args(
#								$response,
#								WebDriver2::Command::Execution-Status::Type::Element
#						)
#				)
#		).throw;
#	}
#	when 'stale element reference' {
#		WebDriver2::Command::Result::X.new( execution-status =>
#				WebDriver2::Command::Execution-Status.new(
#						|self!status-args(
#								$response,
#								WebDriver2::Command::Execution-Status::Type::Stale
#						)
#				)
#		).throw;
#	}
#	when 26 {
#		WebDriver2::Command::Result::X.new( execution-status =>
#				WebDriver2::Command::Execution-Status.new:
#						|self!status-args:
#								$response,
#								WebDriver2::Command::Execution-Status::Type::Alert
#		).throw;
#	}
#	default {
#		# FIXME : do something sensible here
#		return unless $data<value><error>;
#		WebDriver2::Command::Result::X.new( execution-status =>
#				WebDriver2::Command::Execution-Status.new(
#						|self!status-args(
#								$response,
#								WebDriver2::Command::Execution-Status::Type
#						)
#				)
#		).throw;
#	}
#	}
#}
#
#method value( $value ) {
#	( $value.defined )
#			?? $value
#			!! Str
#}
#
#method basic( WebDriver2::HTTP::Response $response ) {
##	my $data = from-json( $response.content );
#	\(
#			str => $response.content,
#			execution-status => self.execution-status( $response )
#	)
#}
#
#method single-value( WebDriver2::HTTP::Response $response ) {
#	my $data = from-json( $response.content );
#	my WebDriver2::Command::Execution-Status $execution-status = self.execution-status( $response );
#	\(
#			str => $response.content,
#			:$execution-status,
#			value => $data<value> // Str
#	)
#}
#
#
#
#
#method status( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Status ) {
#	my $data = from-json( $response.content );
#	return WebDriver2::Command::Result::Status.new(
#			str => $response.content,
#			version => $data<value><build><version>,
#			ready => $data<value><ready>,
#			message => $data<value><message> // Str,
#			execution-status => self.execution-status( $response )
#	);
#}
#
#method session( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Session ) {
#	my $data = from-json( $response.content );
#	return WebDriver2::Command::Result::Session.new(
#			str => $response.content,
#			execution-status => self.execution-status( $response ),
#			value => $data<value><sessionId>
#	);
#}
#
#method element( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Element ) {
#	my $data = from-json( $response.content );
#	# FIXME : status 7 for no such element
#	return WebDriver2::Command::Result::Element.new(
#			str => $response.content,
#			execution-status => self.execution-status( $response ),
#			value => self.value( $data<value>{ ELEMENT-ID } )
#	);
#}
#
#method subelement( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::SubElement ) {
#	my $data = from-json( $response.content );
#	# FIXME : status 7 for no such element
#	return WebDriver2::Command::Result::SubElement.new(
#			str => $response.content,
#			execution-status => self.execution-status( $response ),
#			value => self.value( $data<value>{ ELEMENT-ID } )
#	);
#}
#
#method elements( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Elements ) {
#	my $data = from-json( $response.content );
#	# FIXME : status 7 for no such element
#	my Str @el;
#	@el.push: $_{ ELEMENT-ID } for $data<value>[*];
#	WebDriver2::Command::Result::Elements.new(
#			str => $response.content,
#			execution-status => self.execution-status( $response ),
#			values => @el
#	);
#}
#
#method subelements(
#		WebDriver2::HTTP::Response $response
#		--> WebDriver2::Command::Result::SubElements
#) {
#	my $data = from-json( $response.content );
#	# FIXME : status 7 for no such element
#	my Str @el;
#	@el.push: $_{ ELEMENT-ID } for $data<value>[*];
#	WebDriver2::Command::Result::SubElements.new(
#			str => $response.content,
#			execution-status => self.execution-status( $response ),
#			values => @el
#	);
#}
#
#method element-rect(
#		WebDriver2::HTTP::Response $response
#		--> WebDriver2::Command::Result::Element-Rect
#) {
#	my $data = from-json $response.content;
#	WebDriver2::Command::Result::Element-Rect.new:
#			x => $data<value><x> ?? $data<value><x>.Int !! Int,
#			y => $data<value><y> ?? $data<value><y>.Int !! Int,
#			width => $data<value><width> ?? $data<value><width>.Int !! Int,
#			height => $data<value><height> ?? $data<value><height>.Int !! Int
#}
#
#method window-handles (
#		WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Window-Handles
#) {
#	my $data = from-json $response.content;
#	my Str @wh;
#	@wh.push: $_ for $data<value>[*];
#	WebDriver2::Command::Result::Window-Handles.new:
#			str => $response.content,
#			values => @wh,
#			execution-status => self.execution-status: $response;
#}
#
#method new-window (
#		WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::New-Window
#) {
#	#	WebDriver2::Command::Result::New-Window.new: |self.basic: $response;
#	my $data = from-json $response.content;
#	my Str %values = $data<value><>:kv;
#	WebDriver2::Command::Result::New-Window.new:
#			str => $response.content,
#			:%values,
#			execution-status => self.execution-status: $response;
#}
#
#method active( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Active ) {
#	my $data = from-json( $response.content );
#	WebDriver2::Command::Result::Active.new(
#			str => $response.content,
#			execution-status => self.execution-status( $response ),
#			value => self.value( $data<value>{ ELEMENT-ID } )
#	)
#}
