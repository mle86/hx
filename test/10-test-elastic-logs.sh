#!/bin/sh
. $(dirname "$0")/init.sh


logfile="$HERE/samples/elastic.log"

# [2021-08-01T14:00:00.585+0000][1][gc,cpu       ] GC(13) User=0.10s Sys=0.00s Real=0.01s
line="$(logline "$logfile" | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "\[2021-08-01T14:00:00\.585\+0000\]")/"
assertRegex "$line" "/(?:$(re_tok $T_INFO "\[1\]")$(re_tok $T_INFO "\[gc,cpu       \]")|$(re_tok $T_INFO "\[1\]\[gc,cpu       \]"))/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "GC\(13\).*")/"


success
