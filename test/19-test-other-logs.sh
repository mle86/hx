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

# Apr  1 10:00:00 mysys org.gnome.Shell.desktop[4600]: #2 0x7ffd00007d22 I   resource:///org/gnome/gjs/modules/_legacy.js:82 (0x7ffd00007d30 @ 71)
line="$(logline "$logfile" 3 | LEX)"
reStack="$(re_tok $T_INFO "#2 0x7ffd00007d22 I +")"
reMsg="(?:$(re_tok $T_MESSAGE)|$(re_tok $T_MESSAGE " +"))"
reSource="$(re_tok $T_TRACE " *resource:\/\/\/org\/gnome\/gjs\/modules\/_legacy.js:82")"
reInfo="$(re_tok $T_INFO "\(0x7ffd00007d30 @ 71\)")"
assertRegex "$line" "/${reStack}${reMsg}${reSource}${reInfo}/"

# [Sun, Apr 26th, 13:49:59 2020] msg
line="$(logline "$logfile" 4 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "\[Sun, Apr 26th, 13:49:59 2020\]")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "msg")/"

# 2020-10-14 12:45:23 Platform HTTP 500: array_key_exists() expects parameter 2 to be array, null given [:, Import.php:300, Application.php:200, index.php:33]
line="$(logline "$logfile" 5 | LEX)"
assertRegex "$line" "/$(re_tok $T_APP "Platform( HTTP)?")/"
assertRegex "$line" "/$(re_tok $T_HTTP_STATUS "(HTTP )?500")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "array_key_exists\(\) expects parameter 2 to be array, null given")/"
assertRegex "$line" "/$(re_tok "$T_TRACE|$T_INFO" "\[.*33\](\\\\n)?")/"

# [myapp] (0.262733) init.c:105     | Start-up complete
line="$(logline "$logfile" 6 | LEX)"
assertRegex "$line" "/$(re_tok $T_APP "\[myapp\]")/"
assertRegex "$line" "/$(re_tok $T_DATE "\(?0\.262733\)?")/"
assertRegex "$line" "/$(re_tok "$T_TRACE|$T_INFO" "init\.c:105\s*")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "Start-up complete")/"

# 12:00:00 ERROR     [app] message
line="$(logline "$logfile" 7 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "12:00:00")\s*$(re_tok $T_LOGLEVEL "ERROR\s*")\s*$(re_tok $T_APP '\[app\]')\s*$(re_tok $T_MESSAGE)/"

# ERROR: app (pid 1000) Mon Jul 26 16:00:00 2021: message
line="$(logline "$logfile" 8 | LEX)"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL "ERROR:?")\s*$(re_tok $T_APP "app \(pid 1000\)")\s*$(re_tok $T_DATE 'Mon Jul 26 16:00:00 2021:?')\s*$(re_tok $T_MESSAGE)/"

# update-alternatives 2021-07-03 13:05:40: run with --install ...
line="$(logline "$logfile" 9 | LEX)"
assertRegex "$line" "/$(re_tok $T_APP "update-alternatives")\s*$(re_tok $T_DATE "2021-07-03 13:05:40:?")\s*$(re_tok $T_MESSAGE)/"

# /usr/bin/script.sh:50: Warning: Message
line="$(logline "$logfile" 10 | LEX)"
assertRegex "$line" "/$(re_tok "$T_TRACE|$T_APP" "\\/usr\\/bin\\/script.sh:50:")\s*$(re_tok $T_LOGLEVEL "Warning:")\s*$(re_tok $T_MESSAGE)/"

# 2021-07-26 15:00:00,000 INFO Starting unattended upgrades script
line="$(logline "$logfile" 11 | LEX)"
assertRegex "$line" "/$(re_tok "$T_DATA" "2021-07-26 15:00:00,000")\s*$(re_tok $T_LOGLEVEL "INFO")\s*$(re_tok $T_MESSAGE)/"

# E [01/Aug/2021:12:00:00 +0200] [cups-deviced] message
line="$(logline "$logfile" 12 | LEX)"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL "E")\s*$(re_tok $T_DATE "\[01/Aug/2021:12:00:00 \+0200\]")\s*$(re_tok "$T_MESSAGE|$T_INFO" "\[cups.*")/"

# Aug  1 12:00:00 hostname kernel: *ERROR* message
line="$(logline "$logfile" 13 | LEX)"
assertRegex "$line" "/$(re_tok $T_APP "kernel:")$(re_tok $T_LOGLEVEL "\*ERROR\*")$(re_tok $T_MESSAGE "message")/"

# 2021-08-12 11:00:00,000 UTC: message
line="$(logline "$logfile" 14 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "2021-08-12 11:00:00,000 UTC:")$(re_tok $T_LOGLEVEL "FATAL:")$(re_tok $T_MESSAGE)/"

# 1622215601080	app::helper	INFO	Listening on port 34830
line="$(logline "$logfile" 15 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "1622215601080\t")$(re_tok $T_APP "app::helper\t")$(re_tok $T_LOGLEVEL "INFO\t")$(re_tok $T_MESSAGE)/"

# console.warn: message
line="$(logline "$logfile" 16 | LEX)"
assertRegex "$line" "/$(re_tok $T_APP "console\.?")$(re_tok $T_LOGLEVEL "\.?warn:?").*$(re_tok $T_MESSAGE ".*message")/"

# (/usr/bin/program:1234): GLib-GObject-CRITICAL **: 12:00:00.123: g_object_set: assertion 'G_IS_OBJECT (object)' failed
line="$(logline "$logfile" 17 | LEX)"
assertRegex "$line" "/$(re_tok $T_APP "\(\/usr/bin/program:1234\):")$(re_tok $T_LOGLEVEL "GLib-GObject-CRITICAL \*\*:")$(re_tok $T_DATE "12:00:00.123:")$(re_tok $T_MESSAGE)/"


success
