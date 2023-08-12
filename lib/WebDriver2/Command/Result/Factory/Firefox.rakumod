use WebDriver2::HTTP::Response;
use JSON::Tiny;

#use WebDriver2;
use WebDriver2::Command::Execution-Status;
use WebDriver2::Command::Result;
use WebDriver2::Command::Result::Factory;

unit class WebDriver2::Command::Result::Factory::Firefox does WebDriver2::Command::Result::Factory;

method status-args( WebDriver2::HTTP::Response $response, $type ) {
	\(
			code => $response.code,
			:$type,
			message => $response.status-line ~ $response.content
			# prev message values '' # $data<value><message>
	)
}

method execution-status( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Execution-Status ) {
	my $data = from-json( $response.content );
	given $response.code {
	when 200 {
		WebDriver2::Command::Execution-Status.new(
				code => $response.code,
				type => WebDriver2::Command::Execution-Status::Type::OK,
				message => $data<value><message> // Str
		)
	}
	when 400 {
		given $data<value><error> {
			when 'element not interactable' {
				warn "INTERACTABLE: $data";
				WebDriver2::Command::Result::X.new( execution-status =>
						WebDriver2::Command::Execution-Status.new(
								|self.status-args(
										$response,
										WebDriver2::Command::Execution-Status::Type::Interactable
								)
						)
				).throw;
			}
			default {
				warn $data<value><error>;
				WebDriver2::Command::Result::X.new( execution-status =>
						WebDriver2::Command::Execution-Status.new(
								|self.status-args(
										$response,
										WebDriver2::Command::Execution-Status::Type
								)
						)
				).throw;
			}
		}
	}
	when 404 {
		my $data = from-json( $response.content );
		given $data<value><error> {
			when 'stale element reference' {
#				say '404 ERROR ', .raku;
				WebDriver2::Command::Result::X.new( execution-status =>
				WebDriver2::Command::Execution-Status.new(
						|self.status-args(
								$response,
								WebDriver2::Command::Execution-Status::Type::Stale
								)
						)
						).throw;
			}
#			when 'stale element reference' {
#				WebDriver2::Command::Result::X.new( status =>
#						WebDriver2::Command::Execution-Status.new(
#								|self.status-args(
#										$response,
#										WebDriver2::Command::Execution-Status::Type::Stale
#								)
#						)
#				).throw;
#			}
			when 'no such element' {
				WebDriver2::Command::Result::X.new( execution-status =>
						WebDriver2::Command::Execution-Status.new(
								|self.status-args(
										$response,
										WebDriver2::Command::Execution-Status::Type::Element
								)
						)
				).throw;
			}
			when 'no such window' {
				WebDriver2::Command::Result::X.new( execution-status =>
						WebDriver2::Command::Execution-Status.new(
								|self.status-args(
										$response,
										WebDriver2::Command::Execution-Status::Type::Window
								)
						)
				).throw;
			}
			default {
				warn $data<value><error>;
				WebDriver2::Command::Result::X.new( execution-status =>
						WebDriver2::Command::Execution-Status.new(
								|self.status-args(
										$response,
										WebDriver2::Command::Execution-Status::Type
								)
						)
				).throw;
			}
		}
	}
	when 405 {
		WebDriver2::Command::Result::X.new( execution-status =>
				WebDriver2::Command::Execution-Status.new(
						|self.status-args(
								$response,
								WebDriver2::Command::Execution-Status::Type::Method
						)
				)
		).throw;
	}
	default {
		# FIXME : do something sensible here
		warn "{ $response.code }";
		return if not $response.code; # $data<status>;
		WebDriver2::Command::Result::X.new( execution-status =>
				WebDriver2::Command::Execution-Status.new(
						|self.status-args(
								$response,
								WebDriver2::Command::Execution-Status::Type
						)
				)
		).throw;
	}
	}
}

method !hash-val( $data ) {
	die "wrong number of values: { $data.elems }" if $data.elems != 1;
	$data.pairs[0].value // Str;
}

method basic( WebDriver2::HTTP::Response $response ) {
	my $data = from-json $response.content;
	\(
			str => $response.content,
#			execution-status => self.execution-status( $data, $response.code )
			execution-status => self.execution-status: $response
	)
}

