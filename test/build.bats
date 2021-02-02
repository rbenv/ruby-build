#!/usr/bin/env bats

load test_helper
export RUBY_BUILD_CACHE_PATH="$TMP/cache"
export MAKE=make
export MAKE_OPTS="-j 2"
export CC=cc
export -n RUBY_CONFIGURE_OPTS

setup() {
  mkdir -p "$INSTALL_ROOT"
  stub md5 false
  stub curl false
}

executable() {
  local file="$1"
  mkdir -p "${file%/*}"
  cat > "$file"
  chmod +x "$file"
}

cached_tarball() {
  mkdir -p "$RUBY_BUILD_CACHE_PATH"
  pushd "$RUBY_BUILD_CACHE_PATH" >/dev/null
  tarball "$@"
  popd >/dev/null
}

tarball() {
  local name="$1"
  local path="$PWD/$name"
  local configure="$path/configure"
  shift 1

  executable "$configure" <<OUT
#!$BASH
echo "$name: \$@" \${RUBYOPT:+RUBYOPT=\$RUBYOPT} >> build.log
OUT

  for file; do
    mkdir -p "$(dirname "${path}/${file}")"
    touch "${path}/${file}"
  done

  tar czf "${path}.tar.gz" -C "${path%/*}" "$name"
}

stub_make_install() {
  stub "$MAKE" \
    " : echo \"$MAKE \$@\" >> build.log" \
    "install : echo \"$MAKE \$@\" >> build.log && cat build.log >> '$INSTALL_ROOT/build.log'"
}

assert_build_log() {
  run cat "$INSTALL_ROOT/build.log"
  assert_output
}

@test "yaml is installed for ruby" {
  cached_tarball "yaml-0.1.6"
  cached_tarball "ruby-2.0.0"

  stub uname '-s : echo Linux'
  stub brew false
  stub_make_install
  stub_make_install

  install_fixture definitions/needs-yaml
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
yaml-0.1.6: --prefix=$INSTALL_ROOT
make -j 2
make install
ruby-2.0.0: --prefix=$INSTALL_ROOT
make -j 2
make install
OUT
}

@test "apply ruby patch before building" {
  cached_tarball "yaml-0.1.6"
  cached_tarball "ruby-2.0.0"

  stub uname '-s : echo Linux'
  stub brew false
  stub_make_install
  stub_make_install
  stub patch ' : echo patch "$@" | sed -E "s/\.[[:alnum:]]+$/.XXX/" >> build.log'

  TMPDIR="$TMP" install_fixture --patch definitions/needs-yaml <<PATCH
diff -pU3 align.c align.c
--- align.c 2017-09-14 21:09:29.000000000 +0900
+++ align.c 2017-09-15 05:56:46.000000000 +0900
PATCH
  assert_success

  unstub uname
  unstub make
  unstub patch

  assert_build_log <<OUT
yaml-0.1.6: --prefix=$INSTALL_ROOT
make -j 2
make install
patch -p0 --force -i $TMP/ruby-patch.XXX
ruby-2.0.0: --prefix=$INSTALL_ROOT
make -j 2
make install
OUT
}

@test "striplevel ruby patch before building" {
  cached_tarball "yaml-0.1.6"
  cached_tarball "ruby-2.0.0"

  stub uname '-s : echo Linux'
  stub brew false
  stub_make_install
  stub_make_install
  stub patch ' : echo patch "$@" | sed -E "s/\.[[:alnum:]]+$/.XXX/" >> build.log'

  TMPDIR="$TMP" install_fixture --patch definitions/needs-yaml <<PATCH
diff -pU3 a/configure b/configure
--- a/configure 2017-09-14 21:09:29.000000000 +0900
+++ b/configure 2017-09-15 05:56:46.000000000 +0900
PATCH
  assert_success

  unstub uname
  unstub make
  unstub patch

  assert_build_log <<OUT
yaml-0.1.6: --prefix=$INSTALL_ROOT
make -j 2
make install
patch -p1 --force -i $TMP/ruby-patch.XXX
ruby-2.0.0: --prefix=$INSTALL_ROOT
make -j 2
make install
OUT
}

