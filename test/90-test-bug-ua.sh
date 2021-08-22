#!/bin/sh
. $(dirname "$0")/init.sh

logfile="$HERE/samples/bug-ua.log"

# 2021-08-22 12:00:00: User-Agent: Firefox/90.0.0 ...
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_LINE).*$(re_tok $T_MESSAGE "User-Agent: Firefox.*")/" \
	"A log line with 'User-Agent: ...' after a prefix was incorrectly recognized as a continuation line!"


success
