#!/bin/sh
. $(dirname "$0")/init.sh

logfile1="$HERE/samples/bug-pkl-brk.log"
logfile2="$HERE/samples/apache2-php-packed.log"
re_backslash='(?:\\)'
re_brk="(?:${re_backslash}n)"  # \n


# ... #0 /proj/db.php(8): PDO->__construct()\n#1 /proj/save.php(9): ...
#   FNCALL(PDO->__construct()) INFO(\n) PKL INFO(#1) TRACE(/proj/save.php)
#   FNCALL(PDO->__construct()) PKL INFO(\n) INFO(#1) TRACE(/proj/save.php)
#   FNCALL(PDO->__construct()) PKL(\n) INFO(#1) TRACE(/proj/save.php)
line="$(logline "$logfile2" 1 | LEX)"
reBreak1="$(re_tok $T_PACKEDLINE)$(re_tok $T_INFO "$re_brk")$(re_tok $T_INFO "#1")"
reBreak2="$(re_tok $T_INFO "$re_brk")$(re_tok $T_PACKEDLINE)$(re_tok $T_INFO "#1")"
reBreak3="$(re_tok $T_PACKEDLINE "$re_brk")$(re_tok $T_INFO "#1")"
reBreak="(?:$reBreak1|$reBreak2|$reBreak3)"
reLine="$(re_tok "$T_FNCALL" "PDO->__construct\(\)")${reBreak}$(re_tok $T_TRACE "\\/proj\\/save.php.*")"
assertRegex "$line" "/$reLine/"

# [2021-09-30T12:00:00.000000+02:00] app.ERROR: ErrorException: fwrite(): send failed Broken pipe in /proj/io.php:10 Stack trace: #0 proj/io.php(10): IO->connect() #1 /proj/init.php(2): init() #2 {main}  Next IOException: Broken pipe in /proj/io.php:14 Stack trace: #0 /proj/conn.php(30): IO->write() #1 {main} {"exception":"[object] (IOException(code: 32): Broken pipe at io.php:14)\n[previous exception] [object] (ErrorException(code: 0): fwrite(): send failed Broken pipe at /proj/io.php:10)"} []
line="$(logline "$logfile1" 1 | LEX)"
assertRegex "$line" "/$(re_tok "$T_JSON" "\{\"exception.*${re_brk}.*\}")$(re_tok $T_INFO "\[\]")/"

# A second bug also relating to packed lines:
# [2022-11-27T18:56:00] Fatal Error: Class "Helper" not found in ErrorHandler.php:100 Stack trace: #0 in src/ErrorHandler.php:100\nStack trace:\n#0 src/ErrorHandler.php(200): ErrorHandler->handleException()\n#1 [internal function]: ErrorHandler->handleException()\n#2 {main}\n  thrown at /proj/src/ErrorHandler.php:100)"} []
line="$(logline "$logfile1" 2 | LEX)"
assertRegex "$line" "/$(re_tok $T_LINE).*$(re_tok $T_TRACE).*$(re_tok $T_PACKEDLINE).*$(re_tok $T_INFO "Stack trace:").*$(re_tok $T_PACKEDLINE).*$(re_tok $T_INFO "Stack trace:(${re_backslash}n)?").*$(re_tok $T_EOL).*/"


success