@test "apply ruby patch from git diff before building" {
  cached_tarball "yaml-0.1.6"
  cached_tarball "ruby-2.0.0"

  stub uname '-s : echo Linux'
  stub brew false
  stub_make_install
  stub_make_install
  stub patch ' : echo patch "$@" | sed -E "s/\.[[:alnum:]]+$/.XXX/" >> build.log'

  TMPDIR="$TMP" install_fixture --patch definitions/needs-yaml <<PATCH
diff --git a/test/build.bats b/test/build.bats
index 4760c31..66a237a 100755
--- a/test/build.bats
+++ b/test/build.bats
PATCH
  assert_success

  unstub uname
  unstub make
  unstub patch

  assert_build_log <<OUT
yaml-0.1.6: --prefix=$INSTALL_ROOT
make -j 2
make install
patch -p1 --force -i $TMP/ruby-patch.XXX
ruby-2.0.0: --prefix=$INSTALL_ROOT
make -j 2
make install
OUT
}

@test "yaml is linked from Homebrew" {
  cached_tarball "ruby-2.0.0"

  brew_libdir="$TMP/homebrew-yaml"
  mkdir -p "$brew_libdir"

  stub uname '-s : echo Linux'
  stub brew "--prefix libyaml : echo '$brew_libdir'" false
  stub_make_install

  install_fixture definitions/needs-yaml
  assert_success

  unstub uname
  unstub brew
  unstub make

  assert_build_log <<OUT
ruby-2.0.0: --prefix=$INSTALL_ROOT --with-libyaml-dir=$brew_libdir
make -j 2
make install
OUT
}

@test "readline is linked from Homebrew" {
  cached_tarball "ruby-2.0.0"

  readline_libdir="$TMP/homebrew-readline"
  mkdir -p "$readline_libdir"

  stub brew "--prefix readline : echo '$readline_libdir'"
  stub_make_install

  run_inline_definition <<DEF
install_package "ruby-2.0.0" "http://ruby-lang.org/ruby/2.0/ruby-2.0.0.tar.gz"
DEF
  assert_success

  unstub brew
  unstub make

  assert_build_log <<OUT
ruby-2.0.0: --prefix=$INSTALL_ROOT --with-readline-dir=$readline_libdir
make -j 2
make install
OUT
}

@test "readline is not linked from Homebrew when explicitly defined" {
  cached_tarball "ruby-2.0.0"

  stub brew
  stub_make_install

  export RUBY_CONFIGURE_OPTS='--with-readline-dir=/custom'
  run_inline_definition <<DEF
install_package "ruby-2.0.0" "http://ruby-lang.org/ruby/2.0/ruby-2.0.0.tar.gz"
DEF
  assert_success

  unstub brew
  unstub make

  assert_build_log <<OUT
ruby-2.0.0: --prefix=$INSTALL_ROOT --with-readline-dir=/custom
make -j 2
make install
OUT
}

@test "number of CPU cores defaults to 2" {
  cached_tarball "ruby-2.0.0"

  stub uname '-s : echo Darwin' false
  stub sysctl false
  stub_make_install

  export -n MAKE_OPTS
  run_inline_definition <<DEF
install_package "ruby-2.0.0" "http://ruby-lang.org/ruby/2.0/ruby-2.0.0.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
ruby-2.0.0: --prefix=$INSTALL_ROOT
make -j 2
make install
OUT
}

@test "number of CPU cores is detected on Mac" {
  cached_tarball "ruby-2.0.0"

  stub uname '-s : echo Darwin' false
  stub sysctl '-n hw.ncpu : echo 4'
  stub_make_install

  export -n MAKE_OPTS
  run_inline_definition <<DEF
install_package "ruby-2.0.0" "http://ruby-lang.org/ruby/2.0/ruby-2.0.0.tar.gz"
DEF
  assert_success

  unstub uname
  unstub sysctl
  unstub make

  assert_build_log <<OUT
ruby-2.0.0: --prefix=$INSTALL_ROOT
make -j 4
make install
OUT
}

@test "number of CPU cores is detected on FreeBSD" {
  cached_tarball "ruby-2.0.0"

  stub uname '-s : echo FreeBSD' false
  stub sysctl '-n hw.ncpu : echo 1'
  stub_make_install

  export -n MAKE_OPTS
  run_inline_definition <<DEF
install_package "ruby-2.0.0" "http://ruby-lang.org/ruby/2.0/ruby-2.0.0.tar.gz"
DEF
  assert_success

  unstub uname
  unstub sysctl
  unstub make

  assert_build_log <<OUT
ruby-2.0.0: --prefix=$INSTALL_ROOT
make -j 1
make install
OUT
}

