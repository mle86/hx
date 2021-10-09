#!/bin/sh
. $(dirname "$0")/init.sh

logfile="$HERE/samples/bug-fn-inuse.log"


# 2020-04-24 13:02:13,114 WARN: Strange entry in use/foo/bar.html
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_MESSAGE "Strange entry")/"
assertRegex "$line" "/$(re_tok $T_TRACE   "in use\/foo\/bar\.html")/"

# 2020-04-24 13:02:13,114 WARN: Syntax error in use.c
line="$(logline "$logfile" 2 | LEX)"
assertRegex "$line" "/$(re_tok $T_MESSAGE "Syntax error")/"
assertRegex "$line" "/$(re_tok $T_TRACE   "in use\.c")/"

# 2020-04-24 13:02:13,114 WARN: Address already in use
line="$(logline "$logfile" 3 | LEX)"
assertRegex "$line" "/$(re_tok $T_MESSAGE "Address already in use")/" \
	"A trailing 'in use' was incorrectly recognized as a filename suffix."

# 2021-10-09 12:00:00,000 WARN: unexpected end-of-file in prolog
line="$(logline "$logfile" 4 | LEX)"
assertRegex "$line" "/$(re_tok $T_MESSAGE "unexpected end-of-file in prolog")/" \
	"A trailing 'in prolog' was incorrectly recognized as a filename suffix."


success
