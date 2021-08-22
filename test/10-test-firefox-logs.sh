#!/bin/sh
. $(dirname "$0")/init.sh


logfile="$HERE/samples/firefox.log"


# 1628583436258	FirefoxAccounts	TRACE	initializing new storage manager
line="$(logline "$logfile" 1 | LEX)"
reTs="$(re_tok $T_DATE "1628583436258\t?")"
reApp="$(re_tok $T_APP "\t?FirefoxAccounts\t?")"
reLvl="$(re_tok $T_LOGLEVEL "\t?TRACE\t?")"
reMsg="$(re_tok $T_MESSAGE "init.*")"
assertRegex "$line" "/$reTs$reApp$reLvl$reMsg/"


success
