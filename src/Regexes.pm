#!/usr/bin/perl
use strict;
use vars qw(
	$re_json $re_json_string
	$re_lineno $re_loglevel
	$re_fncall
	$re_exception
	$re_path $re_abspath
	$re_app $re_host $re_client
	$re_word
	$re_time $re_ddd $re_ms $re_ymd $re_ts8601 $re_tsw
	$re_a2date $re_a2clnt $re_a2err
	$re_mysqld
	$re_dmesg_ts $re_dmesg_app
	$re_tail_filename
);


## Regular Expressions:  #######################################################

my  $re_json_number     = qr/\s*-?\d+(?:\.\d+)?(?:[eE][\-\+]?\d+)?\s*/;
my  $re_json_const      = qr/\s*(?:null|true|false)\s*/;
our $re_json_string     = qr/(?<jstr0>\s*")(?<jstr>(?:\\.|[^"\\]+)*+)(?<jstr1>"\s*)/;
my  $re_json_array      = "\\s*\\[(?:(?&json)(?:,(?&json))*|\\s*)\\]\\s*";
my  $re_json_object     = "\\s*\\{(?:$re_json_string:(?&json)(?:,$re_json_string:(?&json))*|\\s*)?\\}\\s*";
our $re_json            = qr/(?<json>$re_json_number|$re_json_const|$re_json_string|$re_json_array|$re_json_object)/;

our $re_lineno   = qr/(?::\d+|\(\d+\)| on line \d+)/;
our $re_loglevel = qr/(?:(?:PHP )?(?i:warn|warning|warnung|err|error|fehler|info|information|note|notice|hinweis|crit|critical|schwerwiegend|emerg|emergency|debug|dbg|alrt|alert|parse error|fatal error))/;

my  $re_nsname    = qr/(?:\\?(?:[A-Za-z]\w*\\)+)/;
my  $re_classname = qr/(?:$re_nsname?[A-Za-z]\w+)/;
my  $re_fnname    = qr/(?:[A-Za-z_]\w*|\{closure\})/;
my  $re_fnprefix  = qr/(?:->|::)/;
our $re_fncall    = qr/(?:(?<class>${re_nsname}(?=\{)|${re_classname}(?=${re_fnprefix})|${re_classname}::${re_nsname})?(?<fnp>${re_fnprefix})?(?<fn>${re_fnname})(?<args> ?\(.*\)))/;

my  $re_fqcn      = qr/(?:(?:[A-Za-z][A-Za-z0-9_]+\\)+[A-Za-z][A-Za-z0-9_]*\b)/;  # fqcn must contain backslashes
my  $re_excn      = qr/(?:(?:[A-Z][A-Za-z0-9_]*)?(?:[Ee]xception|[Ee]rror)|ExceptionStack)/;  # short exception class name must end in "exception" or "error"
my  $re_ex_code   = qr/(?:\/\d+|\(code:? \d+\))/;
our $re_exception = qr/(?:(?:$re_fqcn|$re_excn)$re_ex_code?)/;

our $re_abspath = qr/(?:\/[a-z]+[a-z0-9]+(?:\/[a-zA-Z0-9\-_\.\$]+)+)/;
my  $re_relpath = qr/(?:(?:[A-Za-z0-9\-_\.\$]+\/)*[A-Za-z0-9\-_\.\$]+)/;
our $re_path    = qr/(?:$re_abspath|$re_relpath)/;

our $re_time   = qr/(?:\d\d:\d\d:\d\d)/;
our $re_ms     = qr/(?:[\.,]\d{1,6})/;
our $re_ddd    = qr/(?:[A-Za-z]{2,3} +\d+)/;
our $re_ymd    = qr/(?:\d\d\d\d-\d\d-\d\d|\d\d\d\d\/\d\d\/\d\d|\d\d\d\d\.\d\d\.\d\d)/;
my  $re_tz     = qr/(?:[\+\-]\d\d(?::?\d\d)?|Z)/;
our $re_ts8601 = qr/(?:${re_ymd}T${re_time}${re_ms}?(?:$re_tz)?)/;  # 2019-07-07T18:22:34.001Z
our $re_tsw    = qr/(?:\d{1,2}-\w{2,4}-\d{4} ${re_time}${re_ms}?)/;  # 07-Jun-2019 11:36:20.106

our $re_app    = qr/(?:[A-Za-z\/][A-Za-z0-9_\-\.\/]+?(?:\[\d+\]|\])?)/;
our $re_word   = qr/(?:[A-Z][a-z]+)/;

my  $re_ip     = qr/(?:\[(?:[0-9a-fA-F]{1,4})?(?:::?[0-9a-fA-F]{1,4}){1,7}\]|(?:[0-9a-fA-F]{1,4})?(?:::?[0-9a-fA-F]{1,4}){1,7}|\d{1,3}(?:\.\d{1,3}){3})/;
our $re_host   = qr/(?:[A-Za-z][A-Za-z0-9_\-\.]+)/;
our $re_client = qr/(?:$re_ip|$re_host)/;

our $re_mysqld = qr/(?:(?:\/usr\/sbin\/)?mysqld: )/;

our $re_a2date = qr/(?:\[ ?\d{1,2}\/\w{3}\/\d{4}[ :T]$re_time(?: ?$re_tz)?\])/;
our $re_a2clnt = qr/(?:(?:\[(?:client )?$re_client(?::\d+)?\]))/;
our $re_a2err  = qr/(?:AH\d+)/;

our $re_dmesg_ts  = qr/(?:\[\d+${re_ms}?\])/;
our $re_dmesg_app = qr/(?:[A-Za-z0-9][\w\-\.]*(?: [\w\-\.:]+)?)/;

our $re_tail_filename = qr/(?:(?<prefix>==+> +)(?<filename>$re_path)(?<suffix> +<==+\s*$))/;


1
