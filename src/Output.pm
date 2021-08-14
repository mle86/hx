#!/usr/bin/perl
use strict;
use vars qw(
	$linestart $metalinestart $contlinestart
);


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

	my $content = $token->content();

	return format_date($content)  if $token->is(T_DATE);
	return format_app($content)  if $token->is(T_APP);
	return format_host($content)  if $token->is(T_HOST);
	return format_loglevel($token)  if $token->is(T_LOGLEVEL);

	return format_stack($content)  if $token->is(T_STACK);
	return format_trace($content)  if ($token->is(T_TRACE) && $opt{'had_message'});
	return format_trace($content, $c_info_prefix)  if $token->is(T_TRACE);
	return format_trace($content, $c_message)  if $token->is(T_FILENAME) && ($opt{'line'}->attr('ps') || $opt{'line'}->attr('ftp'));
	return format_trace($content)  if $token->is(T_FILENAME);
	return format_exception($content)  if $token->is(T_ERROR);
	return format_fncall($content, $opt{'packedline'})  if $token->is(T_FNCALL);
	return format_rpt($content)  if $token->is(T_REPEAT);
	return format_rpt($content)  if $token->is(T_REPEATEND);
	return format_http($content)  if $token->is(T_HTTP_STATUS);
	return format_json($content, $opt{'had_message'})  if $token->is(T_JSON);
	return format_kv($token, $opt{'line'})  if $token->is(T_KV);
	return format_postfix_status($content)  if ($token->is(T_MESSAGE) && $token->attr('type') eq 'dsn');

	if ($token->is(T_INFO) || $token->is(T_CLIENT) || $token->is(T_USERNAME) || $token->is(T_WRAP) || $token->is(T_WRAPEND)) {

		if ($token->attr('type') eq 'rfc-5424-sd') {
			# reformat RFC-5424-style Structured Data elements
			$content = format_rfc5424_sd($content);
		}

		$content = format_wrapbegin($content)  if $token->is(T_WRAP);

		$content = ($opt{'had_message'})
			? format_info($content)
			: format_info_prefix($content);

		$content = format_wrapend($content)  if $token->is(T_WRAPEND);

		return $content;
	}

	return format_message($content)
}

## Formatting functions:  ######################################################

sub format_date ($) { $c_date . $_[0] . $c0 }
sub format_host ($) { $c_host . $_[0] . $c0 }
sub format_message ($) { $c_message . $_[0] . $c0 }
sub format_app  ($) { $c_app . $_[0] . $c0 }
sub format_rpt ($) { $c_rpt . $_[0] . $c0 }
sub format_meta ($) { $c_meta . $_[0] . $c0 }

