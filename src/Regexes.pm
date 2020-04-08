#!/usr/bin/perl
use strict;
use vars qw(
	$re_json $re_json_string
	$re_continuation_line $re_repeat_begin $re_repeat_end
	$re_lineno $re_loglevel
	$re_fncall
	$re_exception
	$re_path $re_abspath
	$re_app $re_host $re_client
	$re_word
	$re_time $re_ddd $re_ms $re_ymd $re_ts8601 $re_tsw $re_sects
	$re_a2date $re_a2clnt $re_a2err $re_http
	$re_mysqld
	$re_dmesg_ts $re_dmesg_app
	$re_tail_filename
	$re_cron_cmd
	$re_kv
	$re_ansi_color
);


## Regular Expressions:  #######################################################

my  $re_json_number     = qr/\s*-?\d+(?:\.\d+)?(?:[eE][\-\+]?\d+)?\s*/;
my  $re_json_const      = qr/\s*(?:null|true|false)\s*/;
our $re_json_string     = qr/(?<jstr0>\s*")(?<jstr>(?:\\.|[^"\\]+)*+)(?<jstr1>"\s*)/;
my  $re_json_array      = "\\s*\\[(?:(?&json)(?:,(?&json))*|\\s*)\\]\\s*";
my  $re_json_object     = "\\s*\\{(?:$re_json_string:(?&json)(?:,$re_json_string:(?&json))*|\\s*)?\\}\\s*";
our $re_json            = qr/(?<json>$re_json_number|$re_json_const|$re_json_string|$re_json_array|$re_json_object)/;

our $re_continuation_line = qr/(?:^\s*(?:#\d+\b|URI:|Referr?er:|User-?[Aa]gent:|Stack trace:$|CLI:|  thrown in | {16,}|\tat))/;
our $re_repeat_begin      = qr/(?:(?<prefix>message repeated (?<n>\d+) times: \[)(?<rest>\s*))/;
our $re_repeat_end        = qr/(?:\s*\]\s*)/;

our $re_lineno   = qr/(?::\d+|\(\d+\)| on line \d+|, line:? \d+| line:? \d+)/;

our $re_loglevel = qr/(?:(?:PHP )?(?i:warn|warning|warnung|err|error|fehler|info|information|note|notice|hinweis|crit|critical|schwerwiegend|emerg|emergency|debug[123]?|dbg|fine|alrt|alert|parse error|fatal error))/;

my $re_loglevel_warn = qr/\b(?:warn|warning|warnung)\b/i;
my $re_loglevel_err  = qr/\b(?:err|error|errors|fehler|crit|critical|schwerwiegend|alrt|alert|emerg|emergency)\b/i;
sub read_loglevel ($) {
	if    ($_[0] =~ m/$re_loglevel_warn/i) { return level => L_WARNING }
	elsif ($_[0] =~ m/$re_loglevel_err/i)  { return level => L_ERROR }
	return level => L_LOW
}

my  $re_nsname    = qr/(?:\\?(?:[A-Za-z]\w*\\)+)/;
my  $re_classname = qr/(?:$re_nsname?[A-Za-z]\w+)/;
my  $re_fnname    = qr/(?:[A-Za-z_]\w*|\{closure\})/;
my  $re_fnprefix  = qr/(?:->|::)/;
our $re_fncall    = qr/(?:(?<class>${re_nsname}(?=\{)|${re_classname}(?=${re_fnprefix})|${re_classname}::${re_nsname})?(?<fnp>${re_fnprefix})?(?<fn>${re_fnname})(?<args> ?\(.*\)))/;

my  $re_fqcn      = qr/(?:(?:[A-Za-z][A-Za-z0-9_]+\\)+[A-Za-z][A-Za-z0-9_]*\b)/;  # fqcn must contain backslashes
my  $re_excn      = qr/(?:(?:[A-Z][A-Za-z0-9_]*)?(?:[Ee]xception|[Ee]rror|Fault)|ExceptionStack)/;  # short exception class name must end in "exception" or "error"
my  $re_ex_code   = qr/(?:\/\d+|\(code:? \d+\))/;
our $re_exception = qr/(?:(?:$re_fqcn|$re_excn)$re_ex_code?)/;

my  $re_pathchr = qr/[A-Za-z0-9\-_\.\+\$@]/;
our $re_abspath = qr/(?:\/[a-z]+[a-z0-9]+(?:\/+${re_pathchr}+)+)/;
my  $re_relpath = qr/(?:(?:${re_pathchr}+:?\/+)*[A-Za-z0-9\-_\.\+\$]+)/;
our $re_path    = qr/(?:$re_abspath|$re_relpath)/;

our $re_time   = qr/(?:\d\d:\d\d:\d\d)/;
our $re_ms     = qr/(?:[\.,]\d{1,6})/;
our $re_ddd    = qr/(?:[A-Za-z]{2,3} +\d+)/;
our $re_ymd    = qr/(?:\d\d\d\d-\d\d-\d\d|\d\d\d\d\/\d\d\/\d\d|\d\d\d\d\.\d\d\.\d\d)/;
my  $re_tz     = qr/(?:[\+\-]\d\d(?::?\d\d(?::\d\d)?)?|Z)/;
our $re_ts8601 = qr/(?:${re_ymd}T${re_time}${re_ms}?${re_tz}?)/;  # 2019-07-07T18:22:34.001Z
our $re_tsw    = qr/(?:\d{1,2}-\w{2,4}-\d{4} ${re_time}${re_ms}?)/;  # 07-Jun-2019 11:36:20.106
our $re_sects  = qw/(?:\[\s*\d+\.\d+\])/;  # [   16.082998]

our $re_app    = qr/(?:[A-Za-z0-9\/][A-Za-z0-9_\-\.\/]+?(?:\[\d+\]|\])?)/;
our $re_word   = qr/(?:[A-Z][a-z]+)/;

my  $re_ip     = qr/(?:\[(?:[0-9a-fA-F]{1,4})?(?:::?[0-9a-fA-F]{1,4}){1,7}\]|(?:[0-9a-fA-F]{1,4})?(?:::?[0-9a-fA-F]{1,4}){1,7}|\d{1,3}(?:\.\d{1,3}){3})/;
our $re_host   = qr/(?:[A-Za-z][A-Za-z0-9_\-\.]+)/;
our $re_client = qr/(?:$re_ip|$re_host)/;

our $re_mysqld = qr/(?:(?:\/usr\/sbin\/)?mysqld: )/;

our $re_a2date = qr/(?:\[ ?\d{1,2}\/\w{3}\/\d{4}[ :T]$re_time(?: ?$re_tz)?\])/;
our $re_a2clnt = qr/(?:(?:\[(?:client )?$re_client(?::\d+)?\]))/;
our $re_a2err  = qr/(?:AH\d+)/;

our $re_http = qr/(?:(?<hs0> *\[)(?<hs>\d\d\d)(?<hs1>\]))/;

our $re_dmesg_ts  = qr/(?:\[\d+${re_ms}?\])/;
our $re_dmesg_app = qr/(?:[A-Za-z0-9][\w\-\.]*(?: [\w\-\.:]+)?)/;

our $re_tail_filename = qr/(?:(?<prefix>==+> +)(?<filename>$re_path)(?<suffix> +<==+\s*$))/;

our $re_cron_cmd = qr/(?<user>\([\w\-]+\))(?<prefix> CMD \( +)(?<cmd>.+)(?<suffix>\)\s*$)/;

our $re_kv = qr/(?<k>\w[\w\.\-]*)(?<s>[=:])(?<v>"[^"]*+"|<[^>]*+>|[^\s,]*+)(?=\s|,|$)/;

our $re_ansi_color = qr/(?:\e\[\d+(?:;\d+)*m)/;
sub get_ansi_prefix ($) {
	return $1 if ($_[0] =~ m/^\s*($re_ansi_color+)/);
}


1
