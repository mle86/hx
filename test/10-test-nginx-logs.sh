#!/bin/sh
. $(dirname "$0")/init.sh


logfile="$HERE/samples/nginx.log"


# 2021/07/10 12:00:00 [error] 40#40: *44 recv() failed (104: Connection reset by peer) while reading response header from upstream, client: 127.0.35.1, server: test.tld, request: "GET /info HTTP/1.1", upstream: "fastcgi://127.0.0.1:9000", host: "my-sys"
errorLine="$(logline "$logfile" 1 | LEX)"
assertRegex "$errorLine" "/$(re_tok $T_MESSAGE "recv\(\) failed \(104: Connection reset by peer\)")/"
assertRegex "$errorLine" "/$(re_tok $T_INFO "while reading response .* host: \"my-sys\".*")/"


success
