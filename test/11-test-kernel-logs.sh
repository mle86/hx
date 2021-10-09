#!/bin/sh
. $(dirname "$0")/init.sh

# Tests parsing of dmesg/kernel messages.


logfile="$HERE/samples/dmesg.log"

# [    0.244585] kernel: rcu: Hierarchical SRCU implementation.
line="$(logline "$logfile" 1 | LEX)"
reDate="$(re_tok $T_DATE "\[    0\.244585\]")"
reApp="(?:$(re_tok $T_APP "kernel:")$(re_tok $T_APP "rcu:")|$(re_tok $T_APP "kernel: rcu:"))"
reMsg="$(re_tok $T_MESSAGE "Hierarchical.*")"
assertRegex "$line" "/$reDate$reApp$reMsg/"


success
