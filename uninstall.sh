#!/bin/sh

set -e

if [ -z "${PREFIX}" ]; then
  PREFIX="/usr/local"
fi

BIN_PATH="${PREFIX}/bin"
SHARE_PATH="${PREFIX}/share/ruby-build"

if [ -d "${BIN_PATH}" ]; then
    for file in bin/*; do
        rm "${BIN_PATH}/${file}"
    done
else
    echo "${BIN_PATH} does not exist, are you sure you installed ruby-build standalone, and not as an rbenv plugin (rbenv/plugins/ruby-build)?"
fi

if [ -d "${SHARE_PATH}" ]; then
    for file in share/ruby-build/*; do
        rm "${SHARE_PATH}/${file}" 
    done
else
    echo "${SHARE_PATH} does not exist, are you sure you installed ruby-build standalone, and not as an rbenv plugin (rbenv/plugins/ruby-build)?"
fi

echo "Uninstalled ruby-build"
