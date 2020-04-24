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


success
