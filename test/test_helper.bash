export TMP="$BATS_TMPDIR"/ruby-build-test
export RUBY_BUILD_CURL_OPTS=
export RUBY_BUILD_HTTP_CLIENT="curl"

if [ "$FIXTURE_ROOT" != "$BATS_TEST_DIRNAME/fixtures" ]; then
  export FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures"
  export INSTALL_ROOT="$TMP/install"
  PATH="/usr/bin:/bin:/usr/sbin:/sbin"
  if [ "FreeBSD" = "$(uname -s)" ]; then
    PATH="/usr/local/bin:$PATH"
  fi
  PATH="$BATS_TEST_DIRNAME/../bin:$PATH"
  PATH="$TMP/bin:$PATH"
  export PATH
fi

remove_commands_from_path() {
  local path cmd
  local NEWPATH=":$PATH:"
  while PATH="${NEWPATH#:}" command -v "$@" >/dev/null; do
    local paths=( $(PATH="${NEWPATH#:}" command -v "$@" | sed 's!/[^/]*$!!' | sort -u) )
    for path in "${paths[@]}"; do
      local tmp_path="$(mktemp -d "$TMP/path.XXXXX")"
      ln -fs "$path"/* "$tmp_path/"
      for cmd; do rm -f "$tmp_path/$cmd"; done
      NEWPATH="${NEWPATH/:$path:/:$tmp_path:}"
    done
  done
  echo "${NEWPATH#:}"
}

teardown() {
  rm -fr "${TMP:?}"
}

stub() {
  local program="$1"
  # shellcheck disable=SC2155
  local prefix="$(echo "$program" | tr a-z- A-Z_)"
  shift

  export "${prefix}_STUB_PLAN"="${TMP}/${program}-stub-plan"
  export "${prefix}_STUB_RUN"="${TMP}/${program}-stub-run"
  export "${prefix}_STUB_END"=

  mkdir -p "${TMP}/bin"
  ln -sf "${BATS_TEST_DIRNAME}/stubs/stub" "${TMP}/bin/${program}"

  touch "${TMP}/${program}-stub-plan"
  for arg in "$@"; do printf "%s\n" "$arg" >> "${TMP}/${program}-stub-plan"; done
}

stub_repeated() {
  local program="$1"
  # shellcheck disable=SC2155
  local prefix="$(echo "$program" | tr a-z- A-Z_)"
  export "${prefix}_STUB_NOINDEX"=1
  stub "$@"
}

unstub() {
  local program="$1"
  # shellcheck disable=SC2155
  local prefix="$(echo "$program" | tr a-z- A-Z_)"
  local path="${TMP}/bin/${program}"

  export "${prefix}_STUB_END"=1

  local stub_was_invoked=
  [ -e "${TMP}/${program}-stub-run" ] && stub_was_invoked=1

  local STATUS=0
  "$path" || STATUS="$?"

  local debug_var="${prefix}_STUB_DEBUG"
  if [ $STATUS -ne 0 ] && [ -z "${!debug_var}" ] && [ -n "$stub_was_invoked" ]; then
    echo "unstub $program: re-run test with ${debug_var}=3 to log \`$program' invocations" >&2
  fi

  rm -f "$path"
  rm -f "${TMP}/${program}-stub-plan" "${TMP}/${program}-stub-run"
  return "$STATUS"
}

run_inline_definition() {
  local definition="${TMP}/build-definition"
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

assert() {
  if ! "$@"; then
    flunk "failed: $@"
  fi
}

refute() {
  if "$@"; then
    flunk "expected to fail: $@"
  fi
}

flunk() {
  { if [ "$#" -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed "s:${TMP}:\${TMP}:g" >&2
  return 1
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    { echo "command failed with exit status $status"
      echo "output: $output"
    } | flunk
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_failure() {
  if [ "$status" -eq 0 ]; then
    flunk "expected failed exit status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_equal() {
  if [ "$1" != "$2" ]; then
    { echo "expected: $1"
      echo "actual:   $2"
    } | flunk
  fi
}

assert_output() {
  local expected
  if [ $# -eq 0 ]; then expected="$(cat -)"
  else expected="$1"
  fi
  assert_equal "$expected" "$output"
}

assert_output_contains() {
  local expected="$1"
  if [ -z "$expected" ]; then
    echo "assert_output_contains needs an argument" >&2
    return 1
  fi
  echo "$output" | $(type -p ggrep grep | head -1) -F "$expected" >/dev/null || {
    { echo "expected output to contain $expected"
      echo "actual: $output"
    } | flunk
  }
}
