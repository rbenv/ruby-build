#!/usr/bin/env bats

load test_helper

@test "not enough arguments for ruby-build" {
  mkdir -p "$TMP"
  # use empty inline definition so nothing gets built anyway
  touch "${TMP}/empty-definition"
  run ruby-build "${TMP}/empty-definition"
  assert_failure
  assert_output_contains 'Usage: ruby-build'
}

@test "extra arguments for ruby-build" {
  mkdir -p "$TMP"
  # use empty inline definition so nothing gets built anyway
  touch "${TMP}/empty-definition"
  run ruby-build "${TMP}/empty-definition" "${TMP}/install" ""
  assert_failure
  assert_output_contains 'Usage: ruby-build'
}
