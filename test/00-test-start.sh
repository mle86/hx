#!/bin/sh
. $(dirname "$0")/init.sh

# Make sure the program can start and can handle input,
# i.e. it won't crash and it will print _something._


assertCmd "\"$HX\" </dev/null"


assertCmd "head -n1 \"$HERE/samples/syslog.log\" | \"$HX\""

[ -n "$ASSERTCMDOUTPUT" ] || fail "hx produced no output!"

assertContains "$ASSERTCMDOUTPUT" '[' \
	"hx output contained no ansi coloring sequences at all!"


success
