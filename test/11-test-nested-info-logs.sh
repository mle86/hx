#!/bin/sh
. $(dirname "$0")/init.sh

# Tests nested info brackets.
#
# This test depends on test-syslog-logs.

logfile="$HERE/samples/nested-info.log"


# Aug  1 12:00:00 myhost kernel: [drm:drm_dp_send_dpcd_read [drm_kms_helper]] info
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_INFO "\[drm:drm_dp_send_dpcd_read \[drm_kms_helper\]\]")/"


success
