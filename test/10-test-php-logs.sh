#!/bin/sh
. $(dirname "$0")/init.sh


logfile="$HERE/samples/php.log"


# PHP Warning:  Uncaught CustomException: exception message in /proj/source.php:10
line="$(logline "$logfile" 1 | LEX)"
re_line=
re_line="${re_line}$(re_tok $T_LOGLEVEL "PHP Warning:")\s*"
re_line="${re_line}$(re_tok $T_MESSAGE "Uncaught")\s*"
re_line="${re_line}$(re_tok $T_ERROR "CustomException:?")\s*"
re_line="${re_line}$(re_tok $T_MESSAGE ":")?\s*"
re_line="${re_line}$(re_tok $T_MESSAGE "(?:: )?exception message")\s*"
re_line="${re_line}$(re_tok $T_TRACE "in \/proj\/source.php:10")\s*"
assertRegex "$line" "/$re_line/"


success
