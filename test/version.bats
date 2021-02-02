#!/usr/bin/env bats

load test_helper

bats_bin="${BATS_TEST_DIRNAME}/../bin/ruby-build"
static_version="$(grep VERSION "$bats_bin" | head -1 | cut -d'"' -f 2)"

@test "ruby-build static version" {
  stub git 'echo "ASPLODE" >&2; exit 1'
  run ruby-build --version
  assert_success "ruby-build ${static_version}"
  unstub git
}

@test "ruby-build git version" {
  stub git \
    'remote -v : echo origin https://github.com/rbenv/ruby-build.git' \
    "describe --tags HEAD : echo v1984-12-gSHA"
  run ruby-build --version
  assert_success "ruby-build 1984-12-gSHA"
  unstub git
}

@test "git describe fails" {
  stub git \
    'remote -v : echo origin https://github.com/rbenv/ruby-build.git' \
    "describe --tags HEAD : echo ASPLODE >&2; exit 1"
  run ruby-build --version
  assert_success "ruby-build ${static_version}"
  unstub git
}

@test "git remote doesn't match" {
  stub git \
    'remote -v : echo origin https://github.com/Homebrew/homebrew.git' \
    "describe --tags HEAD : echo v1984-12-gSHA"
  run ruby-build --version
  assert_success "ruby-build ${static_version}"
}
