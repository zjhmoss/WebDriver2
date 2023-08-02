use v6;

unit class WebDriver2::HTTP::Header::Field;

has $.name;
has @.values;

method Str {
    @.values.join(', ');
}

=begin pod

=head1 NAME

WebDriver2::HTTP::Header::Field

=head1 SYNOPSIS

    use WebDriver2::HTTP::Header::Field;
    my $header = WebDriver2::HTTP::Header::Field.new(:name<Date>, values => (123, 456));

=head1 DESCRIPTION

This module provides a class encapsulating HTTP Message header field.

=head1 METHODS

=head2 method new

    multi method new(*%params) returns WebDriver2::HTTP::Header::Field

A constructor. Takes parameters like:

=item name   : name of a header field
=item values : array of values of a header field

=head2 method Str

    method Str(WebDriver2::HTTP::Header::Field:) returns Str

Stringifies an WebDriver2::HTTP::Header::Field object. Returns a header field in a human (and server) readable form.

=head1 SEE ALSO

L<WebDriver2::HTTP::Header>

=end pod
