#!/bin/sh

set -e

if [ -z "${PREFIX}" ]; then
  PREFIX="/usr/local"
fi

BIN_PATH="${PREFIX}/bin"
SHARE_PATH="${PREFIX}/share/ruby-build"
LIBEXEC_PATH="${PREFIX}/libexec"

mkdir -p "${BIN_PATH}"
mkdir -p "${SHARE_PATH}"
mkdir -p "${LIBEXEC_PATH}"

for file in bin/*; do
  cp "${file}" "${BIN_PATH}"
done

for file in share/ruby-build/*; do
  cp "${file}" "${SHARE_PATH}"
done

for file in libexec/*; do
  cp "${file}" "${LIBEXEC_PATH}"
done

echo "Installed ruby-build at ${PREFIX}"
