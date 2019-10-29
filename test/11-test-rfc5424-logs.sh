#!/bin/sh
. $(dirname "$0")/init.sh

# Tests RFC-5424 syslog messages.
#
# This test depends on test-syslog-logs.


logfile="$HERE/samples/syslog-rfc5424.log"
re_backslash='(?:\\)'


# Jun 16 11:31:52 hostname5 1 2019-06-16T11:31:52.892601+02:00 hostname5 user5 - - [timeQuality tzKnown="1" isSynced="1" syncAccuracy="280500"][zoo@123 tiger="hungry"] this is message
line="$(logline "$logfile" 1 | LEX)"
reDate="$(re_tok $T_DATE "Jun 16 11:31:52")"
reHost="$(re_tok $T_HOST "hostname5")"
reVers="$(re_tok $T_INFO "1")"
reTime="$(re_tok $T_DATE "2019-06-16T11:31:52\.892601\+02:00")"
reTag="$(re_tok $T_APP "user5")"
rePid="$(re_tok $T_APP "-")"
reMsgid="$(re_tok $T_INFO "-")"
assertRegex "$line" "/${reDate}${reHost}${reVers}${reTime}${reHost}${reTag}${rePid}${reMsgid}/"
assertRegex "$line" "/$(re_tok $T_INFO "\[timeQuality tzKnown=\"1\" isSynced=\"1\" syncAccuracy=\"280500\"\].*")/"
assertRegex "$line" "/$(re_tok $T_INFO ".*\[zoo@123 tiger=\"hungry\"\]")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "this is message")/"

# Jun 16 11:45:54 hostname5 1 2019-06-16T11:45:54.360888+02:00 hostname5 MYTAG 31247 4X44 [zoo@123 tiger="hungry" zebra="running"][manager@123 qu'otes="ab\c"] this is message.
line="$(logline "$logfile" 3 | LEX)"
reHost="$(re_tok $T_HOST "hostname5")"
reTag="$(re_tok $T_APP "MYTAG")"
rePid="$(re_tok $T_APP "31247")"
reMsgid="$(re_tok $T_INFO "4X44")"
assertRegex "$line" "/${reHost}${reTag}${rePid}${reMsgid}/"
assertRegex "$line" "/$(re_tok $T_INFO "\[zoo@123 tiger=\"hungry\" zebra=\"running\"\].*")/"
assertRegex "$line" "/$(re_tok $T_INFO ".*\[manager@123 qu'otes=\"ab${re_backslash}c\"\]")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "this is message\.")/"


success
