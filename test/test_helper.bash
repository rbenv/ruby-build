export PATH="$BATS_TEST_DIRNAME/../bin:$PATH"
export TMP="$BATS_TEST_DIRNAME/tmp"
export FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures"
export INSTALL_ROOT="$TMP/install"

teardown() {
  rm -fr "$TMP"/*
}

stub() {
  local program="$1"
  local prefix="$(echo "$program" | tr a-z A-Z)"
  shift

  export "${prefix}_STUB_PLAN"="${TMP}/${program}-stub-plan"
  export "${prefix}_STUB_RUN"="${TMP}/${program}-stub-run"
  export "${prefix}_STUB_DIR"="$FIXTURE_ROOT"
  export "${prefix}_STUB_END"=

  export PATH="${BATS_TEST_DIRNAME}/stubs/${program}:$PATH"

  rm -f "${TMP}/${program}-stub-plan" "${TMP}/${program}-stub-run"
  touch "${TMP}/${program}-stub-plan"
  for arg in "$@"; do printf "%s\n" "$arg" >> "${TMP}/${program}-stub-plan"; done
}

unstub() {
  local program="$1"
  local prefix="$(echo "$program" | tr a-z A-Z)"

  export "${prefix}_STUB_DIR"=
  export "${prefix}_STUB_END"=1

  local path="${BATS_TEST_DIRNAME}/stubs/$program"
  local escaped_path="${path//\//\\/}"
  export PATH="${PATH/${escaped_path}:}"

  "${path}/$program"
}

install_fixture() {
  local name="$1"
  local destination="$2"
  [ -n "$destination" ] || destination="$INSTALL_ROOT"

  run ruby-build "$FIXTURE_ROOT/$name" "$destination"
}
