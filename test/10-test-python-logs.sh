#!/bin/sh
. $(dirname "$0")/init.sh

logfile="$HERE/samples/python.log"


# 2019-05-31 11:42:02,115 - __init__.py[WARN]: Attempting setup of ephemeral network on ens3 with 169.254.0.1/16 brd 169.254.255.255
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "2019-05-31 11:42:02,115(?: -)?")/"
assertRegex "$line" "/$(re_tok $T_APP "__init__\.py")/"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL "\[WARN\]:?")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "Attempting .*")/"

# error: <class 'socket.error'>, [Errno 99] Cannot assign requested address: file: /usr/lib/python2.7/socket.py line: 571
line="$(logline "$logfile" 2 | LEX)"
reError="$(re_tok $T_LOGLEVEL "error:?")"
reType="$(re_tok $T_APP ":? ?<class 'socket\.error'>,?")"
reErrno="$(re_tok $T_ERROR ",? ?\[Errno 99\]")"
reMsg="$(re_tok $T_MESSAGE "Cannot assign requested address:?")"
reSource="$(re_tok $T_TRACE ":? ?file: \/usr\/lib\/python2\.7\/socket\.py line: 571")"
assertRegex "$line" "/${reError}${reType}${reErrno}${reMsg}${reSource}/"

# error: <class 'socket.error'>, [Errno 99] Cannot assign requested address in file:///usr/lib/python2.7/socket.py:571
line="$(logline "$logfile" 3 | LEX)"
reSource="$(re_tok $T_TRACE "(?:in )?file:\/\/\/usr\/lib\/python2\.7\/socket\.py:571")"
assertRegex "$line" "/${reMsg}${reSource}/"

# FileNotFoundError: [Errno 2] No such file or directory: 'test.txt'
line="$(logline "$logfile" 4 | LEX)"
assertRegex "$line" "/(?:$(re_tok $T_ERROR "FileNotFoundError:")$(re_tok $T_ERROR "\[Errno 2\]")|$(re_tok $T_ERROR "FileNotFoundError: \[Errno 2\]"))$(re_tok $T_MESSAGE)/"


# Traceback (most recent call last):
line="$(logline "$logfile" 5 | LEX)"
assertRegex "$line" "/$(re_tok $T_CONTLINE).*$(re_tok $T_INFO "Traceback.*")/"

#   File "/home/user/.local/lib/python3.7/site-packages/rest_framework/views.py", line 457, in handle_exception
line="$(logline "$logfile" 6 | LEX)"
assertRegex "$line" "/$(re_tok $T_CONTLINE)/"
assertRegex "$line" "/$(re_tok $T_TRACE "File \"/home/user/.local/lib/python3.7/site-packages/rest_framework/views.py\", line 457,?")/"
assertRegex "$line" "/$(re_tok $T_FNCALL "(?:in )?handle_exception")/"

#     self.raise_uncaught_exception(exc)
line="$(logline "$logfile" 6 2 | LEX | tail -n1)"
assertRegex "$line" "/$(re_tok $T_CONTLINE)/"


success