@test "setting RUBY_MAKE_INSTALL_OPTS to a multi-word string" {
  cached_tarball "ruby-2.0.0"

  stub uname '-s : echo Linux'
  stub_make_install

  export RUBY_MAKE_INSTALL_OPTS="DOGE=\"such wow\""
  run_inline_definition <<DEF
install_package "ruby-2.0.0" "http://ruby-lang.org/ruby/2.0/ruby-2.0.0.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
ruby-2.0.0: --prefix=$INSTALL_ROOT
make -j 2
make install DOGE="such wow"
OUT
}

@test "setting MAKE_INSTALL_OPTS to a multi-word string" {
  cached_tarball "ruby-2.0.0"

  stub uname '-s : echo Linux'
  stub_make_install

  export MAKE_INSTALL_OPTS="DOGE=\"such wow\""
  run_inline_definition <<DEF
install_package "ruby-2.0.0" "http://ruby-lang.org/ruby/2.0/ruby-2.0.0.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
ruby-2.0.0: --prefix=$INSTALL_ROOT
make -j 2
make install DOGE="such wow"
OUT
}

@test "custom relative install destination" {
  export RUBY_BUILD_CACHE_PATH="$FIXTURE_ROOT"

  cd "$TMP"
  install_fixture definitions/without-checksum ./here
  assert_success
  assert [ -x ./here/bin/package ]
}

@test "make on FreeBSD defaults to gmake" {
  cached_tarball "ruby-2.0.0"

  stub uname "-s : echo FreeBSD" false
  MAKE=gmake stub_make_install

  MAKE= install_fixture definitions/vanilla-ruby
  assert_success

  unstub gmake
  unstub uname
}

@test "can use RUBY_CONFIGURE to apply a patch" {
  cached_tarball "ruby-2.0.0"

  executable "${TMP}/custom-configure" <<CONF
#!$BASH
apply -p1 -i /my/patch.diff
exec ./configure "\$@"
CONF

  stub uname '-s : echo Linux'
  stub apply 'echo apply "$@" >> build.log'
  stub_make_install

  export RUBY_CONFIGURE="${TMP}/custom-configure"
  run_inline_definition <<DEF
install_package "ruby-2.0.0" "http://ruby-lang.org/pub/ruby-2.0.0.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make
  unstub apply

  assert_build_log <<OUT
apply -p1 -i /my/patch.diff
ruby-2.0.0: --prefix=$INSTALL_ROOT
make -j 2
make install
OUT
}

@test "copy strategy forces overwrite" {
  export RUBY_BUILD_CACHE_PATH="$FIXTURE_ROOT"

  mkdir -p "$INSTALL_ROOT/bin"
  touch "$INSTALL_ROOT/bin/package"
  chmod -w "$INSTALL_ROOT/bin/package"

  install_fixture definitions/without-checksum
  assert_success

  run "$INSTALL_ROOT/bin/package" "world"
  assert_success "hello world"
}

@test "mruby strategy" {
  package="$TMP/mruby-1.0"
  executable "$package/minirake" <<OUT
#!$BASH
set -e
echo \$0 "\$@" >> '$INSTALL_ROOT'/build.log
mkdir -p build/host/bin
touch build/host/bin/{mruby,mirb}
chmod +x build/host/bin/{mruby,mirb}
OUT
  mkdir -p "$package/include"
  touch "$package/include/mruby.h"
  mkdir -p "$RUBY_BUILD_CACHE_PATH"
  tar czf "$RUBY_BUILD_CACHE_PATH/${package##*/}.tar.gz" -C "${package%/*}" "${package##*/}"
  rm -rf "$package"

  stub gem false
  stub rake false

  mkdir -p "$INSTALL_ROOT/bin"
  touch "$INSTALL_ROOT/bin/mruby"
  chmod -w "$INSTALL_ROOT/bin/mruby"

  run_inline_definition <<DEF
install_package "mruby-1.0" "http://ruby-lang.org/pub/mruby-1.0.tar.gz" mruby
DEF
  assert_success
  assert_build_log <<OUT
./minirake
OUT

  assert [ -w "$INSTALL_ROOT/bin/mruby" ]
  assert [ -e "$INSTALL_ROOT/bin/ruby" ]
  assert [ -e "$INSTALL_ROOT/bin/irb" ]
  assert [ -e "$INSTALL_ROOT/include/mruby.h" ]
}

