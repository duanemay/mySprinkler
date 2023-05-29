#!/bin/sh -f

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

echo Change Dir: ${SCRIPT_DIR}/t

cd ${SCRIPT_DIR}/t
prove -I .. testDateLib.pl testWeatherLib.pl