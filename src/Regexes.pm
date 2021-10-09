#!/usr/bin/perl
use strict;
use vars qw(
	$re_json $re_json_string
	$re_py_trace_source $re_py_trace_line
	$re_continuation_line_start $re_continuation_line $re_repeat_begin $re_repeat_end
	$re_lineno $re_loglevel $re_loglevel_short $re_loglevel_prefix
	$re_fnname $re_fncall $re_memaddr
	$re_exception
	$re_info_brackets
	$re_path $re_abspath $re_source
	$re_app $re_ip $re_host $re_client
	$re_word $re_percentage $re_qstr
	$re_time $re_ddd $re_ms $re_dmy $re_ymd $re_dmdty $re_dmdyt $re_ts8601 $re_tsw $re_tsv $re_sects $re_dmyts $re_ymdts $re_unixts
	$re_a2date $re_a2clnt $re_a2err $re_http
	$re_mysqld
	$re_dmesg_ts $re_dmesg_app
	$re_psstime
	$re_tail_filename
	$re_cron_cmd
	$re_kv
	$re_ansi_color
);


## Regular Expressions:  #######################################################

my  $re_sqstr  = qr/(?:'(?:[^'\\]++|\\.)*+')/;  # A singlequote-enclosed string which may contain anything, incl. backslash-escaped singlequotes.
my  $re_dqstr  = qr/(?:"(?:[^"\\]++|\\.)*+")/;  # A doublequote-enclosed string which may contain anything, incl. backslash-escaped doublequotes.
our $re_qstr   = qr/(?:$re_sqstr|$re_dqstr)/;

