#!/bin/sh
. $(dirname "$0")/init.sh

# hx recognizes the HX_COLORS env variable
# which can be used to set custom colors
# for various token classes.
#
# This test depends on test-mode-printer
# because this way we don't have to use any specific log format
# (which might require specific tests to be run first)
# and on test-set-settings
# so that we can set custom prefix symbols.

strip_sgr0 () { perl -pe "s/\\x1b\\[0m//g"; }
re_linebegin="^${RE_SGR0}?"

PRN () {
	local colorDefinitions="$1" ; shift
	HX_COLORS="$colorDefinitions" HX_SETTINGS="px=\"# \"" "$HX" --printer "$@"
}

input="$HERE/samples/alltokens.hxt"


# Using the "*=0" sequence should get rid of all coloring sequences except possibly SGR0:
outputWithoutColors="$(PRN '*=0' < "$input" | strip_sgr0)"
assertContainsNoAnsiSequences "$outputWithoutColors" \
	"hx with HX_COLORS=\"*=0\" still produced some ANSI sequences in its output!"

# prefix symbols in red, green, blue;
# date in bold-red, app in bold-green, host in bold-yellow, info-prefixes in bold-violet, info-suffixes in violet;
# message in faint-white;
# nothing else.
output="$(PRN 'SY=31:ML=32:CL=34:dt=1;31:ap=1;32:hn=1;33:ix=1;35:in=35:ms=2;37:*=0' <"$input")"
assertRegex "$output" "/${re_linebegin}$(re_col 32 "# ").*${re_linebegin}$(re_col 31 "# ").*${re_linebegin}$(re_col 34 "# ")/ms"
assertRegex "$output" "/$(re_b_col 31)date/"
assertRegex "$output" "/$(re_b_col 32)app/"
assertRegex "$output" "/$(re_b_col 33)host/"
assertRegex "$output" "/$(re_b_col 35)infoprefix/"
assertRegex "$output" "/$(re_col   35)infosuffix/"
assertRegex "$output" "/$(re_col  '2;37')message/"

# json wrapper in yellow; keys in blue; nothing else.
output="$(PRN 'jw=33:ke=34:*=0' <"$input")"
assertRegex "$output" "/$(re_col 33)\{$(re_col 0)\"$(re_col 34)k1$(re_col 0)\":\[2.*\"$(re_col 34)y1$(re_col 0)\":\"json\"[^\x1b]*\}\]$(re_col 33)\}$(re_col 0)/"


success
