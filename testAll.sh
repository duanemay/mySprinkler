#!/bin/sh -f

SCRIPT_DIR=`dirname $0`
export PERL5LIB=${SCRIPT_DIR}
echo Change Dir: ${SCRIPT_DIR}/t

cd ${SCRIPT_DIR}/t
./testWeatherLib.pl;
./testDateLib.pl;