#!/bin/sh
. $(dirname "$0")/init.sh

logfile="$HERE/samples/other.log"


# 07-Jun-2019 11:36:20.106 INFORMATION [localhost-startStop-2] org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping.register Mapped "{[/reload],methods=[POST]}" onto public org.springframework.http.ResponseEntity com.project.testController.reloadConfi(com.project.data)
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "07-Jun-2019 11:36:20\.106")/"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL "INFORMATION")/"
assertRegex "$line" "/$(re_tok $T_APP "\[localhost-startStop-2\]")/"
assertRegex "$line" "/$(re_tok $T_INFO "org\.springframework\.web\.servlet\.mvc\.method\.annotation\.RequestMappingHandlerMapping\.register")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "Mapped .*")/"

# [2019.06.07 12:16:21] Opened '/home/user1/snap/telegram-desktop/753/.local/share/TelegramDesktop/tdata/working' for reading, the previous Telegram Desktop launch was not finished properly :( Crash log size: 0
line="$(logline "$logfile" 2 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "\[2019\.06\.07 12:16:21\]")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "Opened .*")/"

# 2019-05-31 11:42:02,115 - __init__.py[WARN]: Attempting setup of ephemeral network on ens3 with 169.254.0.1/16 brd 169.254.255.255
line="$(logline "$logfile" 3 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "2019-05-31 11:42:02,115(?: -)?")/"
assertRegex "$line" "/$(re_tok $T_APP "__init__\.py")/"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL "\[WARN\]:?")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "Attempting .*")/"

# error: <class 'socket.error'>, [Errno 99] Cannot assign requested address: file: /usr/lib/python2.7/socket.py line: 571
line="$(logline "$logfile" 4 | LEX)"
reError="$(re_tok $T_LOGLEVEL "error:?")"
reType="$(re_tok $T_APP ":? ?<class 'socket\.error'>,?")"
reErrno="$(re_tok $T_ERROR ",? ?\[Errno 99\]")"
reMsg="$(re_tok $T_MESSAGE "Cannot assign requested address:?")"
reSource="$(re_tok $T_TRACE ":? ?file: \/usr\/lib\/python2\.7\/socket\.py line: 571")"
assertRegex "$line" "/${reError}${reType}${reErrno}${reMsg}${reSource}/"

# error: <class 'socket.error'>, [Errno 99] Cannot assign requested address in file:///usr/lib/python2.7/socket.py:571
line="$(logline "$logfile" 5 | LEX)"
reSource="$(re_tok $T_TRACE "(?:in )?file:\/\/\/usr\/lib\/python2\.7\/socket\.py:571")"
assertRegex "$line" "/${reMsg}${reSource}/"


success
