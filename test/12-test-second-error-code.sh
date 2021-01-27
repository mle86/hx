#!/bin/sh
. $(dirname "$0")/init.sh


logfile="$HERE/samples/second-error-code.log"
re_backslash='(?:\\)'


# [2018-01-01 10:00:00] php.CRITICAL: Uncaught Exception: An exception occurred in driver: SQLSTATE[HY000] [2002] Connection refused {"json":["data"]} []
line="$(logline "$logfile" 1 | LEX)"
re=
re="${re}$(re_tok $T_ERROR "Exception:?")(?:$(re_tok $T_MESSAGE ":"))?"
re="${re}$(re_tok $T_MESSAGE ":? ?An exception occurred in driver.*")"
re="${re}$(re_tok $T_ERROR "SQLSTATE.*").*"
re="${re}$(re_tok $T_MESSAGE ".*Connection refused").*"
re="${re}$(re_tok $T_JSON "\{.*\}")"
assertRegex "$line" "/$re/"

# [2021-01-01 10:00:00] request.CRITICAL: Uncaught PHP Exception Doctrine\DBAL\Exception\InvalidFieldNameException: "An exception occurred while executing '(SQL)' with params ["H90"]:  SQLSTATE[42S22]: Column not found: 1054 Unknown column 't0.access' in 'field list'" at /proj/AbstractMySQLDriver.php line 60 {"json":["data"]} []
line="$(logline "$logfile" 3 | LEX)"
re=
re="${re}$(re_tok $T_ERROR "Doctrine${re_backslash}DBAL${re_backslash}Exception${re_backslash}InvalidFieldNameException:?")(?:$(re_tok $T_MESSAGE ":"))?"
re="${re}$(re_tok $T_MESSAGE ":? ?\"An exception occurred while executing '.*' with params \[.*\]: ?")"
re="${re}$(re_tok $T_ERROR "SQLSTATE(?:\[42S22\]:?)?").*"
re="${re}$(re_tok $T_MESSAGE ".*Column not found:.*")"
assertRegex "$line" "/$re/"


success