@test "rbx uses bundle then rake" {
  cached_tarball "rubinius-2.0.0" "Gemfile"

  stub gem false
  stub rake false
  stub bundle \
    '--version : echo 1' \
    ' : echo bundle "$@" >> build.log' \
    '--version : echo 1' \
    " exec rake install : { cat build.log; echo bundle \"\$@\"; } >> '$INSTALL_ROOT/build.log'"

  run_inline_definition <<DEF
install_package "rubinius-2.0.0" "http://releases.rubini.us/rubinius-2.0.0.tar.gz" rbx
DEF
  assert_success

  unstub bundle

  assert_build_log <<OUT
bundle --path=vendor/bundle
rubinius-2.0.0: --prefix=$INSTALL_ROOT RUBYOPT=-rrubygems
bundle exec rake install
OUT
}

@test "fixes rbx binstubs" {
  executable "${RUBY_BUILD_CACHE_PATH}/rubinius-2.0.0/gems/bin/rake" <<OUT
#!rbx
puts 'rake'
OUT
  executable "${RUBY_BUILD_CACHE_PATH}/rubinius-2.0.0/gems/bin/irb" <<OUT
#!rbx
print '>>'
OUT
  cached_tarball "rubinius-2.0.0" bin/ruby

  stub bundle false
  stub rake \
    '--version : echo 1' \
    "install : mkdir -p '$INSTALL_ROOT'; cp -fR . '$INSTALL_ROOT'"

  run_inline_definition <<DEF
install_package "rubinius-2.0.0" "http://releases.rubini.us/rubinius-2.0.0.tar.gz" rbx
DEF
  assert_success

  unstub rake

  run ls "${INSTALL_ROOT}/bin"
  assert_output <<OUT
irb
rake
ruby
OUT

  run $(type -p greadlink readlink | head -1) "${INSTALL_ROOT}/gems/bin"
  assert_success '../bin'

  assert [ -x "${INSTALL_ROOT}/bin/rake" ]
  run cat "${INSTALL_ROOT}/bin/rake"
  assert_output <<OUT
#!${INSTALL_ROOT}/bin/ruby
puts 'rake'
OUT

  assert [ -x "${INSTALL_ROOT}/bin/irb" ]
  run cat "${INSTALL_ROOT}/bin/irb"
  assert_output <<OUT
#!${INSTALL_ROOT}/bin/ruby
print '>>'
OUT
}

@test "JRuby build" {
  executable "${RUBY_BUILD_CACHE_PATH}/jruby-1.7.9/bin/jruby" <<OUT
#!${BASH}
echo jruby "\$@" >> ../build.log
OUT
  executable "${RUBY_BUILD_CACHE_PATH}/jruby-1.7.9/bin/gem" <<OUT
#!/usr/bin/env jruby
nice gem things
OUT
  cached_tarball "jruby-1.7.9" bin/foo.exe bin/bar.dll bin/baz.bat

  run_inline_definition <<DEF
install_package "jruby-1.7.9" "http://jruby.org/downloads/jruby-bin-1.7.9.tar.gz" jruby
DEF
  assert_success

  assert_build_log <<OUT
jruby gem install jruby-launcher
OUT

  run ls "${INSTALL_ROOT}/bin"
  assert_output <<OUT
gem
jruby
ruby
OUT

  assert [ -x "${INSTALL_ROOT}/bin/gem" ]
  run cat "${INSTALL_ROOT}/bin/gem"
  assert_output <<OUT
#!${INSTALL_ROOT}/bin/jruby
nice gem things
OUT
}

@test "JRuby Java 7 missing" {
  cached_tarball "jruby-9000.dev" bin/jruby

  stub java false

  run_inline_definition <<DEF
require_java7
install_package "jruby-9000.dev" "http://ci.jruby.org/jruby-dist-9000.dev-bin.tar.gz" jruby
DEF
  assert_failure
  assert_output_contains "ERROR: Java 7 required, but your Java version was:"
}

