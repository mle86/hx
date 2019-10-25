#!/bin/sh
. $(dirname "$0")/init.sh

logfile="$HERE/samples/apache2.log"


# [Tue Mar 26 20:49:29.019045 2019] [:error] [pid 54] [client 172.30.0.1:60248] PHP Warning:  mysql_free_result() expects parameter 1 to be resource, null given in /srv/db.php on line 85
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "\[Tue Mar 26 20:49:29.019045 2019\]")/"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL "\[:error\]")/"
assertRegex "$line" "/$(re_tok $T_APP "\[pid 54\]")/"
assertRegex "$line" "/$(re_tok $T_INFO "\[client 172.30.0.1:60248\]")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE ".*mysql_free_result\(\) expects parameter 1 to be resource, null given")/"
assertRegex "$line" "/$(re_tok $T_TRACE "in /srv/db.php on line 85")/"

# [Fri May 31 15:34:11.711154 2019] [proxy:warn] [pid 2197:tid 140111931162368] [client 127.0.0.1:24124] AH01144: No protocol handler was valid for the URL /foo/bar/test.php (scheme 'http'). If you are using a DSO version of mod_proxy, make sure the proxy submodules are included in the configuration using LoadModule.
line="$(logline "$logfile" 2 | LEX)"
assertRegex "$line" "/$(re_tok $T_ERROR "AH01144:")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "No protocol handler.*")/"

# [Thu Jun 06 18:59:35.966014 2019] [authn_file:error] [pid 29838:tid 140111088789248] (13)Permission denied: [client 127.0.0.1:8092] AH01620: Could not open password file: /home/confluence/htpasswd
line="$(logline "$logfile" 3 | LEX)"
regex="$(re_tok $T_MESSAGE ".*Permission denied:.*")"
regex="$regex.*$(re_tok $T_ERROR "AH01620:")"
regex="$regex.*$(re_tok $T_MESSAGE "Could not open password file.*")"
assertRegex "$line" "/$regex/"  # normal message part before and after T_ERROR!

# www.hostname.tld:80 127.0.50.33 - - [28/Apr/2019:15:28:14 +0200] "GET / HTTP/1.1" 302 452 "-" "Monitoring Bot"
line="$(logline "$logfile" 7 | LEX)"
assertRegex "$line" "/$(re_tok $T_HOST "www.hostname.tld:80")/"
assertRegex "$line" "/$(re_tok $T_CLIENT "127.0.50.33")/"
assertRegex "$line" "/$(re_tok $T_DATE "\[28\/Apr\/2019:15:28:14 \+0200\]")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "\"?GET / HTTP/1.1\"?")/"
assertRegex "$line" "/$(re_tok $T_HTTP_STATUS "302")/"
assertRegex "$line" "/$(re_tok $T_INFO "452 \"-\" \"Monitoring Bot\"")/"

# bb.hostname.tld:80 127.0.0.1 identUser basicUser [01/Apr/2019:17:22:03 +0200] "GET /img/upload/wf1.png HTTP/1.1" 304 165 "http://bb.hostname.tld/profile.php?UID=1&edit=1" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0"
line="$(logline "$logfile" 8 | LEX)"
assertRegex "$line" "/$(re_tok $T_USERNAME "identUser")/"
assertRegex "$line" "/$(re_tok $T_USERNAME "basicUser")/"


success
