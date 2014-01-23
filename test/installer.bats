#!/usr/bin/env bats

load test_helper

@test "installs ruby-build into PREFIX" {
  cd "$TMP"
  PREFIX="${PWD}/usr" run "${BATS_TEST_DIRNAME}/../install.sh"
  assert_success ""

  cd usr

  assert [ -x bin/ruby-build ]
  assert [ -x bin/rbenv-install ]
  assert [ -x bin/rbenv-uninstall ]

  assert [ -e share/ruby-build/1.8.6-p383 ]
  assert [ -e share/ruby-build/ree-1.8.7-2012.02 ]
}

@test "build definitions don't have the executable bit" {
  cd "$TMP"
  PREFIX="${PWD}/usr" run "${BATS_TEST_DIRNAME}/../install.sh"
  assert_success ""

  run $BASH -c 'ls -l usr/share/ruby-build | tail -2 | cut -d" " -f1'
  assert_output <<OUT
-rw-r--r--
-rw-r--r--
OUT
}

@test "overwrites old installation" {
  cd "$TMP"
  mkdir -p bin share/ruby-build
  touch bin/ruby-build
  touch share/ruby-build/1.8.6-p383

  PREFIX="$PWD" run "${BATS_TEST_DIRNAME}/../install.sh"
  assert_success ""

  assert [ -x bin/ruby-build ]
  run grep "install_package" share/ruby-build/1.8.6-p383
  assert_success
}

@test "unrelated files are untouched" {
  cd "$TMP"
  mkdir -p bin share/bananas
  chmod g-w bin
  touch bin/bananas
  touch share/bananas/docs

  PREFIX="$PWD" run "${BATS_TEST_DIRNAME}/../install.sh"
  assert_success ""

  assert [ -e bin/bananas ]
  assert [ -e share/bananas/docs ]

  run ls -ld bin
  assert_equal "r-x" "${output:4:3}"
}