method single-value( WebDriver2::HTTP::Response $response ) {
#	my $data = from-json( $response.content );
	my $data = from-json $response.content;
	my WebDriver2::Command::Execution-Status $execution-status = self.execution-status( $response );
#	my WebDriver2::Command::Execution-Status $execution-status = self.execution-status( $data, $response.code );
	\(
			str => $response.content,
			:$execution-status,
			value => $data<value> // Str
#			value => $data<value> // Str
	)
}

#method url ( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::URL ) {
#	WebDriver2::Command::Result::URL.new( |self!single-value( $response ) )
#}
#
method status( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Status ) {
	my $data = from-json( $response.content );
	return WebDriver2::Command::Result::Status.new(
			str => $response.content,
			version => '', # $data<value><build><version>,
			ready => $data<value><ready> // $data<value><sessionId>.defined,
			message => $data<value><message> // Str,
			execution-status => self.execution-status( $response )
	);
}

method session( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Session ) {
	my $data = from-json( $response.content );
	return WebDriver2::Command::Result::Session.new(
			str => $response.content,
			status => self.status( $response ),
			execution-status => self.execution-status( $response ),
			value => $data<value><sessionId>
	);
}
#
#
#method maximize-window (
#		WebDriver2::HTTP::Response $response
#		--> WebDriver2::Command::Result::Maximize-Window
#) {
#	WebDriver2::Command::Result::Maximize-Window.new( |self!basic( $response ) )
#}
#
#
#method set-window-rect(
#		WebDriver2::HTTP::Response $response
#		--> WebDriver2::Command::Result::Set-Window-Rect
#) {
#	WebDriver2::Command::Result::Set-Window-Rect.new( |self!basic( $response ) )
#}
#
#method navigate( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Navigate ) {
#	WebDriver2::Command::Result::Navigate.new( |self!basic( $response ) )
#}
#
#method refresh( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Refresh ) {
#	WebDriver2::Command::Result::Refresh.new( |self!basic( $response ) )
#}
#
#method screenshot( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Screenshot ) {
#	WebDriver2::Command::Result::Screenshot.new( |self!single-value( $response ) )
#}
#
#method element-screenshot(
#		WebDriver2::HTTP::Response $response
#		--> WebDriver2::Command::Result::Element-Screenshot
#) {
#	WebDriver2::Command::Result::Element-Screenshot.new( |self!single-value( $response ) )
#}
#
#method title( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Title ) {
#	WebDriver2::Command::Result::Title.new( |self!single-value( $response ) )
#}
#
#method alert-text( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Alert-Text ) {
#	WebDriver2::Command::Result::Alert-Text.new( |self!single-value( $response ) )
#}
#
#method accept-alert(
#		WebDriver2::HTTP::Response $response
#		--> WebDriver2::Command::Result::Accept-Alert
#) {
#	WebDriver2::Command::Result::Accept-Alert.new( |self!basic( $response ) )
#}
#
#method dismiss-alert(
#		WebDriver2::HTTP::Response $response
#		--> WebDriver2::Command::Result::Dismiss-Alert
#) {
#	WebDriver2::Command::Result::Dismiss-Alert.new( |self!basic( $response ) )
#}
#
#method send-alert-text(
#		WebDriver2::HTTP::Response $response
#		--> WebDriver2::Command::Result::Send-Alert-Text
#) {
#	WebDriver2::Command::Result::Send-Alert-Text.new( |self!basic( $response ) )
#}
#
method element( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Element ) {
	my $data = from-json( $response.content );
	# FIXME : status 7 for no such element
#	my WebDriver2::Command::Execution-Status $status = self.status( $response );
	return WebDriver2::Command::Result::Element.new(
			str => $response.content,
			execution-status => self.execution-status( $response ),
			value => self!hash-val( $data<value> )
	);
}

method subelement( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::SubElement ) {
	my $data = from-json( $response.content );
	# FIXME : status 7 for no such element
	return WebDriver2::Command::Result::SubElement.new(
			str => $response.content,
			execution-status => self.execution-status( $response ),
			value => self!hash-val( $data<value> )
	);
}

method elements( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Elements ) {
	my $data = from-json( $response.content );
	# FIXME : status 7 for no such element
	my Str @el;
	@el.push: self!hash-val( $_ ) for $data<value>[*];
	WebDriver2::Command::Result::Elements.new(
			str => $response.content,
			execution-status => self.execution-status( $response ),
			values => @el
	);
}

