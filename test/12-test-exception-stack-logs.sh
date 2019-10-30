#!/bin/sh
. $(dirname "$0")/init.sh


logfile="$HERE/samples/exception-stack.log"
re_backslash='(?:\\)'

# May  7 13:41:07 myhost myapp: ExceptionStack: could not validate 'known_prop': 'UNKNOWNVAL123'    (stack: ValidationException: could not validate 'known_prop': 'UNKNOWNVAL123') (ErrorPkg\ExceptionStack @ src/Validation/Validator:161) (trace: src/Controller/UpdateController:59, src/RequestDispatch:134, public/index:18)
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_ERROR "ExceptionStack:?")(?:$(re_tok $T_MESSAGE ":"))?$(re_tok $T_MESSAGE ":? ?could not validate.*")/"
assertRegex "$line" "/$(re_tok $T_STACK "\s*\(stack: ValidationException: could not validate 'known_prop': 'UNKNOWNVAL123'\)")/"
assertRegex "$line" "/$(re_tok $T_TRACE "\(ErrorPkg${re_backslash}ExceptionStack @ src\/Validation\/Validator:161\)")/"

# 2019-02-12 11:05:52 ExceptionStack: foo  bar    (stack: InvalidArgumentException: foo; LogicException; RuntimeException/223: bar) (ErrorPkg\ExceptionStack @ TEST:37) (trace: aa, bb, cc)
line="$(logline "$logfile" 2 | LEX)"
assertRegex "$line" "/$(re_tok $T_MESSAGE "foo  bar  *")/"
assertRegex "$line" "/$(re_tok $T_STACK "\s*\(stack: InvalidArgumentException: foo; LogicException; RuntimeException/223: bar\)")/"
# TODO: test special highlighting of the (stack:…) section


success
