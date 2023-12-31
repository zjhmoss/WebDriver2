use HTTP::Status;
use WebDriver2::HTTP::Message;
use WebDriver2::HTTP::Request;
use WebDriver2::HTTP::UserAgent::Exception;

unit class WebDriver2::HTTP::Response is WebDriver2::HTTP::Message;

has $.status-line is rw;
has $.code is rw;
has WebDriver2::HTTP::Request $.request is rw;

my $CRLF = "\r\n";


submethod BUILD(:$!code) {
    $!status-line = self.set-code($!code);
}

proto method new(|c) { * }

# This candidate makes it easier to test weird responses
multi method new(Blob $header-chunk) {
    # See https://tools.ietf.org/html/rfc7230#section-3.2.4
    my ( $rl, $header ) = $header-chunk.decode('ISO-8859-1').split(/\r?\n/, 2);

    if not $rl {
        warn "chunk:\n$rl$header";
        X::WebDriver2::HTTP::NoResponse.new.throw;
    }
    my $code = (try $rl.split(' ')[1].Int) // 500;
    my $response = self.new($code);
    if $header.defined {
        $response.header.parse( $header.subst(/"\r"?"\n"$$/, '') );
    }
    return $response;
}

multi method new(Int $code? = 200, *%fields) {
    my $header = WebDriver2::HTTP::Header.new(|%fields);
    self.bless(:$code, :$header);
}

method content-length() returns Int {
    my $content-length = self.field('Content-Length').values[0];

    if $content-length.defined {
        my $c = $content-length;
        if not ($content-length = try +$content-length).defined {
            X::WebDriver2::HTTP::ContentLength.new(message => "Content-Length header value '$c' is not numeric").throw;
        }
    }
    else {
        $content-length = Int
    }
    $content-length;
}

method is-success {
    return so is-success($!code);
}

# please extend as necessary
method has-content returns Bool {
    (204, 304).grep({ $!code eq $_ }) ?? False !! True;
}

method is-chunked {
   return self.field('Transfer-Encoding') &&
          self.field('Transfer-Encoding') eq 'chunked' ?? True !! False;
}

method set-code(Int $code) {
    $!code = $code;
    $!status-line = $code ~ " " ~ get_http_status_msg($code);
}

method next-request() returns WebDriver2::HTTP::Request {
    my WebDriver2::HTTP::Request $new-request;

    my $location = ~self.header.field('Location').values;


    if $location.defined {
        # Special case for the HTTP status code 303 (redirection):
        # The response to the request can be found under another URI using
        # a separate GET method. This relates to POST, PUT, DELETE and PATCH methods.
        my $method = $!request.method;
        $method = "GET"
          if self.code == 303 &&
             $!request.method eq any('POST', 'PUT', 'DELETE', 'PATCH');

        my %args = $method => $location;

        $new-request = WebDriver2::HTTP::Request.new(|%args);

        if not ~$new-request.field('Host').values {
            my $hh = ~$!request.field('Host').values;
            $new-request.field(Host => $hh);
            $new-request.scheme = $!request.scheme;
            $new-request.host   = $!request.host;
            $new-request.port   = $!request.port;
        }
    }

    $new-request;
}

method Str (:$debug) {
    my $s = $.protocol ~ " " ~ $!status-line;
    $s ~= $CRLF ~ callwith($CRLF, :debug($debug));
}

=begin pod

=head1 NAME

WebDriver2::HTTP::Response - class encapsulating HTTP response message

=head1 SYNOPSIS

    use WebDriver2::HTTP::Response;
    my $response = WebDriver2::HTTP::Response.new(200);
    say $response.is-success; # it is

=head1 DESCRIPTION

Module provides functionality to easily manage HTTP responses.

Response object is returned by the .get() method of L<WebDriver2::HTTP::UserAgent>.

=head1 METHODS

=head2 method new

    method new(Int $code = 200, *%fields)

A constructor, takes parameters like:

=item code   : code of the response
=item fields : hash of header fields (field_name => values)

    my $response = WebDriver2::HTTP::Response.new(200, :h1<v1>);

=head2 method is-success

    method is-success(WebDriver2::HTTP::Response:) returns Bool;

Returns True if response is successful (status == 2xx), False otherwise.

    my $response = WebDriver2::HTTP::Response.new(200);
    say 'YAY' if $response.is-success;

=head2 method set-code

    method set-code(WebDriver2::HTTP::Response:, Int $code)

Sets code of the response.

    my $response = WebDriver2::HTTP::Response.new;
    $response.set-code: 200;

=head2 method Str

    method Str(WebDriver2::HTTP::Response:) returns Str

Returns strigified object.

=head2 method parse

See L<WebDriver2::HTTP::Message>.

For more documentation, see L<WebDriver2::HTTP::Message>.

=head1 SEE ALSO

L<WebDriver2::HTTP::Message>, L<WebDriver2::HTTP::Response>

=end pod
