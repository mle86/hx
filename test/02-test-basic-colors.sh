#!/bin/sh
. $(dirname "$0")/init.sh


SYSLOGLINE="$(syslogline 1 | HX)"
KERNELLINE="$(sysloggrep 'OUT=eth0' | HX)"
REPEATLINE="$(sysloggrep 'repeated 5 times' | HX)"

color_date='33'
color_host="$color_date"
color_app="$color_date"
color_msg='37|0'
color_rpt='34'
color_info='30|37|38;5;243'
color_prefix="$color_info|38;2;125;117;83"


assertRegex "$SYSLOGLINE" "/$(re_col $color_date)Jun 16\\b/"
assertRegex "$SYSLOGLINE" "/$(re_col $color_host)test-pc\\b/"
assertRegex "$SYSLOGLINE" "/$(re_col $color_app)rsyncd\\b/"
assertRegex "$SYSLOGLINE" "/$(re_col $color_msg)sent 63 bytes\\b/"

assertRegex "$KERNELLINE" "/$(re_col $color_prefix)\\[269611.241825\\]/"

assertRegex "$REPEATLINE" "/$(re_col $color_rpt)message repeated 5 times:/"


success
