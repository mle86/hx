#!/bin/sh
. $(dirname "$0")/init.sh

logfile="$HERE/samples/sym4.log"
re_backslash='(?:\\)'


# [2019-01-30 12:44:53] request: Matched route "app_xxxxxxxxxxx". {"route":"app_xxxxxxxxxxx","route_parameters":{"_route":"app_xxxxxxxxxxx","_controller":"App\\Controller\\XxxxxxxxxController::showXxxxxxxByIdentity","identity":"9999"},"request_uri":"http://hostname.tld/xxxxxxx/by-ident/9999","method":"GET"} []
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "\[2019-01-30 12:44:53\]")/"
assertRegex "$line" "/$(re_tok $T_APP "request:?")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE ":? ?Matched route \"app_xxxxxxxxxxx\"\.")/"
assertRegex "$line" "/$(re_tok $T_JSON "\{\"route\":\"app_xxxxxxxxxxx\",\"route_parameters\":\{\"_route\":\"app_xxxxxxxxxxx\",\"_controller\":\"App${re_backslash}{2}Controller${re_backslash}{2}XxxxxxxxxController::showXxxxxxxByIdentity\",\"identity\":\"9999\"\},\"request_uri\":\"http:\/\/hostname\.tld\/xxxxxxx\/by-ident\/9999\",\"method\":\"GET\"\}")/"
assertRegex "$line" "/$(re_tok $T_INFO "\[\]")/"

# [2019-01-30 16:45:14] app.ERROR: TemporaryErrorException: unknown error: cURL error 6: Could not resolve host: hostname.tld (see http://curl.haxx.se/libcurl/c/libcurl-errors.html)  [500] (MyApp\Services\Exceptions\TemporaryErrorException @ vendor/myapp/svc/src/Exceptions/WrapMethod:25) (trace: vendor/myapp/svc/src/AssetHandler:35, vendor/myapp/svc/src/AssetHandler:68, vendor/myapp/svc/src/AssetHandler:94, src/Controller/VendorsController:174, src/Controller/VendorsController:149, vendor/symfony/http-kernel/HttpKernel:150, vendor/symfony/http-kernel/HttpKernel:67, vendor/symfony/http-kernel/Kernel:198, public/index:37) {"exception":"[object] (MyApp\\Services\\Exceptions\\TemporaryErrorException(code: 0): unknown error: cURL error 6: Could not resolve host: hostname.tld (see http://curl.haxx.se/libcurl/c/libcurl-errors.html) at /var/www/xxxxxxxx/vendor/myapp/svc/src/Exceptions/WrapMethod.php:25, GuzzleHttp\\Exception\\ConnectException(code: 0): cURL error 6: Could not resolve host: hostname.tld (see http://curl.haxx.se/libcurl/c/libcurl-errors.html) at /var/www/xxxxxxxx/vendor/guzzlehttp/guzzle/src/Handler/CurlFactory.php:185)"} []
line="$(logline "$logfile" 2 | LEX)"
reHttp=
reHttp="${reHttp}(?:$(re_tok "$T_MESSAGE|$T_INFO" " ? ?\[?"))?"
reHttp="${reHttp}(?:$(re_tok $T_INFO "\["))?"
reHttp="${reHttp}$(re_tok $T_HTTP_STATUS "500")"
reHttp="${reHttp}$(re_tok $T_INFO "\]")"
assertRegex "$line" "/$(re_tok $T_APP "app\.?")/"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL "\.?ERROR:?")/"
assertRegex "$line" "/$(re_tok $T_ERROR ":? ?TemporaryErrorException:?")/"
assertRegex "$line" "/(?:$(re_tok $T_MESSAGE ":? ?"))?/"
assertRegex "$line" "/$(re_tok $T_MESSAGE ":? ?unknown error: cURL error 6: Could not resolve host: hostname\.tld \(see http:\/\/curl\.haxx\.se\/libcurl\/c\/libcurl-errors\.html\) ?")/"
assertRegex "$line" "/$reHttp/"
assertRegex "$line" "/$(re_tok $T_TRACE "\(MyApp${re_backslash}Services${re_backslash}Exceptions${re_backslash}TemporaryErrorException @ vendor\/myapp\/svc\/src\/Exceptions\/WrapMethod:25\)")/"
assertRegex "$line" "/$(re_tok $T_JSON "\{\"exception\":\"\[object\].*?:185\)\"\}")/"

