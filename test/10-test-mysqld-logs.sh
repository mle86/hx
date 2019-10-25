#!/bin/sh
. $(dirname "$0")/init.sh

logfile="$HERE/samples/mysqld.log"


# 2019-05-21T12:25:57.649219Z 0 [Note] /usr/sbin/mysqld: ready for connections.
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "2019-05-21T12:25:57.649219Z")/"
assertRegex "$line" "/$(re_tok $T_INFO "0")/"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL "\[Note\]")/"
assertRegex "$line" "/$(re_tok $T_APP "\/usr\/sbin\/mysqld:?")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "ready for connections.")/"


success
