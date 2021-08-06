#!/bin/sh
. $(dirname "$0")/init.sh

logfile="$HERE/samples/bug-datedigit.log"


# Wed Aug 14 10:21:13 2021: message
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "Wed Aug 14 10:21:13 2021:?")$(re_tok $T_MESSAGE)/"

# Wed Aug  4 10:21:13 2021: message
line="$(logline "$logfile" 2 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "Wed Aug  4 10:21:13 2021:?")$(re_tok $T_MESSAGE)/" \
	"Single-digit day-of-month with double space was not recognized correctly!"


success
