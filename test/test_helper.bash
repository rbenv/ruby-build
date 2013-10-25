export TMP="$BATS_TEST_DIRNAME/tmp"

if [ "$FIXTURE_ROOT" != "$BATS_TEST_DIRNAME/fixtures" ]; then
  export FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures"
  export INSTALL_ROOT="$TMP/install"
  export PATH="$BATS_TEST_DIRNAME/../bin:$PATH"
  export PATH="$TMP/bin:$PATH"
fi

teardown() {
  rm -fr "$TMP"/*
}

stub() {
  local program="$1"
  local prefix="$(echo "$program" | tr a-z A-Z)"
  shift

  export "${prefix}_STUB_PLAN"="${TMP}/${program}-stub-plan"
  export "${prefix}_STUB_RUN"="${TMP}/${program}-stub-run"
  export "${prefix}_STUB_END"=

  mkdir -p "${TMP}/bin"
  ln -shf "${BATS_TEST_DIRNAME}/stubs/stub" "${TMP}/bin/${program}"

  rm -f "${TMP}/${program}-stub-plan" "${TMP}/${program}-stub-run"
  touch "${TMP}/${program}-stub-plan"
  for arg in "$@"; do printf "%s\n" "$arg" >> "${TMP}/${program}-stub-plan"; done
}

unstub() {
  local program="$1"
  local prefix="$(echo "$program" | tr a-z A-Z)"
  local path="${TMP}/bin/${program}"

  export "${prefix}_STUB_END"=1

  "$path"
  rm -f "$path"
}

install_fixture() {
  local name="$1"
  local destination="$2"
  [ -n "$destination" ] || destination="$INSTALL_ROOT"

  run ruby-build "$FIXTURE_ROOT/$name" "$destination"
}
