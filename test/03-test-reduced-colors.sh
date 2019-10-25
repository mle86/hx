#!/bin/sh
. $(dirname "$0")/init.sh

# The --ecma option enables simplifies color output.
#
# This test depends on test-basic-colors.


allowed_codes='(?:0|1|2|22|3[1-7])'
re_allowed_sequences="\x1b\[$allowed_codes(?:;$allowed_codes)*m"
re_ansi_sequence="\x1b\["

assertContainsOnlyAllowedAnsiSequences () {
	local logfile="$1"
	local output="$(HX --ecma48 < "$logfile")"

	local outputWithoutAllowedSequences="$(printf '%s\n' "$output" | perl -pe "s/${re_allowed_sequences}//g" )"

	assertRegex "$outputWithoutAllowedSequences" "!/$re_ansi_sequence/" \
		"\"hx --ecma48 < $(basename -- "$logfile")\" still produced unexpected ANSI sequences!"
}


assertContainsOnlyAllowedAnsiSequences "$HERE/samples/syslog.log"
assertContainsOnlyAllowedAnsiSequences "$HERE/samples/apache2.log"
assertContainsOnlyAllowedAnsiSequences "$HERE/samples/mysqld.log"


success
