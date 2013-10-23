#!/usr/bin/env bats

load test_helper
export RUBY_BUILD_SKIP_MIRROR=1
export RUBY_BUILD_CACHE_PATH="$TMP/cache"

setup() {
  mkdir "$RUBY_BUILD_CACHE_PATH"
}


@test "packages are saved to download cache" {
  stub md5 true
  stub curl "-C - -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${6##*/} \$4"

  install_fixture definitions/without-checksum
  [ "$status" -eq 0 ]
  [ -e "${RUBY_BUILD_CACHE_PATH}/package-1.0.0.tar.gz" ]

  unstub curl
  unstub md5
}


@test "cached package without checksum" {
  stub md5 true
  stub curl

  cp "${FIXTURE_ROOT}/package-1.0.0.tar.gz" "$RUBY_BUILD_CACHE_PATH"

  install_fixture definitions/without-checksum
  [ "$status" -eq 0 ]
  [ -e "${RUBY_BUILD_CACHE_PATH}/package-1.0.0.tar.gz" ]

  unstub curl
  unstub md5
}


@test "cached package with valid checksum" {
  stub md5 true "echo 83e6d7725e20166024a1eb74cde80677"
  stub curl

  cp "${FIXTURE_ROOT}/package-1.0.0.tar.gz" "$RUBY_BUILD_CACHE_PATH"

  install_fixture definitions/with-checksum
  [ "$status" -eq 0 ]
  [ -x "${INSTALL_ROOT}/bin/package" ]
  [ -e "${RUBY_BUILD_CACHE_PATH}/package-1.0.0.tar.gz" ]

  unstub curl
  unstub md5
}


@test "cached package with invalid checksum falls back to mirror and updates cache" {
  export RUBY_BUILD_SKIP_MIRROR=
  local checksum="83e6d7725e20166024a1eb74cde80677"

  stub md5 true "echo invalid" "echo $checksum"
  stub curl "-*I* : true" \
    "-C - -o * -*S* http://?*/$checksum : cp $FIXTURE_ROOT/package-1.0.0.tar.gz \$4"

  touch "${RUBY_BUILD_CACHE_PATH}/package-1.0.0.tar.gz"

  install_fixture definitions/with-checksum
  [ "$status" -eq 0 ]
  [ -x "${INSTALL_ROOT}/bin/package" ]
  [ -e "${RUBY_BUILD_CACHE_PATH}/package-1.0.0.tar.gz" ]
  diff -q "${RUBY_BUILD_CACHE_PATH}/package-1.0.0.tar.gz" "${FIXTURE_ROOT}/package-1.0.0.tar.gz"

  unstub curl
  unstub md5
}


@test "nonexistent cache directory is ignored" {
  stub md5 true
  stub curl "-C - -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${6##*/} \$4"

  export RUBY_BUILD_CACHE_PATH="${TMP}/nonexistent"

  install_fixture definitions/without-checksum
  [ "$status" -eq 0 ]
  [ -x "${INSTALL_ROOT}/bin/package" ]
  [ ! -d "$RUBY_BUILD_CACHE_PATH" ]

  unstub curl
  unstub md5
}
