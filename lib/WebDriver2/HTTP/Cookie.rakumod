unit class WebDriver2::HTTP::Cookie;

has $.name is rw;
has $.value is rw;
has $.secure is rw;
has $.httponly is rw;
has $.path is rw;
has $.domain is rw;
has $.version is rw;
has $.expires is rw;

has %.fields;

method Str {
    my $s = "$.name=$.value";
    $s ~= "; Domain=$.domain" if $.domain;
    $s ~= "; Version=$.version" if $.version;
    $s ~= "; Path=$.path" if $.path;
    $s ~= "; Expires=$.expires" if $.expires;
    $s ~= ';' ~ (%.fields.map( *.fmt("%s=%s") )).flat.join('; ') if %.fields.elems > 1;
    $s ~= "; $.secure" if $.secure;
    $s ~= "; $.httponly" if $.httponly;
    $s;
}

=begin pod

=head1 NAME

WebDriver2::HTTP::Cookie - HTTP cookie class

=head1 SYNOPSIS

    use WebDriver2::HTTP::Cookie;

    my $cookie = WebDriver2::HTTP::Cookie.new(:name<test_name>, :value<test_value>);
    say ~$cookie;

=head1 DESCRIPTION

This module encapsulates single HTTP Cookie.

=head1 METHODS

The following methods are provided:

=head2 method new

    method new(WebDriver2::HTTP::Cookie:, *%params)

A constructor, it takes hash parameters, like:

    name:     name of a cookie
    value:    value of a cookie
    secure:   Secure param
    httponly: HttpOnly param
    fields:   hash of fields (field => value)

Example:

    my $c = WebDriver2::HTTP::Cookie.new(:name<a_cookie>, :value<a_value>, :secure, fields => (a => b));

=head2 method Str

    method Str(WebDriver2::HTTP::Cookie:)

Returns a cookie (as a String) in readable (RFC2109) form.

=head1 SEE ALSO

L<WebDriver2::HTTP::Cookies>, L<WebDriver2::HTTP::Request>, L<WebDriver2::HTTP::Response>

=end pod
