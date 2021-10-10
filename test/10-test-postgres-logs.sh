#!/bin/sh
. $(dirname "$0")/init.sh

logfile="$HERE/samples/postgres.log"


# 2021-10-10 11:00:00.001 UTC [16000] LOG:  listening on IPv4 address "0.0.0.0", port 5432
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "2021-10-10 11:00:00.001 UTC")/"
assertRegex "$line" "/$(re_tok $T_INFO "\[16000\]")/"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL "LOG: ?")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "listening on IPv4 address \"0.0.0.0\", port 5432")/"

# 2021-10-10 12:00:00.001 UTC [16000] user@db LOG:  could not receive data from client: Connection reset by peer
line="$(logline "$logfile" 2 | LEX)"
assertRegex "$line" "/$(re_tok $T_INFO "\[16000\]")$(re_tok $T_CLIENT "user@db")$(re_tok $T_LOGLEVEL "LOG: ?")/"


success
