#!/usr/bin/perl
use strict;

## Formatting functions:  ######################################################

sub format_token ($;%) {
	my ($token, %opt) = @_;

	return $token->content()  if ($token->is(T_EMPTYLINE) || $token->is(T_EOL));

	return $linestart  if $token->is(T_LINE);
	return $metalinestart  if $token->is(T_METALINE);
	return $contlinestart  if $token->is(T_CONTLINE);

	if ($opt{'line'} && $opt{'line'}->is(T_METALINE)) {
		return format_trace($token->content(), $c_meta)  if $token->is(T_FILENAME);
		return format_meta($token->content())  if $token->is(T_MESSAGE);
	}

	return format_date($token->content())  if $token->is(T_DATE);
	return format_app($token->content())  if $token->is(T_APP);
	return format_host($token->content())  if $token->is(T_HOST);
	return format_loglevel($token)  if $token->is(T_LOGLEVEL);

	return format_stack($token->content())  if $token->is(T_STACK);
	return format_trace($token->content())  if $token->is(T_TRACE);
	return format_trace($token->content())  if $token->is(T_FILENAME);
	return format_exception($token->content())  if $token->is(T_ERROR);
	return format_fncall($token->content())  if $token->is(T_FNCALL);
	return format_rpt($token->content())  if $token->is(T_REPEAT);
	return format_rpt($token->content())  if $token->is(T_REPEATEND);

	if ($token->is(T_INFO)) {
		my $content = $token->content();

		if ($token->is(T_WRAP)) {
			$content = format_wrapbegin($content);
		} elsif ($token->is(T_JSON)) {
			$content = format_json($content);
		} elsif ($token->attr('type') eq 'rfc-5424-sd') {
			# reformat RFC-5424-style Structured Data elements
			$content = format_rfc5424_sd($content);
		}

		$content = ($opt{'had_message'})
			? format_info($content)
			: format_info_prefix($content);

		if ($token->is(T_HTTP_STATUS)) {
			$content = format_http($content, $token->attr('st'), get_ansi_prefix($content));
		} elsif ($token->is(T_WRAPEND)) {
			$content = format_wrapend($content);
		}

		return $content;
	}

	return format_http($token->content(), $token->attr('st'))  if $token->is(T_HTTP_STATUS);

	return $token->content()
}

## Formatting functions:  ######################################################

sub format_date ($) { $c_date . $_[0] . $c0 }
sub format_host ($) { $c_host . $_[0] . $c0 }
sub format_message ($) { $c_message . $_[0] . $c0 }
sub format_app  ($) { $c_app . $_[0] . $c0 }
sub format_rpt ($) { $c_rpt . $_[0] . $c0 }
sub format_meta ($) { $c_meta . $_[0] . $c0 }

sub _format_tracefile ($$) {
	my ($file, $lineno) = (@_);
	my ($c_hi, $c_lo) = ($c_bold, $c_unbold);
	my $include_lineno_in_bold = ($lineno !~ m/(?:on line|in line)/);

	$c_hi . $file .
	(($include_lineno_in_bold)
		? $lineno . $c_lo
		: $c_lo . $lineno)
}

