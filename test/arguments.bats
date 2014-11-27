#!/usr/bin/env bats

load test_helper

@test "not enought arguments for ruby-build" {
  # use empty inline definition so nothing gets built anyway
  local definition="${TMP}/build-definition"
  echo '' > "$definition"

  run ruby-build "$definition"
  assert_failure
  assert_output_contains 'Usage: ruby-build'
}

@test "extra arguments for ruby-build" {
  # use empty inline definition so nothing gets built anyway
  local definition="${TMP}/build-definition"
  echo '' > "$definition"

  run ruby-build "$definition" "${TMP}/install" ""
  assert_failure
  assert_output_contains 'Usage: ruby-build'
}

@test "extra arguments for rbenv-install" {
  stub ruby-build "--lib : $BATS_TEST_DIRNAME/../bin/ruby-build --lib"
  stub rbenv-hooks
  stub rbenv-rehash

  run rbenv-install 2.1.1 2.1.2
  assert_failure
  assert_output_contains 'Usage: rbenv install'

  unstub ruby-build
  unstub rbenv-hooks
  unstub rbenv-rehash
}

@test "not enough arguments rbenv-uninstall" {
  run rbenv-uninstall
  assert_failure
  assert_output_contains 'Usage: rbenv uninstall'
}

@test "extra arguments for rbenv-uninstall" {
  stub rbenv-hooks

  run rbenv-uninstall 2.1.1 2.1.2
  assert_failure
  assert_output_contains 'Usage: rbenv uninstall'

  unstub rbenv-hooks
}
