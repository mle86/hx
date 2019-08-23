#!/bin/sh

HX="$HERE/../src/hx"

SYSLOG="$HERE/samples/syslog.log"


# re_b
#  Regex to match the sequence which turns text bold.
re_b () { printf '%s' "\\x1b\\[(?:(?:\\d\\+;)*0;)?1m"; }

# re_col COLORCODE
#  Regex to match the sequence which colorizes text.
#  Separate multiple allowed color codes with "|".
re_col () { printf '%s' "\\x1b\\[(?:(?:\\d\\+;)*0;)?(?:$1)m"; }

# re_b_col COLORCODE
#  Regex to match the sequence which colorizes and boldens text.
#  Separate multiple allowed color codes with "|".
re_b_col () { printf '%s' "\\x1b\\[(?:(?:\\d\\+;)*0;)?(?:(?:$1)(?:;|\\x1b\\[)1|1(?:;|\\x1b\\[)(?:$1))m"; }