my  $re_json_number     = qr/\s*-?\d+(?:\.\d+)?(?:[eE][\-\+]?\d+)?\s*/;
my  $re_json_const      = qr/\s*(?:null|true|false)\s*/;
our $re_json_string     = qr/(?<jstr0>\s*")(?<jstr>(?:[^"\\]++|\\.)*+)(?<jstr1>"\s*)/;
my  $re_json_string_nc  = qr/\s*$re_dqstr\s*/;  # like re_json_string, but non-capturing
my  $re_json_array      = "\\s*\\[(?:(?&json)(?:,(?&json))*|\\s*)\\]\\s*";
my  $re_json_object     = "\\s*\\{(?:$re_json_string_nc:(?&json)(?:,$re_json_string_nc:(?&json))*|\\s*)?\\}\\s*";
our $re_json            = qr/(?<json>$re_json_number|$re_json_const|$re_json_string_nc|$re_json_array|$re_json_object)/;
  # NB: the $re_json pattern captures into the <json> group. This means it uses one numbered capture group too.

our $re_lineno   = qr/(?::\d+|\(\d+\)| on line \d+|, line:? \d+| line:? \d+)/;

my  $re_pathchr = qr/[A-Za-z0-9\-_\.\+\$@]/;
our $re_abspath = qr/(?:\/[a-z]+[a-z\-0-9]+(?:\/+${re_pathchr}+)+)/;
my  $re_relpath = qr/(?:(?!use(?:$|\s))(?:${re_pathchr}+:?\/+)*[A-Za-z0-9\-_\.\+\$]+)/;
my  $re_url     = qr/[a-z]+:\/{2,3}+(?:[^@]+@)?+[\w\-]+(?:\.[\w\-]+)*(?::\d+)?(?:\/${re_pathchr}*)*/;
our $re_path    = qr/(?:$re_abspath|$re_relpath|$re_url)/;
our $re_source  = qr/(?:(?:thrown |called )?(?:\bin|\bat|@)(?: file:?)? \[?${re_path}${re_lineno}?\b\]?|(?<=[:,\.] )[Ff]ile:? ${re_path}${re_lineno}?|File \"$re_path\", line \d+\b)/;

our $re_py_trace_source = qr/(?:^  (?=File )$re_source)/;
our $re_py_trace_line = qr/(?:^    \S.*$)/;

my  $re_symfony_loglevels = qr/(?:NOTE|OK|WARNING|ERROR|CAUTION)/;
our $re_loglevel = qr/(?:(?:PHP )?(?:(?i:warning|warnung|warn|error|err|fehler|information|info|notice|noti|note|hinweis|critical|crit|schwerwiegend|emergency|emerg|debug[123]?|dbg|fine|trace|alrt|alert|parse error|fatal error|fatal|stdout|stderr)|$re_symfony_loglevels))/;
our $re_loglevel_short = qr/(?:\b[EW]\b)/;
our $re_loglevel_prefix = qr/(?:<$re_loglevel>  ?|\[$re_loglevel\][: ]|$re_loglevel:(?:  ?|$)|$re_loglevel +- |\*+$re_loglevel[!:]?\*+:? *+)/;

our $re_continuation_line = qr/(?:^\s*?(?:#\d+\b|Stack trace:$|\[stack ?trace\]:?$|Traceback(?: \(most recent call last\))?:$|$re_py_trace_source|CLI:|  thrown in | {16,}|(?:\t|#011| {4,})at|$|\s+!\s+)| \/\/ )/;
our $re_continuation_line_start = qr/(?:(?!^ ! \[$re_symfony_loglevels)$re_continuation_line|^\s*?(?:URI:|Referr?er:|User-?[Aa]gent:))/;
our $re_repeat_begin      = qr/(?:(?<prefix>message repeated (?<n>\d+) times: \[)(?<rest>\s*))/;
our $re_repeat_end        = qr/(?:\s*\]\s*)/;

my $re_loglevel_warn = qr/\b(?:W|warn|warning|warnung|stderr)\b/i;
my $re_loglevel_err  = qr/\b(?:E|err|error|errors|fehler|crit|critical|schwerwiegend|alrt|alert|emerg|emergency|fatal)\b/i;
sub read_loglevel ($) {
	if    ($_[0] =~ m/$re_loglevel_warn/i) { return level => L_WARNING }
	elsif ($_[0] =~ m/$re_loglevel_err/i)  { return level => L_ERROR }
	return level => L_LOW
}

my  $re_nsname    = qr/(?:\\?(?:[A-Za-z]\w*\\{1,2})+)/;
my  $re_classname = qr/(?:$re_nsname?[A-Za-z]\w+)/;
our $re_fnname    = qr/(?:[A-Za-z_]\w*|\{closure\}|<module>)/;
my  $re_fnprefix  = qr/(?:->|::)/;
our $re_fncall    = qr/(?:(?<class>${re_nsname}(?=\{)|${re_classname}(?=${re_fnprefix})|${re_classname}::${re_nsname})?(?<fnp>${re_fnprefix}${re_nsname}?)?(?<fn>${re_fnname})(?<args> ?\(.*\)))/;
our $re_memaddr   = qr/(?:0x[0-9a-fA-F]{6,})/;

my  $re_excn      = qr/(?:(?:[A-Z][A-Za-z0-9_]*)?(?:[Ee]xception|[Ee]rror|Fault|Warning)|ExceptionStack)/;  # short exception class name must end in "exception" or "error"
my  $re_fqcn_php  = qr/(?:(?:[A-Za-z][A-Za-z0-9_]+\\)+[A-Za-z][A-Za-z0-9_]*\b)/;  # fqcn must contain backslashes
my  $re_fqcn_java = qr/(?:#?(?=[a-z])(?:[a-zA-Z0-9\_]+\.)+$re_excn)/;  # fqcn must contain dots
my  $re_ex_code   = qr/(?:\/\d+|\(code:? \d+\))/;
our $re_exception = qr/(?:(?:$re_fqcn_php|$re_fqcn_java|$re_excn)$re_ex_code?)/;

our $re_time   = qr/(?:\d\d:\d\d:\d\d)/;
our $re_ms     = qr/(?:[\.,:]\d{1,6})/;
our $re_ddd    = qr/(?:[A-Za-z]{2,3} +\d+)/;
our $re_ymd    = qr/(?:\d\d\d\d-\d\d-\d\d|\d\d\d\d\/\d\d\/\d\d|\d\d\d\d\.\d\d\.\d\d)/;
our $re_dmy    = qr/(?:\d\d\/[A-Z][A-Za-z]{2}\/\d\d\d\d)/;
my  $re_longtz = qr/(?:\b(?:[A-Z][A-Za-z\-]+ )+T[Ii][Mm][Ee](?: Z[Oo][Nn][Ee])?\b)/;
my  $re_tz     = qr/(?:[\+\-]\d\d(?::?\d\d(?::\d\d)?)?|Z|(?:(?:GMT|UTC)[\+\-]\d\d(?::?\d\d(?: $re_longtz| \($re_longtz\))?+)?+)|GMT|UTC|[A-Z][A-Z]S?T)/;
our $re_dmdyt  = qr/(?:[A-Z][A-Za-z]{2},? [A-Z][A-Za-z]{2}  ?\d\d?(?:st|nd|rd|th)?,? \d\d\d\d,? ${re_time}${re_ms}?(?: $re_tz)?+)/;  # Sun Apr 26 2020 13:49:59 GMT
our $re_dmdty  = qr/(?:[A-Z][A-Za-z]{2},? [A-Z][A-Za-z]{2}  ?\d\d?(?:st|nd|rd|th)?,? ${re_time}${re_ms}?,? \d\d\d\d)/;  # Sun Apr 26 13:49:59 2020
our $re_ts8601 = qr/(?:${re_ymd}T${re_time}${re_ms}?${re_tz}?)/;  # 2019-07-07T18:22:34.001Z
our $re_ymdts  = qr/(?:$re_ymd $re_time$re_ms?(?: ?$re_tz)?)/;  # 2021-01-19 17:47:31.416
our $re_dmyts  = qr/(?:(?:$re_dmy)[: ]$re_time$re_ms?(?: ?$re_tz)?)/;  # 01/Aug/2021:16:59:01 +0200
our $re_tsw    = qr/(?:\d{1,2}-\w{2,4}-\d{4} ${re_time}${re_ms}?)/;  # 07-Jun-2019 11:36:20.106
our $re_tsv    = qr/(?:\d{1,2} \w{2,4}(?: \d{4})? ${re_time}${re_ms}?)/;  # 07 Jun 2019 11:36:20.106
our $re_sects  = qw/(?:\[\+?\s*\d+\.\d+s?\])/;  # [   16.082998]  or  [+146.12s]
our $re_unixts = qw/(?:\d{9,}(?:\.\d*)?)/;  # [   16.082998]  or  [+146.12s]

our $re_app    = qr/(?:[A-Za-z0-9\/][A-Za-z0-9_\-\.\/]+?(?:\[\d+\]|\]| ?\(pid \d+\))?)/;
our $re_word   = qr/(?:[A-Z][a-z]+)/;
our $re_percentage = qr/(?:(?:\.\d+|\d+(?:\.\d+)?)%?)/;

our $re_ip     = qr/(?:\[(?:[0-9a-fA-F]{1,4})?(?:::?[0-9a-fA-F]{1,4}){1,7}\]|(?:[0-9a-fA-F]{1,4})?(?:::?[0-9a-fA-F]{1,4}){1,7}|\d{1,3}(?:\.\d{1,3}){3})/;
our $re_host   = qr/(?:[A-Za-z][A-Za-z0-9_\-\.]+)/;
our $re_client = qr/(?:$re_ip|$re_host)/;

our $re_mysqld = qr/(?:(?:\/usr\/sbin\/)?mysqld: )/;

our $re_a2date = qr/(?:\[ ?\d{1,2}\/\w{3}\/\d{4}[ :T]$re_time(?: ?$re_tz)?\])/;
our $re_a2clnt = qr/(?:(?:\[(?:client )?$re_client(?::\d+)?\]))/;
our $re_a2err  = qr/(?:AH\d+)/;

our $re_http = qr/(?:(?<hs0> *\[)(?<hs>\d\d\d)(?<hs1>\]))/;

our $re_dmesg_ts  = qr/(?:\[\d+${re_ms}?\])/;
our $re_dmesg_app = qr/(?:[A-Za-z0-9][\w\-\.]*(?: [\w\-\.:]+)?)/;

our $re_psstime = qr/(?:\d{4}|\w+\d{1,2}|\d{1,2}:\d{2})/;

our $re_tail_filename = qr/(?:(?<prefix>==+> +)(?<filename>$re_path)(?<suffix> +<==+\s*$))/;

our $re_cron_cmd = qr/(?<user>\([\w\-]+\))(?<prefix> CMD \( +)(?<cmd>.+)(?<suffix>\)\s*$)/;

our $re_kv = qr/(?<k>\w[\w\.\-]*)(?<s>[=:])(?<v>$re_dqstr|<[^>]*+>|[^\s,]*+)(?=\s|,|$)/;

our $re_info_brackets = qr/(\[(?:[^\[\]]++|(?=\[)(?-1))+\])/;

our $re_ansi_color = qr/(?:\e\[\d+(?:;\d+)*m)/;
sub get_ansi_prefix ($) {
	return $1 if ($_[0] =~ m/^\s*($re_ansi_color+)/);
}


1
