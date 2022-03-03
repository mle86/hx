#!/bin/sh
. $(dirname "$0")/init.sh

# Tests pure-ftpd-specific message parsing.
#
# This test depends on test-syslog-logs.


logfile="$HERE/samples/syslog-pureftpd.log"


# Mar 03 12:00:00 myhost pure-ftpd: (?@127.0.0.1) [INFO] Logout.
line="$(logline "$logfile" 3 | LEX)"
assertRegex "$line" "/$(re_tok $T_CLIENT "\(\?@127\.0\.0\.1\)").*$(re_tok $T_LOGLEVEL "\[INFO\]").*$(re_tok $T_MESSAGE "Logout\.")/"

# Sep 28 12:00:00 myhost pure-ftpd: (username@ip11.22.33.44.isp.net) [DEBUG] Command [list] []
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_CLIENT "\(username@ip11\.22\.33\.44\.isp\.net\)").*$(re_tok $T_LOGLEVEL "\[DEBUG\]").*$(re_tok $T_MESSAGE "Command \[list\] \[\]")/"


success
