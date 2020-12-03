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

# Apr  1 10:00:00 mysys org.gnome.Shell.desktop[4600]: #2 0x7ffd00007d22 I   resource:///org/gnome/gjs/modules/_legacy.js:82 (0x7ffd00007d30 @ 71)
line="$(logline "$logfile" 6 | LEX)"
reStack="$(re_tok $T_INFO "#2 0x7ffd00007d22 I +")"
reMsg="(?:$(re_tok $T_MESSAGE)|$(re_tok $T_MESSAGE " +"))"
reSource="$(re_tok $T_TRACE " *resource:\/\/\/org\/gnome\/gjs\/modules\/_legacy.js:82")"
reInfo="$(re_tok $T_INFO "\(0x7ffd00007d30 @ 71\)")"
assertRegex "$line" "/${reStack}${reMsg}${reSource}${reInfo}/"

# [Sun, Apr 26th, 13:49:59 2020] msg
line="$(logline "$logfile" 7 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "\[Sun, Apr 26th, 13:49:59 2020\]")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "msg")/"

# 2020-10-14 12:45:23 Platform HTTP 500: array_key_exists() expects parameter 2 to be array, null given [:, Import.php:300, Application.php:200, index.php:33]
line="$(logline "$logfile" 8 | LEX)"
assertRegex "$line" "/$(re_tok $T_APP "Platform( HTTP)?")/"
assertRegex "$line" "/$(re_tok $T_HTTP_STATUS "(HTTP )?500")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "array_key_exists\(\) expects parameter 2 to be array, null given")/"
assertRegex "$line" "/$(re_tok "$T_TRACE|$T_INFO" "\[.*33\](\\\\n)?")/"


success
