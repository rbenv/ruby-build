#!/usr/bin/env bats

load test_helper
export RUBY_BUILD_SKIP_MIRROR=
export RUBY_BUILD_CACHE_PATH=
export RUBY_BUILD_MIRROR_URL=http://mirror.example.com


@test "package URL without checksum bypasses mirror" {
  stub shasum true
  stub curl "-q -fL -o * http://example.com/* : cp $FIXTURE_ROOT/\${5##*/} \$4"

  install_fixture definitions/without-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub shasum
}


@test "package URL with checksum but no shasum support bypasses mirror" {
  stub shasum false
  stub curl "-q -fL -o * http://example.com/* : cp $FIXTURE_ROOT/\${5##*/} \$4"

  install_fixture definitions/with-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub shasum
}


@test "package URL with checksum hits mirror first" {
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"
  local mirror_url="${RUBY_BUILD_MIRROR_URL}/$checksum"

  stub shasum true "echo $checksum"
  stub curl "-*I* $mirror_url : true" \
    "-q -fL -o * $mirror_url : cp $FIXTURE_ROOT/package-1.0.0.tar.gz \$4"

  install_fixture definitions/with-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub shasum
}


@test "package is fetched from original URL if mirror download fails" {
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"
  local mirror_url="${RUBY_BUILD_MIRROR_URL}/$checksum"

  stub shasum true "echo $checksum"
  stub curl "-*I* $mirror_url : false" \
    "-q -fL -o * http://example.com/* : cp $FIXTURE_ROOT/\${5##*/} \$4"

  install_fixture definitions/with-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub shasum
}


@test "package is fetched from original URL if mirror download checksum is invalid" {
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"
  local mirror_url="${RUBY_BUILD_MIRROR_URL}/$checksum"

  stub shasum true "echo invalid" "echo $checksum"
  stub curl "-*I* $mirror_url : true" \
    "-q -fL -o * $mirror_url : cp $FIXTURE_ROOT/package-1.0.0.tar.gz \$4" \
    "-q -fL -o * http://example.com/* : cp $FIXTURE_ROOT/\${5##*/} \$4"

  install_fixture definitions/with-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub shasum
}


@test "default mirror URL" {
  export RUBY_BUILD_MIRROR_URL=
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"

  stub shasum true "echo $checksum"
  stub curl "-*I* : true" \
    "-q -fL -o * https://?*/$checksum : cp $FIXTURE_ROOT/package-1.0.0.tar.gz \$4" \

  install_fixture definitions/with-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub shasum
}


@test "package URL with ruby-lang CDN with default mirror URL will bypasses mirror" {
  export RUBY_BUILD_MIRROR_URL=
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"

  stub shasum true "echo $checksum"
  stub curl "-q -fL -o * https://cache.ruby-lang.org/* : cp $FIXTURE_ROOT/\${5##*/} \$4"

  run_inline_definition <<DEF
install_package "package-1.0.0" "https://cache.ruby-lang.org/packages/package-1.0.0.tar.gz#ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5" copy
DEF

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub shasum
}


@test "package is fetched from complete mirror URL" {
  export RUBY_BUILD_MIRROR_URL=
  export RUBY_BUILD_MIRROR_PACKAGE_URL=http://mirror.example.com/package-1.0.0.tar.gz
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"

  stub shasum true "echo $checksum"
  stub curl "-*I* $RUBY_BUILD_MIRROR_PACKAGE_URL : true" \
    "-q -fL -o * $RUBY_BUILD_MIRROR_PACKAGE_URL : cp $FIXTURE_ROOT/package-1.0.0.tar.gz \$4"

  install_fixture definitions/with-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub shasum
}


@test "package is fetched from original URL if complete mirror URL download fails" {
  export RUBY_BUILD_MIRROR_URL=
  export RUBY_BUILD_MIRROR_PACKAGE_URL=http://mirror.example.com/package-1.0.0.tar.gz
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"

  stub shasum true "echo $checksum"
  stub curl "-*I* $RUBY_BUILD_MIRROR_PACKAGE_URL : false" \
    "-q -fL -o * http://example.com/* : cp $FIXTURE_ROOT/\${5##*/} \$4"

  install_fixture definitions/with-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub shasum
}


@test "package is fetched from original URL if complete mirror URL download checksum is invalid" {
  export RUBY_BUILD_MIRROR_URL=
  export RUBY_BUILD_MIRROR_PACKAGE_URL=http://mirror.example.com/package-1.0.0.tar.gz
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"

  stub shasum true "echo invalid" "echo $checksum"
  stub curl "-*I* $RUBY_BUILD_MIRROR_PACKAGE_URL : true" \
    "-q -fL -o * $RUBY_BUILD_MIRROR_PACKAGE_URL : cp $FIXTURE_ROOT/package-1.0.0.tar.gz \$4" \
    "-q -fL -o * http://example.com/* : cp $FIXTURE_ROOT/\${5##*/} \$4"

  install_fixture definitions/with-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub shasum
}
