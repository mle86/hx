#!/bin/sh
. $(dirname "$0")/init.sh

# This test depends on test-syslog-logs.

logfile="$HERE/samples/syslog-java.log"


# Jan 19 18:10:07 mypc myapp[100]: 2021-01-19 18:10:07,591 [1234567]   WARN - my.app.name - failed to boot
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "Jan 19 18:10:07")/"
assertRegex "$line" "/$(re_tok $T_APP "myapp\[100\]:?")/"
assertRegex "$line" "/$(re_tok $T_DATE "2021-01-19 18:10:07,591")/"
assertRegex "$line" "/$(re_tok $T_INFO "\[1234567\]")/"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL "WARN\W*")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE ".*failed to boot")/"


success
