#!/bin/sh

set -e

if [ -z "${PREFIX}" ]; then
  PREFIX="/usr/local"
fi

BIN_PATH="${PREFIX}/bin"
SHARE_PATH="${PREFIX}/share/ruby-build"
MAN_PATH="${PREFIX}/share/man/man1"

mkdir -p "${BIN_PATH}"
mkdir -p "${SHARE_PATH}"
mkdir -p "${MAN_PATH}"

for file in bin/*; do
  cp "${file}" "${BIN_PATH}"
done

for file in share/ruby-build/*; do
  cp "${file}" "${SHARE_PATH}"
done

for file in man/*.1; do
  command -v ronn >/dev/null && ronn --roff "${file}".ronn 2>/dev/null
  cp "${file}" "${MAN_PATH}"
done

echo "Installed ruby-build at ${PREFIX}"
