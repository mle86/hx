#!/bin/sh
. $(dirname "$0")/init.sh

# The logs' plain text content should not change at all!
# We will now redirect ALL log file samples to hx, line for line,
# and compare its output (sans ansi sequences and line symbol) with the original input.


strip_ansi () { perl -pe "s/\\x1b\\[\\d+(?:;\\d+)*m//g"; }
strip_linesym () { perl -pe "s/^● *//g"; }

assertSameTextContent () {
	local inputLine="$1"
	local source="$3"

	local cmp="$(
		printf '%s' "$actualInput" |
		"$HX" |
		strip_ansi | strip_linesym )"

	assertEq "$cmp" "$expectedPlainText" \
		"hx changed its plain text input! (source: $source)"
}


all_lines="$(cat -- "$HERE/samples/"*)"
n_lines="$(printf '%s' "$all_lines" | wc -l)"

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
