#!/bin/sh
. $(dirname "$0")/init.sh

# hx recognizes the HX_SETTINGS env variable
# which can be used to enable/disable/change some settings.
#
# This test depends on test-reduced-colors.

# Jun 24 01:37:40 myhost CRON[17920]: pam_unix(cron:session): session opened for user root by (uid=0)
normline="$(logline "$HERE/samples/tail-f.log" 2)"
# ==> /var/log/auth.log <==
metaline="$(logline "$HERE/samples/tail-f.log" 1)"
#     thrown in File:123
contline="    thrown in File:123"
lmc_input="$(printf '%s\n%s\n%s\n' "$normline" "$metaline" "$contline")"


# Test "ecma48" option:
assertEq "$(HX_SETTINGS='ecma48' "$HX" < "$HERE/samples/syslog.log")" "$(HX --ecma48 < "$HERE/samples/syslog.log")" \
	"HX_SETTINGS=ecma48 did not have same effect as --ecma48 cmdline option!"

# Test "ecma48" option plus garbage options:
assertEq "$(HX_SETTINGS=' foo  ecma48  bar  ' "$HX" < "$HERE/samples/syslog.log")" "$(HX --ecma48 < "$HERE/samples/syslog.log")" \
	"HX_SETTINGS=\"garbage ecma48 garbage\" did not have same effect as --ecma48 cmdline option!"

# Test "noecma48" option right after "ecma48" option:
assertEq "$(HX_SETTINGS=' foo  ecma48  bar  noecma48  ' "$HX" < "$HERE/samples/syslog.log")" "$(HX < "$HERE/samples/syslog.log")" \
	"HX_SETTINGS=\"ecma48 noecma48\" did NOT disable the ecma48 output mode!"


# Test "lp"/"cp"/"mp" options:
set_prefixes='foo mp="<M> " cp="<C> " bar lp="<L> " zog'
output="$(printf '%s\n' "$lmc_input" | HX_SETTINGS="$set_prefixes" "$HX" | strip_ansi)"
assertRegex "$output" "/^<L> Jun/m"
assertRegex "$output" "/^<M> ==>/m"
assertRegex "$output" "/^<C> \s*thrown/m"

# Test "loglineprefix"/"contlineprefix"/"metalineprefix" options:
set_prefixes='metalineprefix="<MM> " contlineprefix="<CC> " loglineprefix="<LL> "'
output="$(printf '%s\n' "$lmc_input" | HX_SETTINGS="$set_prefixes" "$HX" | strip_ansi)"
assertRegex "$output" "/^<LL> Jun/m"
assertRegex "$output" "/^<MM> ==>/m"
assertRegex "$output" "/^<CC> \s*thrown/m"


# Test "px" option:
set_prefixes='px="<!>" '
output="$(printf '%s\n' "$lmc_input" | HX_SETTINGS="$set_prefixes" "$HX" | strip_ansi)"
assertRegex "$output" "/^<!>Jun/m"
assertRegex "$output" "/^<!>==>/m"
assertRegex "$output" "/^<!>\s*thrown/m"

# Test "lineprefix" option:
set_prefixes='lineprefix="<!!>" '
output="$(printf '%s\n' "$lmc_input" | HX_SETTINGS="$set_prefixes" "$HX" | strip_ansi)"
assertRegex "$output" "/^<!!>Jun/m"
assertRegex "$output" "/^<!!>==>/m"
assertRegex "$output" "/^<!!>\s*thrown/m"


success
