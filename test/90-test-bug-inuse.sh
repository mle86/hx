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

line="$(logline "$HERE/samples/certbot.log" 2 | LEX)"
# 2019-06-05 04:33:37,590:WARN:certbot.log:Root logging level set at 30
assertRegex "$line" "/$(re_tok $T_MESSAGE ":?Root logging level set at 30")/" \
	"A trailing 'set at 30' was incorrectly recognized as a filename suffix."

# Mar 03 12:00:00 myftp daemon: Cannot create directory: File exists
line="$(logline "$logfile" 5 | LEX)"
reOriginalMessage="$(re_tok $T_MESSAGE "Cannot create directory: File exists")"
reSplitMessage="$(re_tok $T_MESSAGE "Cannot create directory:?")$(re_tok $T_MESSAGE ":? ?File exists")"
assertRegex "$line" "/(?:$reOriginalMessage|$reSplitMessage)/" \
	"A trailing 'file exists' was incorrectly recognized as a filename suffix."


success
