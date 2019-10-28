#!/bin/sh
. $(dirname "$0")/init.sh

# This class tests the nginx error format when handling php-fpm error output.
# There's special treatment for wrapped error messages
# so that only the important part appears in white while the rest should be grayed-out.
# Additionally, this scripts tests some PHP exception output specialties
# (the exception class name should be T_ERROR, not T_MESSAGE).

logfile="$HERE/samples/nginx-fastcgi.log"


# 2019/06/22 12:32:30 [error] 29744#29744: *30354220 FastCGI sent in stderr: "Primary script unknown" while reading response header from upstream, client: 172.0.0.1, server: www.hostname.tld, request: "GET /_sub/_page/_images/101010.html HTTP/1.0", upstream: "fastcgi://127.0.0.1:9000", host: "www.hostname.tld"
errorLine="$(logline "$logfile" 1 | LEX)"
assertRegex "$errorLine" "/$(re_tok $T_DATE "2019\/06\/22 12:32:30")/"
assertRegex "$errorLine" "/$(re_tok $T_LOGLEVEL "\[error\]")/"
assertRegex "$errorLine" "/$(re_tok $T_APP "29744#29744:?")/"
# We don't care if the "*30354220" will become part of the WRAP or a separate INFO block:
assertRegex "$errorLine" "/(?:$(re_tok $T_INFO "\*30354220")$(re_tok $T_WRAP "FastCGI sent in stderr: \"")|$(re_tok $T_WRAP "\*30354220 FastCGI sent in stderr: \""))/"
assertRegex "$errorLine" "/$(re_tok $T_MESSAGE "Primary script unknown")/"
assertRegex "$errorLine" "/$(re_tok $T_WRAPEND "\" while reading response header from upstream\b.*")/"
# We don't care if the part after the comma is part of the WRAPEND or a separate trailing INFO block:
assertRegex "$errorLine" "/$(re_tok "$T_WRAPEND|$T_INFO" "(?:\" while reading response header from upstream)?,? ?client: 172\.0\.0\.1, server: www\.hostname\.tld, request: \"GET \/_sub\/_page\/_images\/101010\.html HTTP\/1\.0\", upstream: \"fastcgi:\/\/127\.0\.0\.1:9000\", host: \"www\.hostname\.tld\"$(re_optbrk)")/"

# 2019/06/22 12:42:35 [error] 70#70: *5538 FastCGI sent in stderr: "PHP message: PHP Fatal error:  Class MyBaseLookupAction not found in /var/www/myapp/classes/actions/custom/lookup/MyCustomLookupAction.php on line 12" while reading response header from upstream, client: 172.19.0.1, server: my.app.tld, request: "GET /lookup?q=xyzxyzxyz HTTP/1.0", upstream: "fastcgi://127.0.0.1:9000", host: "my.app.tld", referrer: "http://my.app.tld/lookup/entity?id=120041"
phpErrorLine="$(logline "$logfile" 2 | LEX)"
rePhp1="$(re_tok $T_MESSAGE "PHP message: PHP Fatal error:  Uncaught")"
rePhp2="$(re_tok $T_ERROR "TestException:?")"
rePhp3="(?:$(re_tok $T_MESSAGE ":?"))?"
rePhp4="$(re_tok $T_MESSAGE ":? ?foobar")"
assertRegex "$phpErrorLine" "/$(re_tok $T_WRAP ".*sent in stderr: \"")/"
assertRegex "$phpErrorLine" "/${rePhp1}${rePhp2}${rePhp3}${rePhp4}/"
assertRegex "$phpErrorLine" "/$(re_tok $T_TRACE "in /var/www/myapp/classes/actions/custom/lookup/MyCustomLookupAction\.php on line 12")/"
assertRegex "$phpErrorLine" "/$(re_tok $T_WRAPEND "\" while reading.*")/"


success
