#!/bin/sh
. $(dirname "$0")/init.sh

# This test depends on test-symfony4-logs and test-apache-logs.

logfile="$HERE/samples/sym4-packed.log"
re_backslash='(?:\\)'

line="$(logline "$logfile" 1 | LEX)"
rePart1="$(re_tok $T_ERROR "SoapFault:?")"
 rePart1="${rePart1}$(re_tok $T_MESSAGE ":")?$(re_tok $T_MESSAGE ":? ?Could not connect to host")"
 rePart1="${rePart1}$(re_tok $T_TRACE "in \/var\/myproj\/Import.php:20")"
 rePart1="${rePart1}$(re_tok "$T_MESSAGE|$T_INFO")?"
rePart2="$(re_tok $T_PACKEDLINE)$(re_tok $T_INFO "Stack trace:")"
rePart3="$(re_tok $T_PACKEDLINE)"
 rePart3="${rePart3}$(re_tok $T_INFO "#0")"
 rePart3="${rePart3}$(re_tok $T_TRACE "\[internal function\]:? ?")"
 rePart3="${rePart3}$(re_tok $T_INFO ":")?"
 rePart3="${rePart3}$(re_tok $T_FNCALL "SoapClient->.*")"
 rePart3="${rePart3}.*"
rePart4="$(re_tok $T_PACKEDLINE)$(re_tok $T_INFO "#1").*"
rePart5="$(re_tok $T_PACKEDLINE)"
 rePart5="${rePart5}$(re_tok $T_DATE "Next")"
 rePart5="${rePart5}$(re_tok $T_ERROR "App${re_backslash}Exception${re_backslash}CustomSOAPException")"
 rePart5="${rePart5}$(re_tok $T_MESSAGE ":")?"
 rePart5="${rePart5}$(re_tok $T_MESSAGE ":? ?soap request failed: Could not connect to host")"
 rePart5="${rePart5}$(re_tok $T_TRACE "in \/var\/myproj\/Exception\/CustomSOAPException.php:20")"
 rePart5="${rePart5}.*"
rePart6="$(re_tok $T_PACKEDLINE)$(re_tok $T_INFO "Stack trace:")"
rePart7="$(re_tok $T_PACKEDLINE)$(re_tok $T_INFO "#0")"
assertRegex "$line" "/$rePart1$rePart2$rePart3$rePart4$rePart5$rePart6$rePart7/"


logfile="$HERE/samples/apache2-php-packed.log"
# [Fri Jul 30 14:00:00.100000 2020] [php7:notice] [pid 6001] [client 127.0.0.1:51000] PHP Fatal error:  Uncaught PDOException: SQLSTATE[HY000] [1045] Access denied for user 'test'@'localhost' (using password: YES) in /proj/db.php:8\nStack trace:\n#0 /proj/db.php(8): PDO->__construct()\n#1 /proj/save.php(9): require('/home/mle/web/v...')\n#2 {main}\n  thrown in /proj/db.php on line 8, referer: http://other.tld/foo
re=
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL "\[?php7:notice\]?")/"
assertRegex "$line" "/$(re_tok "$T_MESSAGE|$T_ERROR" "PHP Fatal error:.*")/"
assertRegex "$line" "/$(re_tok $T_ERROR "PDOException:?")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "SQLSTATE.*")/"
assertRegex "$line" "/$(re_tok $T_TRACE "in \/proj\/db.php:8")/"
re="${re}$(re_tok $T_PACKEDLINE).*$(re_tok $T_INFO "Stack trace.*").*"
re="${re}$(re_tok $T_PACKEDLINE).*$(re_tok $T_INFO "#0").*"
re="${re}$(re_tok $T_PACKEDLINE).*$(re_tok $T_INFO "#1").*$(re_tok $T_FNCALL "require.*").*"
assertRegex "$line" "/${re}/"


success
