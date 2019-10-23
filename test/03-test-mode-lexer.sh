#!/bin/sh
. $(dirname "$0")/init.sh

# hx supports the "lexer" output mode
# in which it doesn't colorize the output,
# it shows the raw internal token stream.
# This test ensures that the lexing process works as intended.


SYSLOGLINE="$(syslogline 1 | LEX)"
KERNELLINE="$(sysloggrep 'OUT=eth0' | LEX)"
REPEATLINE="$(sysloggrep 'repeated 5 times' | LEX)"


# The lexed kernel line should contain at least the app name and the info block somewhere:
assertRegex "$KERNELLINE" "/$(re_tok $T_APP "kernel:")/"
assertRegex "$KERNELLINE" "/$(re_tok $T_INFO "\\[269611.241825\\]")/"

# The repetition line should contain T_REPEAT, T_MESSAGE, T_REPEATEND, in this order.
re_repeatline="/$(re_tok $T_REPEAT "message repeated 5 times:.*?").*"
re_repeatline="${re_repeatline}$(re_tok $T_MESSAGE "Failed to load.*").*"
re_repeatline="${re_repeatline}$(re_tok $T_REPEATEND)/"
assertRegex "$REPEATLINE" "$re_repeatline"

# Now we'll try to match one line exactly, token for token:
re_syslogline="/^${RW}$(re_ztok $T_LINE)"
re_syslogline="${re_syslogline}$(re_tok $T_DATE "Jun 16 10:27:20")"
re_syslogline="${re_syslogline}$(re_tok $T_HOST "test-pc")"
re_syslogline="${re_syslogline}$(re_tok $T_APP "rsyncd\\[31755\\]:?")"
re_syslogline="${re_syslogline}$(re_tok $T_MESSAGE "sent 63 bytes  received 100688092 bytes  total size 100663296")"
re_syslogline="${re_syslogline}$(re_ztok $T_EOL)/"
assertRegex "$SYSLOGLINE" "$re_syslogline"


success
