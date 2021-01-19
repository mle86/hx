#!/bin/sh
. $(dirname "$0")/init.sh

re_backslash='(?:\\)'
logfile="$HERE/samples/brk.hxt"


# L M(linebrk\nok ) M(backslash\\ok ) M(escaped-n\\nok ) M(backslash-and-linebrk\\\nok ) Z
line="$(HX --printer < "$logfile")"
assertRegex "$line" "/linebrk\nok/"
assertRegex "$line" "/backslash${re_backslash}ok/"

assertRegex "$line" "/escaped-n${re_backslash}nok/" \
	"Regression: escaped backslash-N in serialized tokens was unserialized/unescaped incorrectly!"

assertRegex "$line" "/backslash-and-linebrk${re_backslash}\nok/"


success
