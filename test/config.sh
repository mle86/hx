#!/bin/sh

HX="$HERE/../src/hx"
HX () { "$HX" "$@" ; }
LEX () { HX --lexer "$@" ; }


SYSLOG="$HERE/samples/syslog.log"

# logline LOGFILE [LINENO=1 [LINES=1]]
logline () { tail -n "+${2:-1}" -- "$1" | head -n ${3:-1} ; }
# syslogline [LINENO=1]
syslogline () { logline "$SYSLOG" "$1" ; }
# sysloggrep GREPEXPR
sysloggrep () { grep -m 1 -e "$@" -- "$SYSLOG" ; }


# RE_CONTENT:  Matches one character of token content. Add "*" or "+" for an entire token's content.
RE_CONTENT="(?:\\\\.|[^\\\\)])"
# RW:  Matches the whitespace before, between, and after tokens.
RW="(?:^| +|\$|\\n)"
# RE_SGR0:  Matches the ANSI SGR0 sequence.
RE_SGR0='(?:\x1b\[0(?:;0)*m)'


# copied from Token.pm:
T_APP='A'
T_DATE='D'
T_HOST='H'
T_LOGLEVEL='G'
T_LINE='L'
T_EMPTYLINE='EL'
T_METALINE='ML'
T_CONTLINE='CL'
T_PACKEDLINE='PKL'
T_EOL='Z'
T_CLIENT='C'
T_USERNAME='UN'
T_FNCALL='F'
T_INFO='I'
T_STACK='S'
T_TRACE='T'
T_REPEAT='RP'
T_REPEATEND='RE'
T_WRAP='WR'
T_WRAPEND='WE'
T_ERROR='X'
T_MESSAGE='M'
T_KV='KV'
T_JSON='JS'
T_FILENAME='FN'
T_HTTP_STATUS='HS'


strip_ansi () { perl -pe "s/\\x1b\\[\\d+(?:;\\d+)*m//g"; }

# re_b
#  Regex to match the sequence which turns text bold.
re_b () { printf '%s' "\\x1b\\[(?:(?:\\d\\+;)*0;)?1m"; }

# re_col COLORCODE
#  Regex to match the sequence which colorizes text.
#  Separate multiple allowed color codes with "|".
re_col () { printf '%s' "\\x1b\\[(?:(?:\\d\\+;)*0;)?(?:$1)m"; }

# re_b_col COLORCODE
#  Regex to match the sequence which colorizes and boldens text.
#  Separate multiple allowed color codes with "|".
re_b_col () { printf '%s' "\\x1b\\[(?:(?:\\d\\+;)*0;)?(?:(?:$1)(?:;|\\x1b\\[)1|1(?:;|\\x1b\\[)(?:$1))m"; }

# re_xtok TOKENTYPE CONTENT [ISOPT=no]
#  Regex to match one token of TOKENTYPE type (can be multiple allowed types; separate with "|")
#  which either has exact content CONTENT,
#  or whose content is ignored if the second argument is missing.
re_xtok () {
	local re_attr="(?:\\[[^\\]]*\\])?"
	local re_content="${RE_CONTENT}*"
	local opt='?'
	if [ $# -ge 2 ]; then
		re_content="$2"
		if [ -n "$2" ] && [ "$2" != " ? ?" ] && [ "$3" != "yes" ]; then
			opt=
		fi
	fi

	# Token contents cannot contain plain closing parentheses.
	# To avoid cluttering all regexes in the test scripts,
	# let's make sure our patterns match the actually expected contents:
	re_content="$(printf '%s' "$re_content" | sed 's/\\)/\\\\\\)/g')"

#	printf '%s' "(?:^|\\s)(?:$1)${re_attr}(?:\\(${re_content}\\))${opt}${RW}"
	printf '%s' "(?:\\b(?:$1)${re_attr}(?:\\(${re_content}\\))${opt}${RW})"
}

# re_tok TOKENTYPE CONTENT
#  Regex to match one token of TOKENTYPE type (can be multiple allowed types; separate with "|")
#  which either has content CONTENT (where one leading and/or one trailing space will be ignored),
#  or whose content is ignored if the second argument is missing.
re_tok () {
	if [ $# -lt 2 ]; then re_xtok "$1"; return; fi
	re_xtok "$1" " ?$2 ?"
}

# re_ztok TOKENTYPE
#  Matches an empty token.
#  If the TOKENTYPE is T_EOL or T_EMPTYLINE, a linebreak content is also allowed.
re_ztok () {
	local re_content=''
	if [ "$1" = "$T_EOL" ] || [ "$1" = "$T_EMPTYLINE" ]; then
		re_content="(?:\\\\n)?"
	fi
	re_xtok "$1" "$re_content" yes
}

# re_optbrk
#  Matches an optional linebreak.
re_optbrk () {
	printf '%s\n' "(?:\\\\n)?"
}

# assertContainsNoAnsiSequences STRING [ERRMSG]
assertContainsNoAnsiSequences () {
	assertRegex "$1" "!/\x1b\[/" \
		"${2:-"String '$1' contained ANSI sequences when it shouldn't!"}"
}