method subelements(
		WebDriver2::HTTP::Response $response
		--> WebDriver2::Command::Result::SubElements
) {
	my $data = from-json( $response.content );
	# FIXME : status 7 for no such element
	my Str @el;
	@el.push: self!hash-val( $_ ) for $data<value>[*];
	WebDriver2::Command::Result::SubElements.new(
			str => $response.content,
			execution-status => self.execution-status( $response ),
			values => @el
	);
}
#
method element-rect(
		WebDriver2::HTTP::Response $response
		--> WebDriver2::Command::Result::Element-Rect
) {
	my $data = from-json $response.content;
	WebDriver2::Command::Result::Element-Rect.new:
			x => $data<value><x> ?? $data<value><x>.Int !! Int,
			y => $data<value><y> ?? $data<value><y>.Int !! Int,
			width => $data<value><width> ?? $data<value><width>.Int !! Int,
			height => $data<value><height> ?? $data<value><height>.Int !! Int
}
#
#
#
method window-handles ( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Window-Handles ) {
	my $data = from-json $response.content;
	my Str @wh;
	@wh.push: self!hash-val( $_ ) for $data<value>[*];
	WebDriver2::Command::Result::Window-Handles.new:
			str => $response.content,
			execution-status => self.execution-status( $response ),
			values => @wh;
}

method new-window (
		WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::New-Window
) {
	my $data = from-json $response.content;
	my Str %values = $data<value><>:kv;
	WebDriver2::Command::Result::New-Window.new:
			str => $response.content,
			:%values,
			execution-status => self.execution-status: $response;
}


#
#method execute-script(
#		WebDriver2::HTTP::Response $response
#		--> WebDriver2::Command::Result::Execute-Script
#) {
#	my $data = from-json $response.content;
#	WebDriver2::Command::Result::Execute-Script.new: |self!single-value: $response;
#}
#
method active( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Active ) {
	my $data = from-json( $response.content );
	WebDriver2::Command::Result::Active.new(
			str => $response.content,
			execution-status => self.execution-status( $response ),
			value => self!hash-val( $data<value> )
	)
}
#
#method tag-name( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Tag-Name ) {
#	WebDriver2::Command::Result::Tag-Name.new( |self!single-value( $response ) )
#}
#
#method switch-to( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Switch-To ) {
#	# FIXME : status 8 for no such frame
#	WebDriver2::Command::Result::Switch-To.new( |self!basic( $response ) );
#}
#
#method switch-to-parent(
#		WebDriver2::HTTP::Response $response
#		--> WebDriver2::Command::Result::Switch-To-Parent
#) {
#	WebDriver2::Command::Result::Switch-To-Parent.new( |self!basic( $response ) )
#}
#
#method property( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Property ) {
#	WebDriver2::Command::Result::Property.new( |self!single-value( $response ) )
#}
#
#method attribute( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Attribute ) {
#	WebDriver2::Command::Result::Attribute.new( |self!single-value( $response ) )
#}
#
#method text( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Text ) {
#	WebDriver2::Command::Result::Text.new( |self!single-value( $response ) )
#}
#
#method enabled( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Enabled ) {
#	WebDriver2::Command::Result::Enabled.new( |self!single-value( $response ) )
#}
#
#method displayed( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Displayed ) {
#	WebDriver2::Command::Result::Displayed.new( |self!single-value( $response ) )
#}
#
#method selected( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Selected ) {
#	WebDriver2::Command::Result::Selected.new( |self!single-value( $response ) )
#}
#
#method css-value( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::CSS-Value ) {
#	WebDriver2::Command::Result::CSS-Value.new( |self!single-value( $response ) )
#}
#
#method send-keys( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Send-Keys ) {
#	WebDriver2::Command::Result::Send-Keys.new( |self!basic( $response ) )
#}
#
#method timeouts( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Timeouts ) {
#	WebDriver2::Command::Result::Timeouts.new( |self!basic( $response ) )
#}
#
#method clear( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Clear ) {
#	WebDriver2::Command::Result::Clear.new( |self!basic( $response ) )
#}
#
#method click( WebDriver2::HTTP::Response $response --> WebDriver2::Command::Result::Click ) {
#	WebDriver2::Command::Result::Click.new( |self!basic( $response ) )
#}
#
#method delete-session(
#		WebDriver2::HTTP::Response $response
#		--> WebDriver2::Command::Result::Delete-Session
#) {
#	WebDriver2::Command::Result::Delete-Session.new( |self!basic( $response ) )
#}
