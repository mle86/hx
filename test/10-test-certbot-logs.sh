#!/bin/sh
. $(dirname "$0")/init.sh

logfile="$HERE/samples/certbot.log"


# 2019-06-05 04:33:37,578:DEBUG:certbot.main:Discovered plugins: PluginsRegistry(PluginEntryPoint#apache,PluginEntryPoint#manual,PluginEntryPoint#null,PluginEntryPoint#standalone,PluginEntryPoint#webroot)
line="$(logline "$logfile" 1 | LEX)"
assertRegex "$line" "/$(re_tok $T_DATE "2019-06-05 04:33:37,578:?")/"
assertRegex "$line" "/$(re_tok $T_LOGLEVEL ":?DEBUG:?")/"
assertRegex "$line" "/$(re_tok $T_APP ":?certbot\.main:?")/"
assertRegex "$line" "/$(re_tok $T_MESSAGE "Discovered plugins: PluginsRegistry.*")/"


success
