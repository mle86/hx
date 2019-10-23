#!/bin/sh
. $(dirname "$0")/init.sh

# hx supports the "printer" output mode
# in which it doesn't try to analyze any log input,
# it simply accepts a prepared token stream
# (as returned by the --lexer mode)
# and turns it into readable colorized output.
#
# So if the --lexer and the --printer mode are combined,
# the result should be exactly the same as the default mode!


# assertSamePrinterOutput LINE
#  Compares the results of "hx --lexer | hx --printer" against the "hx" default mode.
#  If everything is in order, both commands should have identical output.
assertSamePrinterOutput () {
	local inputLine="$1"
	local normalModeOutput="$(printf '%s\n' "$inputLine" | HX)"
	local printerOutput="$(printf '%s\n' "$inputLine" | LEX | HX --printer)"

	assertEq "$printerOutput" "$normalModeOutput" \
		"\"hx\" and \"hx --lexer | hx --printer\" produced different output!"
}


assertSamePrinterOutput "$(syslogline 1)"
assertSamePrinterOutput "$(sysloggrep 'OUT=eth0')"
assertSamePrinterOutput "$(sysloggrep 'repeated 5 times')"
assertSamePrinterOutput "$(logline "$HERE/samples/apache2.log" 1)"


success
