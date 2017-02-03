set -e

if [ -z "${PREFIX}" ]; then
  PREFIX="/usr/local"
fi

BIN_PATH="${PREFIX}/bin"
SHARE_PATH="${PREFIX}/share/ruby-build"

cd bin
for file in *; do
  rm "${BIN_PATH}/${file}"
done

rm -r "${SHARE_PATH}"

cd -

echo "Uninstalled ruby-build at ${PREFIX}"
