#!/bin/sh
. $(dirname "$0")/init.sh

# This test depends on test-symfony4-logs.

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


success
