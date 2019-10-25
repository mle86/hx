#!/bin/sh
. $(dirname "$0")/init.sh


# Jun 16 10:27:20 test-pc rsyncd[31755]: sent 63 bytes  received 100688092 bytes  total size 100663296
line="$(syslogline 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "Jun 16 10:27:20")/"
assertRegex "$line" "/$(re_tok $T_HOSTNAME "test-pc")/"
assertRegex "$line" "/$(re_tok $T_APP "rsyncd\[31755\]:?")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "sent 63 bytes.*")/"

# Jun 16 10:27:20 test-pc kernel: [ 2961.795960] TCP: request_sock_TCP: Possible SYN flooding on port 4444. Sending cookies.  Check SNMP counters.
line="$(syslogline 2 | LEX)"
assertRegex "$line" "/$(re_tok $T_APP "kernel:?")/"
assertRegex "$line" "/$(re_tok $T_INFO "\[ 2961.795960\]")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "TCP: request_sock_TCP: Possible.*")/"

# Jul 17 18:52:43 hostname1 gnome-software[12960]: message repeated 5 times: [ Failed to load snap icon: local snap has no icon]
line="$(syslogline 5 | LEX)"
assertRegex "$line" "/$(re_tok $T_APP "gnome-software\[12960\]:?")/"
assertRegex "$line" "/$(re_tok $T_REPEAT "message repeated 5 times: \[")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "Failed to load snap icon.*")/"
assertRegex "$line" "/$(re_tok $T_REPEATEND "\]$(re_optbrk)")/"

# Aug  6 11:15:00 hostname1 org.gnome.Shell.desktop[19986]: [Parent 25206, Gecko_IOThread] WARNING: pipe error (47): Connection reset by peer: file /build/firefox-tGfEvD/firefox-68.0.1+build1/ipc/chromium/src/chrome/common/ipc_channel_posix.cc, line 358
line="$(syslogline 6 | LEX)"
assertRegex "$line" "/$(re_tok $T_APP "org.gnome.Shell.desktop\[19986\]:?")/"
assertRegex "$line" "/$(re_tok $T_INFO "\[Parent 25206, Gecko_IOThread\]")/"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL "WARNING:?")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "pipe error \(47\): Connection reset by peer.*")/"
assertRegex "$line" "/$(re_tok $T_TRACE ".*file .*ipc_channel_posix.cc, line 358")/"

# Aug  6 11:15:01 hostname1 org.gnome.Shell.desktop[19986]: ###!!! [Parent][RunMessage] Error: Channel closing: too late to send/recv, messages will be lost
line="$(syslogline 7 | LEX)"
assertRegex "$line" "/$(re_tok $T_INFO "###!!!.*")/"
assertRegex "$line" "/$(re_tok $T_INFO ".*\[Parent\]\[RunMessage\]")/"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL "Error:*")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE ".*Channel closing.*")/"

# Aug  6 11:15:01 hostname1 CRON[16964]: (root) CMD (   test -x /etc/cron.daily/popularity-contest && /etc/cron.daily/popularity-contest --crond)
line="$(syslogline 8 | LEX)"
assertRegex "$line" "/$(re_tok $T_APP "CRON\[16964\]:?")/"
assertRegex "$line" "/$(re_tok $T_USERNAME "(\()?root(\))?")/"
assertRegex "$line" "/$(re_tok $T_INFO "CMD \(\s*")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "\s*test .* --crond")/"
assertRegex "$line" "/$(re_tok $T_INFO "\)$(re_optbrk)")/"


success
