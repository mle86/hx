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

# [    0.247623] kernel:   #2  #3  #4  #5  #6  #7  #8  #9 #10 #11 #12 #13 #14 #15
line="$(logline "$logfile" 2 | LEX)"
assertRegex "$line" "/$(re_tok $T_CONTLINE).*$(re_tok $T_INFO " *#2  #3.*")/"


success
