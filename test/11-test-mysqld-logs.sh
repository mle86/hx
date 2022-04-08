#!/bin/sh
. $(dirname "$0")/init.sh

# This test depends on test-syslog-logs.


logfile="$HERE/samples/mysqld.log"


# 2019-05-21T12:25:57.649219Z 0 [Note] /usr/sbin/mysqld: ready for connections.
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "2019-05-21T12:25:57.649219Z")/"
assertRegex "$line" "/$(re_tok $T_INFO "0")/"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL "\[Note\]")/"
assertRegex "$line" "/$(re_tok $T_APP "\/usr\/sbin\/mysqld:?")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "ready for connections.")/"

# Mar 28 08:15:00 myhost mariadbd[1830]: 2022-03-28  8:15:00 129 [Warning] Access denied for user anonymous@192.168.0.1 (using password: NO)
line="$(logline "$logfile" 7 | LEX)"
re=
re="${re}$(re_tok $T_DATE "Mar 28 08:15:00")"
re="${re}$(re_tok $T_HOST "myhost")"
re="${re}$(re_tok $T_APP "mariadbd\[1830\]:")"
re="${re}$(re_tok $T_DATE "2022-03-28  8:15:00")"
re="${re}$(re_tok $T_INFO "129")"
re="${re}$(re_tok $T_LOGLEVEL "\[Warning\]")"
re="${re}$(re_tok $T_MESSAGE)"
assertRegex "$line" "/$re/"


success
