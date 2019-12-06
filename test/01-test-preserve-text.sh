#!/bin/sh
. $(dirname "$0")/init.sh

# The logs' plain text content should not change at all!
# We will now redirect ALL log file samples to hx, line for line,
# and compare its output (sans ansi sequences and line symbol) with the original input.


strip_linesym () { perl -pe "s/^● *//"; }

assertSameTextContent () {
	local inputLine="$1"
	local source="$2"

	local strippedOutput="$(
		printf '%s' "$inputLine" |
		"$HX" |
		strip_ansi | strip_linesym )"

	assertEq "$strippedOutput" "$inputLine" \
		"hx changed its plain text input! (source: $source)"
}


for logfile in "$HERE/samples/"*.log; do
	lineno=0
	while IFS= read -r line; do
		lineno="$((lineno + 1))"
		assertSameTextContent "$line" "$logfile:$lineno"

	done <<Z
$(cat -- "$logfile")
Z
done


success
