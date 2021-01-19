#!/bin/sh
. $(dirname "$0")/init.sh

# This test depends on test-syslog-logs.

logfile="$HERE/samples/syslog-java.log"
re_backslash='(?:\\)'


# Jan 19 18:10:07 mypc myapp[100]: 2021-01-19 18:10:07,591 [1234567]   WARN - my.app.name - failed to boot
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "Jan 19 18:10:07")/"
assertRegex "$line" "/$(re_tok $T_APP "myapp\[100\]:?")/"
assertRegex "$line" "/$(re_tok $T_DATE "2021-01-19 18:10:07,591")/"
assertRegex "$line" "/$(re_tok $T_INFO "\[1234567\]")/"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL "WARN\W*")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE ".*failed to boot")/"

# Jan 19 18:12:15 mypc myapp[100]: org.myapp.MyJavaException: Not acceptable.
line="$(logline "$logfile" 2 | LEX)"
assertRegex "$line" "/$(re_tok $T_ERROR "org\.myapp\.MyJavaException:?")/"

# Jan 19 18:12:15 mypc myapp[100]: Error: Not acceptable.
# Jan 19 18:12:15 mypc myapp[100]:     at Object.method (./proj/helper/test.js:31:34)
line="$(logline "$logfile" 3 | LEX)"
assertRegex "$line" "/^$(re_tok $T_CONTLINE)/"
assertRegex "$line" "/$(re_tok $T_INFO "\s*at Object\.method\W*")/"
assertRegex "$line" "/$(re_tok $T_TRACE "\W*\.\/proj\/helper\/test\.js:31:34\W*")/"

# Jan 19 18:12:16 mypc myapp[100]: stderr: /home/me/proj/src/test.js:44
line="$(logline "$logfile" 5 | LEX)"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL "stderr:?")/"
assertRegex "$line" "/$(re_tok "$T_TRACE|$T_FILENAME" "\/home\/me\/proj\/src\/test\.js:44")/"


success
