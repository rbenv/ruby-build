#!/bin/sh

set -e

if [ -z "${PREFIX}" ]; then
  PREFIX="/usr/local"
fi

BIN_PATH="${PREFIX}/bin"
SHARE_PATH="${PREFIX}/share/ruby-build"

if [ -d "${SHARE_PATH}" ]; then
    if [ -d "${BIN_PATH}" ]; then
        for file in bin/*; do
            rm "${BIN_PATH}/${file}"
        done
        for file in share/ruby-build/*; do
            rm "${SHARE_PATH}/${file}" 
        done
        echo "Uninstalled standalone ruby-build from ${BIN_PATH} and ${SHARE_PATH}."
    else
        echo "${BIN_PATH} does not exist, uninstall aborted."
    fi
else
    echo "${SHARE_PATH} does not exist, uninstall aborted.  ${SHARE_PATH} is automatically created when you run the ruby-build standalone install.sh script.  Are you sure you installed ruby-build standalone, and not as an rbenv plugin (rbenv/plugins/ruby-build)?"
fi

