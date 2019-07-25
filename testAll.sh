#!/bin/sh -f

SCRIPT_DIR=`dirname $0`
echo Change Dir: ${SCRIPT_DIR}/t

cd ${SCRIPT_DIR}/t
prove -I .. testDateLib.pl testWeatherLib.pl