@test "JRuby Java is outdated" {
  cached_tarball "jruby-9000.dev" bin/jruby

  stub java "-version : echo 'java version \"1.6.0_21\"' >&2"

  run_inline_definition <<DEF
require_java7
install_package "jruby-9000.dev" "http://ci.jruby.org/jruby-dist-9000.dev-bin.tar.gz" jruby
DEF
  assert_failure
  assert_output_contains "ERROR: Java 7 required, but your Java version was:"
  assert_output_contains 'java version "1.6.0_21"'
}

@test "JRuby Java 7 up-to-date" {
  cached_tarball "jruby-9000.dev" bin/jruby

  stub java '-version : echo java version "1.7.0_21" >&2'

  run_inline_definition <<DEF
require_java7
install_package "jruby-9000.dev" "http://ci.jruby.org/jruby-dist-9000.dev-bin.tar.gz" jruby
DEF
  assert_success
}

@test "Java version string not on first line" {
  cached_tarball "jruby-9000.dev" bin/jruby

  stub java "-version : echo 'Picked up JAVA_TOOL_OPTIONS' >&2; echo 'java version \"1.8.0_31\"' >&2"

  run_inline_definition <<DEF
require_java7
install_package "jruby-9000.dev" "http://ci.jruby.org/jruby-dist-9000.dev-bin.tar.gz" jruby
DEF
  assert_success
}

@test "Java version string on OpenJDK" {
  cached_tarball "jruby-9000.dev" bin/jruby

  stub java "-version : echo 'openjdk version \"1.8.0_40\"' >&2"

  run_inline_definition <<DEF
require_java7
install_package "jruby-9000.dev" "http://ci.jruby.org/jruby-dist-9000.dev-bin.tar.gz" jruby
DEF
  assert_success
}

@test "JRuby Java 9 version string" {
  cached_tarball "jruby-9000.dev" bin/jruby

  stub java "-version : echo 'java version \"9\"' >&2"

  run_inline_definition <<DEF
require_java7
install_package "jruby-9000.dev" "http://ci.jruby.org/jruby-dist-9000.dev-bin.tar.gz" jruby
DEF
  assert_success
}

@test "JRuby Java 10 version string" {
  cached_tarball "jruby-9000.dev" bin/jruby

  stub java "-version : echo 'java version \"10.8\"' >&2"

  run_inline_definition <<DEF
require_java 9
install_package "jruby-9000.dev" "http://ci.jruby.org/jruby-dist-9000.dev-bin.tar.gz" jruby
DEF
  assert_success
}

@test "TruffleRuby post-install hook" {
  executable "${RUBY_BUILD_CACHE_PATH}/truffleruby-test/lib/truffle/post_install_hook.sh" <<OUT
echo Running post-install hook
OUT
  cached_tarball "truffleruby-test" bin/truffleruby

  run_inline_definition <<DEF
install_package "truffleruby-test" "URL" truffleruby
DEF
  assert_success
  assert_output_contains "Running post-install hook"
}

@test "non-writable TMPDIR aborts build" {
  export TMPDIR="${TMP}/build"
  mkdir -p "$TMPDIR"
  chmod -w "$TMPDIR"

  touch "${TMP}/build-definition"
  run ruby-build "${TMP}/build-definition" "$INSTALL_ROOT"
  assert_failure "ruby-build: TMPDIR=$TMPDIR is set to a non-accessible location"
}

@test "non-executable TMPDIR aborts build" {
  export TMPDIR="${TMP}/build"
  mkdir -p "$TMPDIR"
  chmod -x "$TMPDIR"

  touch "${TMP}/build-definition"
  run ruby-build "${TMP}/build-definition" "$INSTALL_ROOT"
  assert_failure "ruby-build: TMPDIR=$TMPDIR is set to a non-accessible location"
}

@test "initializes LDFLAGS directories" {
  cached_tarball "ruby-2.0.0"

  export LDFLAGS="-L ${BATS_TEST_DIRNAME}/what/evs"
  run_inline_definition <<DEF
install_package "ruby-2.0.0" "http://ruby-lang.org/ruby/2.0/ruby-2.0.0.tar.gz" ldflags_dirs
DEF
  assert_success

  assert [ -d "${INSTALL_ROOT}/lib" ]
  assert [ -d "${BATS_TEST_DIRNAME}/what/evs" ]
}
