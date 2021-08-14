#!/bin/sh
. $(dirname "$0")/init.sh

logfile="$HERE/samples/bug-http-status.log"


# 2021-08-10 12:00:00,306:DEBUG:urllib3.connectionpool:http://r3.o.lencr.org:80 "POST / HTTP/1.1" 200 503
line="$(logline "$logfile" | LEX)"
reLine=
reLine="$reLine$(re_tok $T_DATE "2021-08-10 12:00:00,306:")"
reLine="$reLine$(re_tok $T_LOGLEVEL "DEBUG:")"
reLine="$reLine$(re_tok $T_APP "urllib3\.connectionpool:")"
assertRegex "$line" "/$reLine/"
reLine="(?:$(re_tok $T_MESSAGE "http://r3.o.lencr.org:80")$(re_tok $T_MESSAGE "\"POST / HTTP/1.1\".*")|$(re_tok $T_MESSAGE "http://r3.o.lencr.org:80 \"POST / HTTP/1.1\".*"))"
assertRegex "$line" "/$reLine/" \
	"HTTP status at end of line was printed in the wrong position!"


success
