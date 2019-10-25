#!/bin/sh
. $(dirname "$0")/init.sh

# Tests postfix-specific message parsing.
#
# This test depends on test-syslog-logs.


logfile="$HERE/samples/syslog-postfix.log"

# Jun  6 04:47:07 hostname2 postfix/local[8013]: 812F1252C46: to=<root@mecha.hostname.tld>, orig_to=<root>, relay=local, delay=0.03, delays=0.02/0.01/0/0, dsn=2.0.0, status=sent (delivered to mailbox)
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_APP "postfix\/local\[8013\]:?")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "812F1252C46:?")/"
assertRegex "$line" "/$(re_tok $T_KV "to=<root@mecha.hostname.tld>")/"
assertRegex "$line" "/$(re_tok $T_KV "status=sent")/"
assertRegex "$line" "/$(re_tok $T_INFO "\(delivered to mailbox\)")/"

# processing of the DSN status codes is done by the printing module:
dsn_color_success=32  # green
dsn_color_bounce=33  # yellow
dsn_color_error=31  # red
dsn_colors="*=0:h2=${dsn_color_success}:h3=${dsn_color_bounce}:h4=${dsn_color_error}"  # ...and nothing else!
line_dsn_success="$(logline "$logfile" 1 | HX_COLORS="$dsn_colors" "$HX" )"
line_dsn_error="$(logline "$logfile" 2 | HX_COLORS="$dsn_colors" "$HX" )"
assertRegex "$line_dsn_success" "/$(re_col $dsn_color_success)[\d\.]+$(re_col 0)/"
assertRegex "$line_dsn_error" "/$(re_col $dsn_color_error)[\d\.]+$(re_col 0)/"


success
