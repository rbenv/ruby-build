#!/usr/bin/env bats

load test_helper
export MAKE=make
export MAKE_OPTS='-j 2'
export -n CFLAGS
export -n CC
export -n RUBY_CONFIGURE_OPTS

@test "CC=clang by default on OS X 10.10" {
  mkdir -p "$INSTALL_ROOT"
  cd "$INSTALL_ROOT"

  stub_repeated uname '-s : echo Darwin'
  stub sw_vers '-productVersion : echo 10.10'
  stub_repeated brew 'false'
  # shellcheck disable=SC2016
  stub_repeated make 'echo "make $(inspect_args "$@")" >> build.log'

  cat > ./configure <<CON
#!${BASH}
echo ./configure "\$@" > build.log
echo CC=\$CC >> build.log
echo CFLAGS=\${CFLAGS-no} >> build.log
CON
  chmod +x ./configure

  run_inline_definition <<DEF
build_package_standard ruby-2.5.0
DEF
  assert_success
  run cat build.log
  assert_output <<OUT
./configure --prefix=$INSTALL_ROOT --with-ext=openssl,psych,+
CC=clang
CFLAGS=no
make -j 2
make install
OUT

  unstub uname
  unstub sw_vers
  unstub brew
  unstub make
}
