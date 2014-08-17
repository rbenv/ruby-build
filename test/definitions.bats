#!/usr/bin/env bats

load test_helper
NUM_DEFINITIONS="$(ls "$BATS_TEST_DIRNAME"/../share/ruby-build | wc -l)"

@test "list built-in definitions" {
  run ruby-build --definitions
  assert_success
  assert_output_contains "1.9.3-p194"
  assert_output_contains "jruby-1.7.9"
  assert [ "${#lines[*]}" -eq "$NUM_DEFINITIONS" ]
}

@test "custom RUBY_BUILD_ROOT: nonexistent" {
  export RUBY_BUILD_ROOT="$TMP"
  assert [ ! -e "${RUBY_BUILD_ROOT}/share/ruby-build" ]
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

@test "installing nonexistent definition" {
  run ruby-build "nonexistent" "${TMP}/install"
  assert [ "$status" -eq 2 ]
  assert_output "ruby-build: definition not found: nonexistent"
}
