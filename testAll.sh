#!/bin/sh -f

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

cd "${SCRIPT_DIR}"/t || exit 1
prove -I.. -r .