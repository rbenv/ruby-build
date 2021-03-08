#!/usr/bin/env bats

load test_helper
NUM_DEFINITIONS="$(ls "$BATS_TEST_DIRNAME"/../share/ruby-build | wc -l)"

@test "list all local definitions" {
  run ruby-build --definitions
  assert_success
  assert_output_contains "1.9.3-p194"
  assert_output_contains "jruby-1.7.9"
  assert_output_contains "truffleruby-1.0.0-rc2"
  assert [ "${#lines[*]}" -eq "$NUM_DEFINITIONS" ]
}

@test "custom RUBY_BUILD_ROOT: nonexistent" {
  export RUBY_BUILD_ROOT="$TMP"
  refute [ -e "${RUBY_BUILD_ROOT}/share/ruby-build" ]
  run ruby-build --definitions
  assert_success ""
}

@test "custom RUBY_BUILD_ROOT: single definition" {
  export RUBY_BUILD_ROOT="$TMP"
  mkdir -p "${RUBY_BUILD_ROOT}/share/ruby-build"
  touch "${RUBY_BUILD_ROOT}/share/ruby-build/1.9.3-test"
  run ruby-build --definitions
  assert_success "1.9.3-test"
}

@test "one path via RUBY_BUILD_DEFINITIONS" {
  export RUBY_BUILD_DEFINITIONS="${TMP}/definitions"
  mkdir -p "$RUBY_BUILD_DEFINITIONS"
  touch "${RUBY_BUILD_DEFINITIONS}/1.9.3-test"
  run ruby-build --definitions
  assert_success
  assert_output_contains "1.9.3-test"
  assert [ "${#lines[*]}" -eq "$((NUM_DEFINITIONS + 1))" ]
}

@test "multiple paths via RUBY_BUILD_DEFINITIONS" {
  export RUBY_BUILD_DEFINITIONS="${TMP}/definitions:${TMP}/other"
  mkdir -p "${TMP}/definitions"
  touch "${TMP}/definitions/1.9.3-test"
  mkdir -p "${TMP}/other"
  touch "${TMP}/other/2.1.2-test"
  run ruby-build --definitions
  assert_success
  assert_output_contains "1.9.3-test"
  assert_output_contains "2.1.2-test"
  assert [ "${#lines[*]}" -eq "$((NUM_DEFINITIONS + 2))" ]
}

@test "installing definition from RUBY_BUILD_DEFINITIONS by priority" {
  export RUBY_BUILD_DEFINITIONS="${TMP}/definitions:${TMP}/other"
  mkdir -p "${TMP}/definitions"
  echo true > "${TMP}/definitions/1.9.3-test"
  mkdir -p "${TMP}/other"
  echo false > "${TMP}/other/1.9.3-test"
  run bin/ruby-build "1.9.3-test" "${TMP}/install"
  assert_success ""
}

@test "installing nonexistent definition" {
  run ruby-build "nonexistent" "${TMP}/install"
  assert [ "$status" -eq 2 ]
  assert_output "ruby-build: definition not found: nonexistent"
}

@test "sorting Ruby versions" {
  export RUBY_BUILD_ROOT="$TMP"
  mkdir -p "${RUBY_BUILD_ROOT}/share/ruby-build"
  expected="1.8.7
1.8.7-p72
1.8.7-p375
1.9.3-dev
1.9.3-preview1
1.9.3-rc1
1.9.3-p0
1.9.3-p125
2.1.0-dev
2.1.0-rc1
2.1.0
2.1.1
2.2.0-dev
jruby-1.6.5
jruby-1.6.5.1
jruby-1.7.0-preview1
jruby-1.7.0-rc1
jruby-1.7.0
jruby-1.7.1
jruby-1.7.9
jruby-1.7.10
jruby-9000-dev
jruby-9000
truffleruby-1.0.0-rc2
truffleruby-19.0.0
truffleruby-19.3.0
truffleruby+graalvm-20.0.0
truffleruby+graalvm-20.1.0"
  for ver in $expected; do
    touch "${RUBY_BUILD_ROOT}/share/ruby-build/$ver"
  done
  run ruby-build --definitions
  assert_success "$expected"
}

@test "filtering previous Ruby versions" {
  export RUBY_BUILD_ROOT="$TMP"
  mkdir -p "${RUBY_BUILD_ROOT}/share/ruby-build"

  all_versions="
2.4.0
2.4.1
2.4.2
2.4.3
2.4.4
2.4.5
2.4.6
2.4.7
2.4.8
2.4.9
2.5.0
2.5.1
2.5.2
2.5.3
2.5.4
2.5.5
2.5.6
2.5.7
2.6.0
2.6.1
2.6.2
2.6.3
2.6.4
2.6.5
2.7.0
jruby-1.5.6
jruby-9.2.7.0
jruby-9.2.8.0
jruby-9.2.9.0
maglev-1.0.0
mruby-1.4.1
mruby-2.0.0
mruby-2.0.1
mruby-2.1.0
rbx-3.104
rbx-3.105
rbx-3.106
rbx-3.107
truffleruby-19.2.0.1
truffleruby-19.3.0
truffleruby-19.3.0.2
truffleruby-19.3.1
truffleruby+graalvm-20.0.0
truffleruby+graalvm-20.1.0"

  expected="2.4.9
2.5.7
2.6.5
2.7.0
jruby-9.2.9.0
maglev-1.0.0
mruby-2.1.0
rbx-3.107
truffleruby-19.3.1
truffleruby+graalvm-20.1.0"

  for ver in $all_versions; do
    touch "${RUBY_BUILD_ROOT}/share/ruby-build/$ver"
  done
  run ruby-build --list
  assert_success "$expected"
}

@test "removing duplicate Ruby versions" {
  export RUBY_BUILD_ROOT="$TMP"
  export RUBY_BUILD_DEFINITIONS="${RUBY_BUILD_ROOT}/share/ruby-build"
  mkdir -p "$RUBY_BUILD_DEFINITIONS"
  touch "${RUBY_BUILD_DEFINITIONS}/1.9.3"
  touch "${RUBY_BUILD_DEFINITIONS}/2.2.0"

  run ruby-build --definitions
  assert_success
  assert_output <<OUT
1.9.3
2.2.0
OUT
}