sub format_exception ($) {
	my ($in) = @_;
	my ($prefix, $suffix) = ('', '');
	if ($in =~ s/^((?:[^\\]+\\)+)//) { $prefix = $c_exception_fqcn . $1; }
	if ($in =~ s/(\/\d+)$//) { $suffix = $c_exception_code . $1; }
	$prefix . $c_exception_scn . $in . $suffix . $c_exception0
}

sub format_trace ($;$) {
	my ($out, $c_base) = ($_[0], ($_[1] // $c_trace));
	my ($c_hi, $c_lo) = ($c_bold, $c_unbold);

	$out =~ s/\b([\w\-\.\$]+)($re_lineno)?(,|\)|\s*$)/ _format_tracefile($1, $2) . $3 /ge;

	$c_base . $out . $c0
}

sub format_fncall ($) {
	my ($out) = ($_[0]);
	my ($c_hi, $c_lo) = ($c_bold, $c_unbold);

	$out =~ s#$re_fncall# $+{'class'} . $+{'fnp'} . $c_hi . $+{'fn'}.$+{'fn2'} . $c_lo . format_info( $+{'args'} ) #gem;

	$out
}

sub format_json ($;$) {
	my ($out, $in, $c_json) = ('', $_[0], ($_[1] // $c_info));
	my ($c_hi, $c_lo) = ($c_bold, $c_unbold);

	while ($in ne '') {
		if ($in =~ s/^$re_json_string(?<rest>\s*:\s*)//) {
			$out .= $+{'jstr0'} . $c_hi . $+{'jstr'} . $c_lo . $+{'jstr1'} . $+{'rest'};
		} elsif ($in =~ s/^($re_json_string|[^\\"]+)//) {
			$out .= $1;
		}
	}

	if ($out =~ m/^(\s*\{)(.+)(\}\s*)\s*$/) {
		$out = $c_hi . $1 . $c_lo . $2 . $c_hi . $3 . $c_lo;
	}

	$c_json . $out . $c0
}

sub format_http ($$) {
	my ($string, $status, $c_end) = ($_[0], $_[1], $_[2]//'');

	my $c_http;
	if    (is_http_client_error($status))   { $c_http = $c_http_client_error }
	elsif (is_http_client_failure($status)) { $c_http = $c_http_client_failure }
	elsif (is_http_server_error($status))   { $c_http = $c_http_server_error }
	elsif (is_http_success($status))        { $c_http = $c_http_success }
	elsif (is_http_redir($status))          { $c_http = $c_http_redir }

	if ($c_http) {
		my $re_http_status = qr/(?:^|(?<=\[|\s)|(?<!\d;))(\b\d{3}(?: [A-Za-z\-\(\)']+)*)/;
		$string =~ s/$re_http_status/$c_http$1$c0$c_end/;
	}

	return $string
}

sub format_postfix_info ($) {
	my ($info, $out, $c_pfinfo, $c_hi, $c_lo) = ($_[0], '', $c_info, $c_bold, $c_unbold);

	my $re_replycode = '[2345]\d\d';
	my $re_dsn       = '\d\.\d\.\d';

	$info =~ s/(?<=[\( ])(${re_replycode}(?:[\- ](?:${re_dsn})?)?)\b/ $c_hi . $1 . $c_lo /ge;

	$c_pfinfo . $info . $c0
}

sub format_postfix_status ($) {
	my ($status, $c_status) = ($_[0], '');

	if    ($status =~ m/^(?:2\.\d\.\d|sent|delivered|ok)/) { $c_status = $c_http_success }
	elsif ($status =~ m/^(?:4\.\d\.\d|deferred)/) { $c_status = $c_http_client_error }
	elsif ($status =~ m/^(?:5\.\d\.\d|bounced)/) { $c_status = $c_http_client_failure }
	elsif ($status =~ m/^(?:1\.\d\.\d|error)/) { $c_status = $c_http_server_error }
	return $c_status . $status . $c0
}

sub format_info ($;$) {
	($_[1] // $c_info) . $_[0] . $c0
}

sub format_info_prefix ($;$) {
	my ($in, $mode) = @_;
	format_info($in, $c_info_prefix)
}

sub format_rfc5424_sd ($) {
	my ($in, $out) = ($_[0], '');
	my ($c_id_hi, $c_id_lo) = ($c_bold, $c_unbold);
	my ($c_pn_hi, $c_pn_lo) = ($c_bold, $c_unbold);

	while ($in =~ s/^(\[)([^\s\]]+)( [^=]+=\"[^"]*\")*(\] ?)//) {
		my ($prefix, $id, $params, $suffix) = ($1, $2, $3, $4);

		my $params_out = '';
		while ($params =~ m/( +)([^=]+)(=)(\"[^"]*\")/g) {
			$params_out .= $1 . $c_pn_hi . $2 . $c_pn_lo . $3 . $4;
		}

		$out .= $prefix . $c_id_hi . $id . $c_id_lo . $params_out . $suffix;
	}

	$out . $in
}

sub format_loglevel ($) {
	my ($color, $msg, $level) = ($c_loglevel, $_[0]->content(), $_[0]->attr('level'));
	if    ($level >= L_ERROR)   { $color = $c_loglevel_err }
	elsif ($level >= L_WARNING) { $color = $c_loglevel_warn }
	return $color . $msg . $c0
}

sub format_stack ($) {
	my ($in) = ($_[0]);
	my $re_exc_msg = "($re_exception)(?:(: )(.*?)(?=\\)\$|; ))?";

	my $stack_contains_more_than_one_exception = ($in =~ m/; $re_exception/);
	my $fmt_stack_msg = ($stack_contains_more_than_one_exception)
		# More than one msg in stack? format them each in the default message color for simpler reading.
		? sub($) { format_message($_[0]) . $c_stack }
		# Only one msg in stack? Keep it in the faint $c_stack==$c_info color, the merged message is already msg-formatted.
		: sub($) { $_[0] };

	$in =~ s/(?<=stack: )$re_exc_msg/ format_exception($1) . $2 . &$fmt_stack_msg($3) /e;
	$in =~ s/(?<=; )$re_exc_msg/      format_exception($1) . $2 . &$fmt_stack_msg($3) /ge;
	$c_stack . $in . $c0
}

sub format_wrapbegin ($) {
	my ($in) = ($_[0]);
	$in =~ s/(")(?=\s?$)/$c_bold$1$c_unbold/;
	$in
}

sub format_wrapend ($) {
	my ($in, $c0) = ($_[0], $_[1]//'');
	$in =~ s/^($re_ansi_color)?(")/$c_bold$c_info_prefix$2$c_unbold$1/;
	$in
}



1