# [2019-02-12 11:05:52] app.ERROR: ValidationException: foo bar  [context: YYYYY] [500] (MyApp\Exceptions\ValidationException @ vendor/myapp/src/Validator:33)
line="$(logline "$logfile" 4 | LEX)"
reExceptionName="$(re_tok $T_ERROR "ValidationException:?")"
reExceptionMsg1="$(re_tok $T_MESSAGE ":")"
reExceptionMsg2="$(re_tok $T_MESSAGE ":? ?foo bar\s*")"
reInfo="$(re_tok $T_INFO "\s*\[context: YYYYY\]")"
reHttp1="$(re_tok $T_INFO "\[")"
reHttp2="$(re_tok $T_HTTP_STATUS "500")"
reHttp3="$(re_tok $T_INFO "\]")"
reTrace="$(re_tok $T_TRACE "\(MyApp.+:33\)")"
assertRegex "$line" "/${reExceptionName}(?:${reExceptionMsg1})?${reExceptionMsg2}${reInfo}${reHttp1}${reHttp2}${reHttp3}${reTrace}/"

# [2020-03-17T17:02:57.978098+01:00] request.CRITICAL: Uncaught PHP Exception GuzzleHttp\Exception\ServerException: "Server error: `GET http://micro/ent/1020` resulted in a `500 Internal Server Error` response: <!DOCTYPE html> <html>     <head>         <meta charset="UTF-8" />         <meta name="robots" content="noindex,nofollow (truncated...) " at /var/www/project/vendor/guzzlehttp/guzzle/src/Exception/RequestException.php line 113 [] []
line="$(logline "$logfile" 5 | LEX)"
reDate="$(re_tok "$T_DATE" "\[2020-03-17T17:02:57\.978098\+01:00\]")"
reMsg="$(re_tok "$T_ERROR|$T_MESSAGE" "Uncaught PHP Exception")"
reExceptionName="$(re_tok $T_ERROR "GuzzleHttp${re_backslash}Exception${re_backslash}ServerException")"
reExceptionMsg="$(re_tok $T_MESSAGE "\"?Server error:.*")"
reJson="$(re_tok "$T_JSON|$T_INFO" "(?:\[\]\s*){1,2}"){1,2}"
assertRegex "$line" "/${reDate}.*${reMsg}.*${reExceptionName}.*${reExceptionMsg}.*${reJson}/"

# [2021-01-01 10:20:30] php.CRITICAL: Uncaught Error: Argument 1 passed to App\Entity\MyEntity::setProp() must be of the type int, null given, called in /proj/test.php on line 100 {"exception":"..."} []
line="$(logline "$logfile" 6 | LEX)"
reMsg="$(re_tok "$T_MESSAGE" "Argument 1 .* null given,?")"
reSoure="$(re_tok "$T_TRACE" ",? ?called in /proj/test.php on line 100")"
reJson="$(re_tok "$T_JSON|$T_INFO" "\{\"exception.*")"
assertRegex "$line" "/${reMsg}${reSource}.*${reJson}/"


logfile="$HERE/samples/sym5-console.log"

# ! [NOTE] Notice
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL " ! \[NOTE\]")$(re_tok $T_MESSAGE "Notice")/"

# // Comment
line="$(logline "$logfile" 6 | LEX)"
assertRegex "$line" "/$(re_tok $T_CONTLINE).*$(re_tok $T_INFO " // Comment")/"


success
