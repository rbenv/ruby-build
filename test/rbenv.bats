#!/usr/bin/env bats

load test_helper
export RBENV_ROOT="${TMP}/rbenv"

setup() {
  stub rbenv-hooks 'install : true'
  stub rbenv-rehash 'true'
}

stub_ruby_build() {
  stub ruby-build "--lib : $BATS_TEST_DIRNAME/../bin/ruby-build --lib" "$@"
}

@test "install proper" {
  stub_ruby_build 'echo ruby-build "$@"'

  run rbenv-install 2.1.2
  assert_success "ruby-build 2.1.2 ${RBENV_ROOT}/versions/2.1.2"

  unstub ruby-build
  unstub rbenv-hooks
  unstub rbenv-rehash
}

@test "install rbenv local version by default" {
  stub_ruby_build 'echo ruby-build "$1"'
  stub rbenv-local 'echo 2.1.2'

  run rbenv-install
  assert_success "ruby-build 2.1.2"

  unstub ruby-build
  unstub rbenv-local
}

@test "list available versions" {
  stub_ruby_build \
    "--definitions : echo 1.8.7 1.9.3-p0 1.9.3-p194 2.1.2 | tr ' ' $'\\n'"

  run rbenv-install --list
  assert_success
  assert_output <<OUT
Available versions:
  1.8.7
  1.9.3-p0
  1.9.3-p194
  2.1.2
OUT

  unstub ruby-build
}

@test "nonexistent version" {
  stub brew false
  stub_ruby_build 'echo ERROR >&2 && exit 2' \
    "--definitions : echo 1.8.7 1.9.3-p0 1.9.3-p194 2.1.2 | tr ' ' $'\\n'"

  run rbenv-install 1.9.3
  assert_failure
  assert_output <<OUT
ERROR

The following versions contain \`1.9.3' in the name:
  1.9.3-p0
  1.9.3-p194

See all available versions with \`rbenv install --list'.

If the version you need is missing, try upgrading ruby-build:

  cd ${BATS_TEST_DIRNAME}/.. && git pull && cd -
OUT

  unstub ruby-build
}

@test "Homebrew upgrade instructions" {
  stub brew "--prefix : echo '${BATS_TEST_DIRNAME%/*}'"
  stub_ruby_build 'echo ERROR >&2 && exit 2' \
    "--definitions : true"

  run rbenv-install 1.9.3
  assert_failure
  assert_output <<OUT
ERROR

See all available versions with \`rbenv install --list'.

If the version you need is missing, try upgrading ruby-build:

  brew update && brew upgrade ruby-build
OUT

  unstub brew
  unstub ruby-build
}

@test "no build definitions from plugins" {
  assert [ ! -e "${RBENV_ROOT}/plugins" ]
  stub_ruby_build 'echo $RUBY_BUILD_DEFINITIONS'

  run rbenv-install 2.1.2
  assert_success ""
}

@test "some build definitions from plugins" {
  mkdir -p "${RBENV_ROOT}/plugins/foo/share/ruby-build"
  mkdir -p "${RBENV_ROOT}/plugins/bar/share/ruby-build"
  stub_ruby_build "echo \$RUBY_BUILD_DEFINITIONS | tr ':' $'\\n'"

  run rbenv-install 2.1.2
  assert_success
  assert_output <<OUT

${RBENV_ROOT}/plugins/bar/share/ruby-build
${RBENV_ROOT}/plugins/foo/share/ruby-build
OUT
}

@test "list build definitions from plugins" {
  mkdir -p "${RBENV_ROOT}/plugins/foo/share/ruby-build"
  mkdir -p "${RBENV_ROOT}/plugins/bar/share/ruby-build"
  stub_ruby_build "--definitions : echo \$RUBY_BUILD_DEFINITIONS | tr ':' $'\\n'"

  run rbenv-install --list
  assert_success
  assert_output <<OUT
Available versions:
  
  ${RBENV_ROOT}/plugins/bar/share/ruby-build
  ${RBENV_ROOT}/plugins/foo/share/ruby-build
OUT
}

@test "completion results include build definitions from plugins" {
  mkdir -p "${RBENV_ROOT}/plugins/foo/share/ruby-build"
  mkdir -p "${RBENV_ROOT}/plugins/bar/share/ruby-build"
  stub ruby-build "--definitions : echo \$RUBY_BUILD_DEFINITIONS | tr ':' $'\\n'"

  run rbenv-install --complete
  assert_success
  assert_output <<OUT

${RBENV_ROOT}/plugins/bar/share/ruby-build
${RBENV_ROOT}/plugins/foo/share/ruby-build
OUT
}

@test "not enough arguments for rbenv-install" {
  stub_ruby_build
  run rbenv-install
  assert_failure
  assert_output_contains 'Usage: rbenv install'
}

@test "too many arguments for rbenv-install" {
  stub_ruby_build
  run rbenv-install 2.1.1 2.1.2
  assert_failure
  assert_output_contains 'Usage: rbenv install'
}

@test "show help for rbenv-install" {
  stub_ruby_build
  run rbenv-install -h
  assert_success
  assert_output_contains 'Usage: rbenv install'
}

@test "not enough arguments rbenv-uninstall" {
  run rbenv-uninstall
  assert_failure
  assert_output_contains 'Usage: rbenv uninstall'
}

@test "too many arguments for rbenv-uninstall" {
  run rbenv-uninstall 2.1.1 2.1.2
  assert_failure
  assert_output_contains 'Usage: rbenv uninstall'
}

@test "show help for rbenv-uninstall" {
  run rbenv-uninstall -h
  assert_success
  assert_output_contains 'Usage: rbenv uninstall'
}
