#!/usr/bin/env bats

load test_helper
export RUBY_BUILD_SKIP_MIRROR=1
export RUBY_BUILD_CACHE_PATH=

setup() {
  export RUBY_BUILD_BUILD_PATH="${TMP}/source"
  mkdir -p "${RUBY_BUILD_BUILD_PATH}"
}

@test "failed download displays error message" {
  stub curl false

  install_fixture definitions/without-checksum
  assert_failure
  assert_output_contains "> http://example.com/packages/package-1.0.0.tar.gz"
  assert_output_contains "error: failed to download package-1.0.0.tar.gz"
}

@test "no download tool" {
  export -n RUBY_BUILD_HTTP_CLIENT
  clean_path="$(remove_commands_from_path curl wget aria2c)"

  PATH="$clean_path" install_fixture definitions/without-checksum
  assert_failure
  assert_output_contains 'error: install `curl`, `wget`, or `aria2c` to download packages'
}

@test "using aria2c if available" {
  export RUBY_BUILD_ARIA2_OPTS=
  export -n RUBY_BUILD_HTTP_CLIENT
  stub aria2c "--allow-overwrite=true --no-conf=true -o * http://example.com/* : cp $FIXTURE_ROOT/\${5##*/} \$4"

  install_fixture definitions/without-checksum
  assert_success
  assert_output <<OUT
Downloading package-1.0.0.tar.gz...
-> http://example.com/packages/package-1.0.0.tar.gz
Installing package-1.0.0...
Installed package-1.0.0 to ${TMP}/install
OUT
  unstub aria2c
}

@test "fetching from git repository" {
  stub git "clone --depth 1 --branch master http://example.com/packages/package.git package-dev : mkdir package-dev"

  run_inline_definition <<DEF
install_git "package-dev" "http://example.com/packages/package.git" master copy
DEF
  assert_success
  assert_output <<OUT
Cloning http://example.com/packages/package.git...
Installing package-dev...
Installed package-dev to ${TMP}/install
OUT
  unstub git
}

@test "updating existing git repository" {
  mkdir -p "${RUBY_BUILD_BUILD_PATH}/package-dev"
  stub git \
    "fetch --depth 1 origin +master : true" \
    "checkout -q -B master origin/master : true"

  run_inline_definition <<DEF
install_git "package-dev" "http://example.com/packages/package.git" master copy
DEF
  assert_success
  assert_output <<OUT
Cloning http://example.com/packages/package.git...
Installing package-dev...
Installed package-dev to ${TMP}/install
OUT
  unstub git
}
