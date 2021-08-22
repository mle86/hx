#!/bin/sh
. $(dirname "$0")/init.sh


logfile="$HERE/samples/nextcloud.log"


# 2021-08-22 12:00:00:600 [ warning nextcloud.sync.networkjob ]:	Network job timeout QUrl("/")
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "2021-08-22 12:00:00:600")/"
assertRegex "$line" "/$(re_tok "$T_LOGLEVEL|$T_INFO" "\[.*")/"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL ".*warning.*")/"
assertRegex "$line" "/$(re_tok $T_APP "nextcloud\.sync\.networkjob \]:\s*")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "Network job timeout.*")/"

# 2021-08-22 12:00:00:603 [ debug nextcloud.sync.cookiejar ]	[ OCC::CookieJar::cookiesForUrl ]:	QUrl("...") requests: (...)
line="$(logline "$logfile" 2 | LEX)"
assertRegex "$line" "/$(re_tok $T_APP "nextcloud\.sync\.cookiejar \]\s*")$(re_tok $T_INFO "\[ OCC::CookieJar::cookiesForUrl \]:\s*")$(re_tok $T_MESSAGE "QUrl.*")/"


success
