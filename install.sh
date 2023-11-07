#!/bin/sh
# Usage: PREFIX=/usr/local ./install.sh
#
# Installs ruby-build under $PREFIX.

set -e

cd "$(dirname "$0")"

if [ -z "${PREFIX}" ]; then
  PREFIX="/usr/local"
fi

BIN_PATH="${PREFIX}/bin"
SHARE_PATH="${PREFIX}/share/ruby-build"
MAN_PATH="${PREFIX}/share/man/man1"

mkdir -p "$BIN_PATH" "$SHARE_PATH" "$MAN_PATH"

install -p bin/* "$BIN_PATH"
install -p -m 0644 share/ruby-build/* "$SHARE_PATH"
install -p -m 0644 share/man/man1/*.1 "$MAN_PATH"
