load helpers/assertions/all

BATS_TMPDIR="$BATS_TEST_DIRNAME/tmp"

if [ "$FIXTURE_ROOT" != "$BATS_TEST_DIRNAME/fixtures" ]; then
  export FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures"
  export INSTALL_ROOT="$BATS_TMPDIR/install"
  PATH=/usr/bin:/usr/sbin:/bin/:/sbin
  PATH="$BATS_TEST_DIRNAME/../bin:$PATH"
  PATH="$BATS_TMPDIR/bin:$PATH"
  export PATH
fi

teardown() {
  rm -fr "$BATS_TMPDIR"/*
}

stub() {
  local program="$1"
  local prefix="$(echo "$program" | tr a-z- A-Z_)"
  shift

  export "${prefix}_STUB_PLAN"="${BATS_TMPDIR}/${program}-stub-plan"
  export "${prefix}_STUB_RUN"="${BATS_TMPDIR}/${program}-stub-run"
  export "${prefix}_STUB_END"=

  mkdir -p "${BATS_TMPDIR}/bin"
  ln -sf "${BATS_TEST_DIRNAME}/stubs/stub" "${BATS_TMPDIR}/bin/${program}"

  touch "${BATS_TMPDIR}/${program}-stub-plan"
  for arg in "$@"; do printf "%s\n" "$arg" >> "${BATS_TMPDIR}/${program}-stub-plan"; done
}

unstub() {
  local program="$1"
  local prefix="$(echo "$program" | tr a-z- A-Z_)"
  local path="${BATS_TMPDIR}/bin/${program}"

  export "${prefix}_STUB_END"=1

  local STATUS=0
  "$path" || STATUS="$?"

  rm -f "$path"
  rm -f "${BATS_TMPDIR}/${program}-stub-plan" "${BATS_TMPDIR}/${program}-stub-run"
  return "$STATUS"
}

run_inline_definition() {
  local definition="${BATS_TMPDIR}/build-definition"
  cat > "$definition"
  run ruby-build "$definition" "${1:-$INSTALL_ROOT}"
}

install_fixture() {
  local args

  while [ "${1#-}" != "$1" ]; do
    args="$args $1"
    shift 1
  done

  local name="$1"
  local destination="$2"
  [ -n "$destination" ] || destination="$INSTALL_ROOT"

  run ruby-build $args "$FIXTURE_ROOT/$name" "$destination"
}