sub _format_tracefile ($$$) {
	my ($file, $lineno, $c_context) = (@_);
	my $include_lineno_in_bold = ($lineno !~ m/(?:on line|in line| line)/);
	my ($c_hi, $c_lo) = _color_hi_lo($c_file_location, $c_context);

	my $file_suffix;
	if ($file =~ s/(["'])$//) { $file_suffix = $1 }

	$c_hi . $file .
	(($include_lineno_in_bold)
		? $file_suffix . $lineno . $c_lo
		: $c_lo . $file_suffix . $lineno)
}

sub format_exception ($) {
	my ($in) = @_;
	my ($prefix, $suffix) = ('', '');
	if ($in =~ s/^((?:[^\\\.]+[\\\.])+)//) { $prefix = $c_exception_fqcn . $1; }
	if ($in =~ s/(\/\d+)$//) { $suffix = $c_exception_code . $1; }
	$prefix . $c_exception_scn . $in . $suffix . $c0
}

sub format_trace ($;$) {
	my ($out, $c_base) = ($_[0], ($_[1] // $c_trace));

	$out =~ s/\b([\w\-\.\$]+["']?)($re_lineno)?(,|\)|\s*$|\])/ _format_tracefile($1, $2, $c_base) . $3 /ge;

	$c_base . $out . $c0
}

sub format_fncall ($$) {
	my ($out, $is_packedline) = (@_);

	my $c_context = ($is_packedline) ? $c_info : $c_message;
	my ($c_hi, $c_lo) = _color_hi_lo($c_function, $c_context);

	$out =~ s#$re_fncall# $+{'class'} . $+{'fnp'} . $c_hi . $+{'fn'}.$+{'fn2'} . $c_lo . format_info( $+{'args'} ) #gem;

	$c_context . $out
}

sub format_json ($) {
	my ($out, $in, $had_message) = ('', $_[0], $_[1]);
	my $c_json = $had_message ? $c_info : $c_message;
	my ($c_key_hi, $c_key_lo) = _color_hi_lo($c_key, $c_json);
	my ($c_wrap_hi, $c_wrap_lo) = _color_hi_lo($c_json_wrap, $c_json);

	while ($in ne '') {
		if ($in =~ s/^$re_json_string(?<rest>\s*:\s*)//) {
			$out .= $+{'jstr0'} . $c_key_hi . $+{'jstr'} . $c_key_lo . $+{'jstr1'} . $+{'rest'};
		} elsif ($in =~ s/^($re_json_string|[^\\"]+)//) {
			$out .= $1;
		}
	}

	if ($out =~ m/^(\s*\{)(.+)(\}\s*)\s*$/ || $out =~ m/^(\s*\[)(.+)(\]\s*)\s*$/) {
		$out = $c_wrap_hi . $1 . $c_wrap_lo . $2 . $c_wrap_hi . $3 . $c_wrap_lo;
	}

	$c_json . $out . $c0
}

sub format_http ($) {
	my $status = $_[0];

	my $c_http;
	if    (is_http_client_error($status))   { $c_http = $c_http_client_error }
	elsif (is_http_client_failure($status)) { $c_http = $c_http_client_failure }
	elsif (is_http_server_error($status))   { $c_http = $c_http_server_error }
	elsif (is_http_success($status))        { $c_http = $c_http_success }
	elsif (is_http_info($status))           { $c_http = $c_http_info }
	elsif (is_http_redir($status))          { $c_http = $c_http_redir }
	else { return $status }

	$c_http . $status . $c0
}

#sub format_postfix_info ($) {
#	my ($info, $out, $c_pfinfo, $c_hi, $c_lo) = ($_[0], '', $c_info, $c_bold, $c_unbold);
#
#	my $re_replycode = '[2345]\d\d';
#	my $re_dsn       = '\d\.\d\.\d';
#
#	$info =~ s/(?<=[\( ])(${re_replycode}(?:[\- ](?:${re_dsn})?)?)\b/ $c_hi . $1 . $c_lo /ge;
#
#	$c_pfinfo . $info . $c0
#}

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

sub format_rfc5424_sd ($;$) {
	my ($in, $out, $c_context) = ($_[0], '', $_[1]//'');
	my ($c_id_hi, $c_id_lo) = _color_hi_lo($c_key, $c_context);
	my ($c_pn_hi, $c_pn_lo) = _color_hi_lo($c_key, $c_context);

	while ($in =~ s/^(\[)([^\s\]]+)((?: [^=]+=\"[^"]*\")*)(\] ?)//) {
		my ($prefix, $id, $params, $suffix) = ($1, $2, $3, $4);

		my $params_out = '';
		while ($params =~ m/( +)([^=]+)(=)(\"[^"]*\")/g) {
			$params_out .= $1 . $c_pn_hi . $2 . $c_pn_lo . $3 . $4;
		}

		$out .= $prefix . $c_id_hi . $id . $c_id_lo . $params_out . $suffix;
	}

	$c_context . $out . $in
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

	$in =~ s/(?<=stack: )$re_exc_msg/ format_exception($1) . $c_stack . $2 . &$fmt_stack_msg($3) /e;
	$in =~ s/(?<=; )$re_exc_msg/      format_exception($1) . $c_stack . $2 . &$fmt_stack_msg($3) /ge;
	$c_stack . $in . $c0
}

sub format_wrapbegin ($) {
	my ($in) = ($_[0]);
	$in =~ s/(")(?=\s?$)/$c_bold$1$c_unbold/;
	$in
}

sub format_wrapend ($;$) {
	my ($in, $c0) = ($_[0], $_[1]//'');
	$in =~ s/^($re_ansi_color)?(")/$c_bold$c_info_prefix$2$c_unbold$1/;
	$in
}

sub format_kv ($) {
	my ($token, $content, $k, $is_boring_keyword) = ($_[0], $_[0]->content(), $_[0]->attr('k'));
	my $c_context = $c_message;
	my ($c_key_hi, $c_key_lo) = _color_hi_lo($c_key, $c_context);

	if ($token->attr('src') eq 'postfix') {
		if ($k eq 'dsn' && $content =~ m/^${re_kv}$/) {
			$content = $+{'k'} . $+{'s'} . format_postfix_status($+{'v'});
		}
		$is_boring_keyword = ($k =~ m/^(?:delays?|size|nrcpt)$/);
	}

	$content =~ s/\b($k)\b/${c_key_hi}$1${c_key_lo}/  unless $is_boring_keyword;
	return $c_context . $content
}

# _color_hilo $hiColor $contextColor
#  Returns a 'high' color code (unchanged)
#  and a corresponding 'low' color code.
#  If the 'high' color code was $c_bold, 'low' will simply be $c_unbold;
#  in all other cases, 'low' will be SGR0 + $contextColor.
sub _color_hi_lo ($;$) {
	return (
		$_[0],
		(($_[0] eq $c_bold)
			? $c_unbold
			: (($_[1] eq $c0) ? $c0 : $c0.$_[1])
		))
}


1
