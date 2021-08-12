#!/bin/sh
. $(dirname "$0")/init.sh

# Tests proftpd-specific message parsing.
# (Similar to syslog.)


logfile="$HERE/samples/proftpd.log"

# 2020-07-10 12:00:00,001 mysys proftpd[20000] mysys: ProFTPD 1.3.5e standalone mode SHUTDOWN
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "2020-07-10 12:00:00,001")/"
assertRegex "$line" "/$(re_tok $T_HOST "mysys")/"
assertRegex "$line" "/(?:$(re_tok $T_APP "proftpd\[20000\] mysys:?")|$(re_tok $T_APP "proftpd\[20000\]")$(re_tok "$T_APP|$T_HOST" "mysys:?"))/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "ProFTPD.*")/"

# 2021-08-12 06:00:00,000 mysys proftpd[35000] mysys.hostname.fqdn: message
line="$(logline "$logfile" 2 | LEX)"
assertRegex "$line" "/(?:$(re_tok $T_APP "proftpd\[35000\] mysys\.hostname\.fqdn:?")|$(re_tok $T_APP "proftpd\[35000\]")$(re_tok "$T_APP|$T_HOST" "mysys\.hostname\.fqdn:?"))/"

# 2021-08-12 11:00:00,000 mysys proftpd[46000] mysys.hostname.fqdn (127.0.0.1[127.0.0.1]): FTP session closed.
line="$(logline "$logfile" 3 | LEX)"
assertRegex "$line" "/(?:$(re_tok $T_APP "proftpd\[46000\] mysys\.hostname\.fqdn \(127\.0\.0\.1\[127\.0\.0\.1\]\):?")|$(re_tok $T_APP "proftpd\[46000\]")$(re_tok "$T_APP|$T_HOST" "mysys\.hostname\.fqdn \(127\.0\.0\.1\[127\.0\.0\.1\]\):?"))/"


xferlogfile="$HERE/samples/proftpd-xferlog.log"
# Sun Aug 01 12:00:00 2021 0 client.addr 3910000 /home/user/storage/image.jpg b _ o r username ftp 0 * c
line="$(logline "$xferlogfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_CLIENT "client.addr")$(re_tok $T_MESSAGE "3910000")$(re_tok $T_FILENAME "/home/user/storage/image.jpg").*$(re_tok $T_MESSAGE "o").*$(re_tok $T_USERNAME "username")/"


success
