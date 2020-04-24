#!/bin/sh
. $(dirname "$0")/init.sh

logfile="$HERE/samples/urls.log"


# 2020-04-24 13:02:15,318 INFO: Server started at http://localhost:8080
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_MESSAGE "Server started")/"
assertRegex "$line" "/$(re_tok $T_TRACE "at http:\/\/localhost:8080")/"

# 2020-04-24 13:02:15,318 INFO: API available at https://test:test@localhost.my-domain/rest.service/api
line="$(logline "$logfile" 2 | LEX)"
assertRegex "$line" "/$(re_tok $T_MESSAGE "API available")/"
assertRegex "$line" "/$(re_tok $T_TRACE "at https:\/\/test:test@localhost\.my-domain\/rest.service\/api")/"


success
