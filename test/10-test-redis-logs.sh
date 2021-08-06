#!/bin/sh
. $(dirname "$0")/init.sh


logfile="$HERE/samples/redis.log"


# 1:M 02 Aug 2021 12:34:56.194 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
line="$(logline "$logfile" 3 | LEX)"
reLine=
reLine="${reLine}$(re_tok $T_INFO "1:M")"
reLine="${reLine}$(re_tok $T_DATE "02 Aug 2021 12:34:56\.194 ")"
reLine="${reLine}(?:$(re_tok $T_LOGLEVEL "# WARNING")|$(re_tok $T_LOGLEVEL "#")$(re_tok $T_LOGLEVEL "WARNING"))"
reLine="${reLine}$(re_tok $T_MESSAGE "overcommit_memory .*")"
assertRegex "$line" "/$reLine/"


success
