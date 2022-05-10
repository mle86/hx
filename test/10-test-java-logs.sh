#!/bin/sh
. $(dirname "$0")/init.sh


logfile="$HERE/samples/java.log"


# 2019-10-24 14:31:18.484 FINE MyUtil: moved /tmp/file1 to /tmp/file2 [info]
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "2019-10-24 14:31:18\.484")/"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL "FINE ?")/"
assertRegex "$line" "/$(re_tok $T_APP "MyUtil:?")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE ":? ?moved.*")/"

# 	at org.h2.message.DbException.getJdbcSQLException(DbException.java:357)
line="$(logline "$logfile" 3 | LEX)"
assertRegex "$line" "/^$(re_tok $T_CONTLINE)/"
assertRegex "$line" "/$(re_tok $T_INFO "\s+at org\.h2\.message.*")/"

# 	... 16 more
line="$(logline "$logfile" 5 | LEX)"
assertRegex "$line" "/^$(re_tok $T_CONTLINE)/"
assertRegex "$line" "/$(re_tok $T_INFO "\s*\.\.\. 16 more")/"

#[2020-09-20T06:20:47,942][INFO ][o.e.x.m.p.l.CppLogMessageHandler] [0a0359200001] [controller/100] init
line="$(logline "$logfile" 7 | LEX)"
re=
re="${re}$(re_tok $T_DATE '\[.*\]')"
re="${re}$(re_tok $T_LOGLEVEL '\[INFO \]')"
re="${re}$(re_tok $T_INFO '\[.+CppLogMessageHandler\]')"
re="${re}$(re_tok $T_INFO '\[0a0359200001\].*')"
re="${re}$(re_tok $T_MESSAGE 'init')"
assertRegex "$line" "/$re/"

# [fe80.local..recover()] WARN javax.jmdns.impl.JmDNSImpl - fe80..recover() Could not recover we are Down!
line="$(logline "$logfile" 9 | LEX)"
re=
re="${re}$(re_tok $T_APP '\[fe80.+\(\)\]')"
re="${re}$(re_tok $T_LOGLEVEL 'WARN')"
re="${re}(?:$(re_tok $T_INFO 'javax.*')$(re_tok $T_INFO '-')|$(re_tok $T_INFO 'javax.* -'))"
re="${re}$(re_tok $T_MESSAGE 'fe80.*Could not recover.*')"
assertRegex "$line" "/$re/"

# 18:00:00.357 INFO [Node.<init>] - message
line="$(logline "$logfile" 10 | LEX)"
re=
re="${re}$(re_tok $T_DATE '18:00:00\.357')"
re="${re}$(re_tok $T_LOGLEVEL 'INFO')"
re="${re}$(re_tok $T_APP '\[Node\.<init>\](?: -)?')"
re="${re}$(re_tok "$T_APP|$T_INFO" '-')?"
re="${re}$(re_tok $T_MESSAGE 'message')"
assertRegex "$line" "/$re/"

# 2022-05-10 18:00:00.297:INFO: message
line="$(logline "$logfile" 11 | LEX)"
re=
re="${re}$(re_tok $T_DATE '2022-05-10 18:00:00\.297:')"
re="${re}$(re_tok $T_LOGLEVEL 'INFO:')"
re="${re}$(re_tok $T_MESSAGE 'message')"
assertRegex "$line" "/$re/"


success
