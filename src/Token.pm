#!/usr/bin/perl
use strict;
use warnings;


## Token constants:  ###########################################################
package Token;
use Exporter 'import';

my @types = qw(
	T_APP T_DATE T_HOST T_LOGLEVEL
	T_LINE T_EMPTYLINE T_METALINE T_CONTLINE T_PACKEDLINE T_EOL
	T_CLIENT T_USERNAME T_FNCALL T_INFO T_STACK T_TRACE
	T_REPEAT T_REPEATEND T_WRAP T_WRAPEND
	T_ERROR T_MESSAGE T_KV T_JSON T_FILENAME T_HTTP_STATUS
);

our @EXPORT_OK = (@types);
our %EXPORT_TAGS = (types => \@types);

sub T_APP      () { 'A' }
sub T_DATE     () { 'D' }
sub T_HOST     () { 'H' }
sub T_LOGLEVEL () { 'G' }

sub T_LINE       () { 'L' }
sub T_EMPTYLINE  () { 'EL' }
sub T_METALINE   () { 'ML' }
sub T_CONTLINE   () { 'CL' }
sub T_PACKEDLINE () { 'PKL' }
sub T_EOL        () { 'Z' }

sub T_CLIENT   () { 'C' }
sub T_USERNAME () { 'UN' }
sub T_FNCALL   () { 'F' }
sub T_INFO     () { 'I' }
sub T_STACK    () { 'S' }
sub T_TRACE    () { 'T' }

sub T_REPEAT    () { 'RP' }
sub T_REPEATEND () { 'RE' }
sub T_WRAP      () { 'WR' }
sub T_WRAPEND   () { 'WE' }

sub T_ERROR       () { 'X' }
sub T_MESSAGE     () { 'M' }
sub T_KV          () { 'KV' }
sub T_JSON        () { 'JS' }
sub T_FILENAME    () { 'FN' }
sub T_HTTP_STATUS () { 'HS' }


## Token wrapper class:  #######################################################
package Token;

use overload '""' => \&serialize;

#my $typesep = '|';
my $attrsep = ',';

#my $re_typesep = quotemeta $typesep;
my $re_attrsep = quotemeta $attrsep;
my $re_type = qr/(?:[A-Z][A-Z0-9]{0,3})/;
my $re_attr = qr/(?:(?<k>[a-z][a-z0-9\-\.]*)=(?<v>[a-z0-9\-\.]*))/;
my $re_text = qr/(?:(?:\\.|[^\\)])*+)/;

my $re_token_serialization = qr/
	(?<type> ${re_type} )
	(?: \[ (?<attrs> ${re_attr} (?:${re_attrsep}${re_attr})* )? \] )?
	(?: \( (?<text> ${re_text}) \) )?
	(?:\s|$)/x;

my %UNESCAPE = (
	'n' => "\n",
);


## Constructors:

sub new ($$;$%) {
	my ($class, $type, $content, %attributes) = @_;

	if (defined $content && $content eq "\n" && ($type eq T_EMPTYLINE || $type eq T_EOL)) {
		undef $content;
	}

	return bless {
		type => $type,
		content => $content,
		attributes => { %attributes },
	}, $class;
}

sub unserialize ($$) {
	my ($class, $str) = @_;

	$str =~ m/^$re_token_serialization/
	  or die "invalid token serialization: '${str}'";

	my $type = $+{'type'};
	my %attributes = map{ split /=/ } split /$re_attrsep/, ($+{'attrs'} // '');
	my $text = $+{'text'};

	if (defined $text) {
		local $1;
		$text =~ s#\\(.)# $UNESCAPE{$1} // $1 #ge;
	}

	return new($class, $type, $text, %attributes);
}

sub unserialize_all ($$) {
	my ($class, $str) = @_;
	return unless defined $str;

	my @tokens = ();

	local $1;
	while ($str =~ m/\s*($re_token_serialization)/gs) {
		push @tokens, unserialize($class, $1)
	}

	return @tokens
}


## Methods:


sub serialize ($) {
	my $self = $_[0];
	local $1;

	my $output = $self->{'type'};

	if ($self->{'attributes'} && (my %attrs = %{$self->{'attributes'}})) {
		$output .= '[' . (join $attrsep, map { $_ . '=' . $attrs{$_} } keys %attrs) . ']';
	}

	if ($self->{'content'} && (my $content = $self->{'content'}) ne '') {
		$content =~ s/([\\\)])/\\$1/g;
		$content =~ s/\n/\\n/g;
		$output .= '(' . $content . ')';
	}

	$output . ' '
}

sub is ($$) {
	my ($self, $type) = @_;
	return ($self->{'type'} eq $type)
}

sub is_line ($) {
	my $t = $_[0]->{'type'};
	return ($t eq T_LINE || $t eq T_METALINE || $t eq T_EMPTYLINE || $t eq T_CONTLINE)
}

sub attr ($$) {
	my ($self, $key) = @_;
	$self->{'attributes'}->{$key}
}

sub set ($@) {
	my ($self, $k) = (shift, undef);
	while (defined($k = shift)) {
		$self->{'attributes'}->{$k} = shift
	}
}

sub set_type ($$) {
	my ($self, $type) = (@_);
	$self->{'type'} = $type
}

sub content ($) {
	my ($self) = ($_[0]);

	if (!defined($self->{'content'}) && ($self->is(T_EOL) || $self->is(T_EMPTYLINE))) {
		return "\n";
	}

	$self->{'content'}
}


1
