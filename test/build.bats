#!/usr/bin/env bats

load test_helper

tarball() {
  local name="$1"
  local path="$TMP/$name"
  local configure="$path/configure"

  mkdir -p "$path"
  cat > "$configure" <<OUT
#!$BASH
echo "$name: \$@" > build.log
OUT
  chmod +x "$configure"

  tar czf "${path}.tgz" -C "$TMP" "$name"
  echo "${path}.tgz"
}

stub_download() {
  stub curl "-C - -o * -*S* $1 : cp '$(tarball "$2")' \$4"
}

@test "yaml is installed for ruby" {
  mkdir -p "$INSTALL_ROOT/bin"

  stub md5 false
  stub brew false
  stub_download "http://pyyaml.org/*" "yaml-0.1.4"
  stub_download "http://ruby-lang.org/*" "ruby-2.0.0"
  stub make \
    ' : echo make "$@" >> build.log' \
    "install : cp build.log '$INSTALL_ROOT/yaml.log'" \
    ' : echo make "$@" >> build.log' \
    "install : cp build.log '$INSTALL_ROOT/ruby.log'"

  install_fixture definitions/needs-yaml
  assert_success

  unstub curl
  unstub make

  run cat "$INSTALL_ROOT/yaml.log"
  assert_output <<OUT
yaml-0.1.4: --prefix=$INSTALL_ROOT
make -j 2
OUT

  run cat "$INSTALL_ROOT/ruby.log"
  assert_output <<OUT
ruby-2.0.0: --prefix=$INSTALL_ROOT
make -j 2
OUT
}

@test "yaml is linked from Homebrew" {
  brew_libdir="$TMP/homebrew-yaml"
  mkdir -p "$INSTALL_ROOT/bin"
  mkdir -p "$brew_libdir"

  stub md5 false
  stub brew "--prefix libyaml : echo '$brew_libdir'"
  stub_download "http://ruby-lang.org/*" "ruby-2.0.0"
  stub make \
    ' : echo make "$@" >> build.log' \
    "install : cp build.log '$INSTALL_ROOT/ruby.log'"

  install_fixture definitions/needs-yaml
  assert_success

  unstub brew
  unstub curl
  unstub make

  run cat "$INSTALL_ROOT/ruby.log"
  assert_output <<OUT
ruby-2.0.0: --prefix=$INSTALL_ROOT --with-libyaml-dir=$brew_libdir
make -j 2
OUT
}
