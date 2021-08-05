#!/bin/sh
. $(dirname "$0")/init.sh

logfile="$HERE/samples/bug-inword.log"


# Aug  1 12:00:00 myhost gdm-password]: gkr-pam: unlocked login keyring
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_APP "gdm-password.*")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE ".*unlocked login keyring")/" \
	"A trailing 'login keyring' was incorrectly recognized as 'log' immediately followed by 'in keyring' as an error source!"


success
