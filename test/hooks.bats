#!/usr/bin/env bats

load test_helper

setup() {
  export RBENV_ROOT="${TMP}/rbenv"
  export HOOK_PATH="${TMP}/i has hooks"
  mkdir -p "$HOOK_PATH"
}

@test "rbenv-install hooks" {
  cat > "${HOOK_PATH}/install.bash" <<OUT
before_install 'echo before: \$PREFIX'
after_install 'echo after: \$STATUS'
OUT
  stub rbenv-hooks "install : echo '$HOOK_PATH'/install.bash"
  stub rbenv-rehash "echo rehashed"

  definition="${TMP}/2.0.0"
  cat > "$definition" <<<"echo ruby-build"
  run rbenv-install "$definition"

  assert_success
  assert_output <<-OUT
before: ${RBENV_ROOT}/versions/2.0.0
ruby-build
after: 0
rehashed
OUT
}

@test "rbenv-uninstall hooks" {
  cat > "${HOOK_PATH}/uninstall.bash" <<OUT
before_uninstall 'echo before: \$PREFIX'
after_uninstall 'echo after.'
rm() {
  echo "rm \$@"
  command rm "\$@"
}
OUT
  stub rbenv-hooks "uninstall : echo '$HOOK_PATH'/uninstall.bash"
  stub rbenv-rehash "echo rehashed"

  mkdir -p "${RBENV_ROOT}/versions/2.0.0"
  run rbenv-uninstall -f 2.0.0

  assert_success
  assert_output <<-OUT
before: ${RBENV_ROOT}/versions/2.0.0
rm -rf ${RBENV_ROOT}/versions/2.0.0
rehashed
after.
OUT

  refute [ -d "${RBENV_ROOT}/versions/2.0.0" ]
}
