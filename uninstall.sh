#!/bin/sh

set -e

if [ -z "${PREFIX}" ]; then
  PREFIX="/usr/local"
fi

BIN_PATH="${PREFIX}/bin"
SHARE_PATH="${PREFIX}/share/ruby-build"

if [ -d "${BIN_PATH}" ]
    for file in bin/*; do
        rm "${BIN_PATH}/${file}"
    done
fi

if [ -d "${SHARE_PATH}" ]
    for file in share/ruby-build/*; do
        rm "${SHARE_PATH}/${file}" 
    done
fi

echo "Uninstalled ruby-build"
