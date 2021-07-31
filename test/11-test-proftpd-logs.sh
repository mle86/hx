#!/bin/sh
. $(dirname "$0")/init.sh

# Tests proftpd-specific message parsing.
# (Similar to syslog.)


logfile="$HERE/samples/proftpd.log"

# 2020-07-10 12:00:00,001 mysys proftpd[20000] mysys: ProFTPD 1.3.5e standalone mode SHUTDOWN
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "2020-07-10 12:00:00,001")/"
assertRegex "$line" "/$(re_tok $T_HOST "mysys")/"
assertRegex "$line" "/(?:$(re_tok $T_APP "proftpd\[20000\] mysys:?")|$(re_tok $T_APP "proftpd\[20000\]")$(re_tok "$T_APP|$T_HOST" "mysys:?"))/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "ProFTPD.*")/"


success
