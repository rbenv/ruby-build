#!/usr/bin/env bats

load test_helper

@test "not enough arguments for ruby-build" {
  # use empty inline definition so nothing gets built anyway
  local definition="${BATS_TMPDIR}/build-definition"
  echo '' > "$definition"

  run ruby-build "$definition"
  assert_failure
  assert_output_contains 'Usage: ruby-build'
}

@test "extra arguments for ruby-build" {
  # use empty inline definition so nothing gets built anyway
  local definition="${BATS_TMPDIR}/build-definition"
  echo '' > "$definition"

  run ruby-build "$definition" "${BATS_TMPDIR}/install" ""
  assert_failure
  assert_output_contains 'Usage: ruby-build'
}
