#!/bin/sh
. $(dirname "$0")/init.sh

# Tests processing of the "tail -f" output format.
#
# This test depends on test-syslog-logs.


logfile="$HERE/samples/tail-f.log"
output="$(HX --lexer < "$logfile")"


# ==> /var/log/auth.log <==
# Jun 24 01:37:40 myhost CRON[17920]: pam_unix(cron:session): session opened for user root by (uid=0)
# ==> /var/log/auth.log.1 <==
# Jun 24 01:37:40 myhost CRON[17921]: pam_unix(cron:session): session closed for user root

re_meta1="$(re_tok $T_METALINE)$(re_tok $T_MESSAGE "==>")$(re_tok $T_FILENAME "\/var\/log\/auth\.log")$(re_tok $T_MESSAGE "<==$(re_optbrk)")"
re_meta2="$(re_tok $T_METALINE)$(re_tok $T_MESSAGE "==>")$(re_tok $T_FILENAME "\/var\/log\/auth\.log\.1")$(re_tok $T_MESSAGE "<==$(re_optbrk)")"

re_app1="$(re_tok $T_APP "CRON\[17920\]:?")"
re_app2="$(re_tok $T_APP "CRON\[17921\]:?")"

re_msg1="$(re_tok $T_MESSAGE ".*session opened.*")"
re_msg2="$(re_tok $T_MESSAGE ".*session closed.*")"

assertRegex "$output" "/${re_meta1}.*${re_app1}.*${re_msg1}.*${re_meta2}.*${re_app2}.*${re_msg2}/s"


success
