unit class WebDriver2::HTTP::Cookies;

use WebDriver2::HTTP::Cookie;
use WebDriver2::HTTP::Response;
use WebDriver2::HTTP::Request;
use DateTime::Parse;

has @.cookies;
has $.file;
has $.autosave is rw = 0;

my grammar WebDriver2::HTTP::Cookies::Grammar {
    token TOP {
        'Set-Cookie:' [\s* <cookie> ','?]*
    }

    token cookie   {
        <name> '=' <value> ';'? \s* [<arg> \s*]* <secure>? ';'? \s* <httponly>? ';'?
    }
    token separator { <[()<>@,;:\"/\[\]?={}\s\t]> }
    token name     { <[\S] - [()<>@,;:\"/\[\]?={}]>+ }
    token value    { <-[;]>+ }
    token arg      { <name> '=' <value> ';'? }
    token secure   { Secure }
    token httponly { :i HttpOnly }
}

my class WebDriver2::HTTP::Cookies::Actions {
    method cookie($/) {
        my $h = WebDriver2::HTTP::Cookie.new;
        $h.name     = ~$<name>;
        $h.value    = ~$<value>;
        $h.secure   = $<secure>.defined ?? ~$<secure> !! False;;
        $h.httponly = $<httponly>.defined ?? ~$<httponly> !! False;

        for $<arg>.list -> $a {
            if <version expires path domain>.grep($a<name>.lc) {
              $h."{$a<name>.lc}"() = ~$a<value>;
            } else {
              $h.fields.push: $a<name> => ~$a<value>;
            }
        }
        $*OBJ.push-cookie($h);
    }
}

method extract-cookies(WebDriver2::HTTP::Response $response) {
    self.set-cookie($_) for $response.field('Set-Cookie').grep({ $_.defined }).map({ "Set-Cookie: $_"  }).flat;
    self.save if $.autosave;
}

method add-cookie-header(WebDriver2::HTTP::Request $request) {
    for @.cookies -> $cookie {
        # TODO this check sucks, eq is not the right (should probably use uri)
        #next if $cookie.domain.defined
        #        && $cookie.domain ne $request.field('Host');
        # TODO : path/domain restrictions
        my $cookiestr = "{$cookie.name}={$cookie.value}; { ($cookie.fields.map( *.fmt("%s=%s") )).flat.join('; ') }";
        if $cookie.version.defined and $cookie.version >= 1 {
            $cookiestr ~= ',$Version='~ $cookie.version;
        } else {
            $request.field(Cookie2 => '$Version="1"');
        }
        if $request.field('Cookie').defined {
            $request.field( Cookie => $request.field("Cookie") ~ $cookiestr );
        } else {
            $request.field( Cookie => $cookiestr );
        }
    }
}

method save {
    my $fh = open $.file, :w;

    # TODO : add versioning
    $fh.say: "#LWP6-Cookies-0.1";
    $fh.say: self.Str;

    $fh.close;
}

method load {
    for $.file.IO.lines -> $l {
        # we don't need #LWP6-Cookies-$VER
        next if $l.substr(0, 1) eq '#';
        self.set-cookie($l.chomp);
    }
}

method clear-expired {
    @.cookies .= grep({
        ! .expires.defined || .expires !~~ /\d\d/ ||
        # we need more precision
        DateTime::Parse.new( .expires ).Date > Date.today
    });
    self.save if $.autosave;
}

method clear {
    @.cookies = ();
    self.save if $.autosave;
}

method set-cookie($str) {
    my $*OBJ = self;
    WebDriver2::HTTP::Cookies::Grammar.parse($str, :actions(WebDriver2::HTTP::Cookies::Actions));

    self.save if $.autosave;
}

method push-cookie(WebDriver2::HTTP::Cookie $c) {
    @.cookies .= grep({ .name ne $c.name });
    @.cookies.push: $c;

    self.save if $.autosave;
}

method Str {
    @.cookies.map({ "Set-Cookie: {$_.Str}" }).flat.join("\n");
}

=begin pod

=head1 NAME

WebDriver2::HTTP::Cookies - HTTP cookie jars

=head1 SYNOPSIS

    use WebDriver2::HTTP::Cookies;
    my $cookies = WebDriver2::HTTP::Cookies.new(
        :file<./cookies>,
        :autosave(1)
    );
    $cookies.load;

=head1 DESCRIPTION

This module provides a bunch of methods to manage HTTP cookies.

=head1 METHODS

=head2 method new

    multi method new(*%params)

A constructor. Takes params like:

=item file     : where to write cookies
=item autosave : save automatically after every operation on cookies or not

    my $cookies = WebDriver2::HTTP::Cookies.new(
        autosave => 1,
        :file<./cookies.here>
    );

=head2 method set-cookie

    method set-cookie(WebDriver2::HTTP::Cookies:, Str $str)

Adds a cookie (passed as an argument $str of type Str) to the list of cookies.

    my $cookies = WebDriver2::HTTP::Cookies.new;
    $cookies.set-cookie('Set-Cookie: name1=value1; HttpOnly');

=head2 method save

    method save(WebDriver2::HTTP::Cookies:)

Saves cookies to the file ($.file).

    my $cookies = WebDriver2::HTTP::Cookies.new;
    $cookies.set-cookie('Set-Cookie: name1=value1; HttpOnly');
    $cookies.save;

=head2 method load

    method load(WebDriver2::HTTP::Cookies:)

Loads cookies from file ($.file).

    my $cookies = WebDriver2::HTTP::Cookies.new;
    $cookies.load;

=head2 method extract-cookies

    method extract-cookies(WebDriver2::HTTP::Cookies:, WebDriver2::HTTP::Response $response)

Gets cookies ('Set-Cookie: ' lines) from the HTTP Response and adds it to the list of cookies.

    my $cookies = WebDriver2::HTTP::Cookies.new;
    my $response = WebDriver2::HTTP::Response.new(Set-Cookie => "name1=value; Secure");
    $cookies.extract-cookies($response);

=head2 method add-cookie-header

    method add-cookie-header(WebDriver2::HTTP::Cookies:, WebDriver2::HTTP::Request $request)

Adds cookies fields ('Cookie: ' lines) to the HTTP Request.

    my $cookies = WebDriver2::HTTP::Cookies.new;
    my $request = WebDriver2::HTTP::Request.new;
    $cookies.load;
    $cookies.add-cookie-header($request);

=head2 method clear-expired

    method clear-expired(WebDriver2::HTTP::Cookies:)

Removes expired cookies.

    my $cookies = WebDriver2::HTTP::Cookies.new;
    $cookies.set-cookie('Set-Cookie: name1=value1; Secure');
    $cookies.set-cookie('Set-Cookie: name2=value2; Expires=Wed, 09 Jun 2021 10:18:14 GMT');
    $cookies.clear-expired; # contains 'name1' cookie only

=head2 method clear

    method clear(WebDriver2::HTTP::Cookies:)

Removes all cookies.

    my $cookies = WebDriver2::HTTP::Cookies.new;
    $cookies.load; # contains something
    $cookies.clear; # will be empty after this action

=head2 method push-cookie

    method push-cookie(WebDriver2::HTTP::Cookies:, WebDriver2::HTTP::Cookie $c)

Pushes cookies (passed as an argument $c of type WebDriver2::HTTP::Cookie) to the list of cookies.

    my $c = WebDriver2::HTTP::Cookie.new(:name<a>, :value<b>, :httponly);
    my $cookies = WebDriver2::HTTP::Cookies.new;
    $cookies.push-cookie: $c;

=head2 method Str

    method Str(WebDriver2::HTTP::Cookies:)

Returns all cookies in human (and server) readable form.

=head1 SEE ALSO

L<WebDriver2::HTTP::Request>, L<WebDriver2::HTTP::Response>, L<WebDriver2::HTTP::Cookie>

=end pod
