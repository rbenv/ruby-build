#!/usr/bin/env bats

load test_helper
export RUBY_BUILD_CACHE_PATH="$TMP/cache"
export MAKE=make
export MAKE_OPTS="-j 2"
export CC=cc
export -n RUBY_CONFIGURE_OPTS
export -n PKG_CONFIG_PATH

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
  local save_to_fixtures
  case "$*" in
  "ruby-3.2.0 configure" | "yaml-0.1.6 configure" | "jruby-9000.dev bin/jruby" )
    save_to_fixtures=1
    ;;
  esac

  local tarball="${1}.tar.gz"
  local fixture_tarball="${FIXTURE_ROOT}/${tarball}"
  local cached_tarball="${RUBY_BUILD_CACHE_PATH}/${tarball}"
  shift 1
  
  if [ -n "$save_to_fixtures" ] && [ -e "$fixture_tarball" ]; then
    mkdir -p "$(dirname "$cached_tarball")"
    cp "$fixture_tarball" "$cached_tarball"
    return 0
  fi

  generate_tarball "$cached_tarball" "$@"
  [ -z "$save_to_fixtures" ] || cp "$cached_tarball" "$fixture_tarball"
}

generate_tarball() {
  local tarfile="$1"
  shift 1
  local name path
  name="$(basename "${tarfile%.tar.gz}")"
  path="$(mktemp -d "$TMP/tarball.XXXXX")/${name}"

  local file target
  for file; do
    case "$file" in
    config | configure )
      mkdir -p "$(dirname "${path}/${file}")"
      cat > "${path}/${file}" <<OUT
#!$BASH
IFS=,
echo "$name: [\$*]" \${RUBYOPT:+RUBYOPT=\$RUBYOPT} \${PKG_CONFIG_PATH:+PKG_CONFIG_PATH=\$PKG_CONFIG_PATH} >> build.log
OUT
      chmod +x "${path}/${file}"
      ;;
    *:* )
      target="${file#*:}"
      file="${file%:*}"
      mkdir -p "$(dirname "${path}/${file}")"
      cp "$target" "${path}/${file}"
      ;;
    * )
      mkdir -p "$(dirname "${path}/${file}")"
      touch "${path}/${file}"
      ;;
    esac
  done

  mkdir -p "$(dirname "$tarfile")"
  tar czf "$tarfile" -C "${path%/*}" "$name"
  rm -rf "$path"
}

stub_make_install() {
  local target="${1:-install}"
  stub "$MAKE" \
    " : echo \"\${PKG_CONFIG_PATH:+PKG_CONFIG_PATH=\$PKG_CONFIG_PATH }$MAKE \$(inspect_args \"\$@\")\" >> build.log" \
    "$target : echo \"$MAKE \$(inspect_args \"\$@\")\" >> build.log && cat build.log >> '$INSTALL_ROOT/build.log'"
}

assert_build_log() {
  run cat "$INSTALL_ROOT/build.log"
  assert_output
}

@test "yaml is installed for ruby" {
  cached_tarball "yaml-0.1.6" configure
  cached_tarball "ruby-3.2.0" configure

  stub_repeated uname '-s : echo Linux'
  stub_repeated brew false
  stub_make_install
  stub_make_install

  install_fixture definitions/needs-yaml
  assert_success

  unstub uname
  unstub brew
  unstub make

  assert_build_log <<OUT
yaml-0.1.6: [--prefix=$INSTALL_ROOT]
make -j 2
make install
ruby-3.2.0: [--prefix=$INSTALL_ROOT,--with-ext=openssl,psych,+]
make -j 2
make install
OUT
}

@test "apply ruby patch before building" {
  cached_tarball "yaml-0.1.6" configure
  cached_tarball "ruby-3.2.0" configure

  stub_repeated uname '-s : echo Linux'
  stub_repeated brew false
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
  unstub brew
  unstub make
  unstub patch

  assert_build_log <<OUT
yaml-0.1.6: [--prefix=$INSTALL_ROOT]
make -j 2
make install
patch -p0 --force -i $TMP/ruby-patch.XXX
ruby-3.2.0: [--prefix=$INSTALL_ROOT,--with-ext=openssl,psych,+]
make -j 2
make install
OUT
}

@test "striplevel ruby patch before building" {
  cached_tarball "yaml-0.1.6" configure
  cached_tarball "ruby-3.2.0" configure

  stub_repeated uname '-s : echo Linux'
  stub_repeated brew false
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
  unstub brew
  unstub make
  unstub patch

  assert_build_log <<OUT
yaml-0.1.6: [--prefix=$INSTALL_ROOT]
make -j 2
make install
patch -p1 --force -i $TMP/ruby-patch.XXX
ruby-3.2.0: [--prefix=$INSTALL_ROOT,--with-ext=openssl,psych,+]
make -j 2
make install
OUT
}

@test "apply ruby patch from git diff before building" {
  cached_tarball "yaml-0.1.6" configure
  cached_tarball "ruby-3.2.0" configure

  stub_repeated uname '-s : echo Linux'
  stub_repeated brew false
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
  unstub brew
  unstub make
  unstub patch

  assert_build_log <<OUT
yaml-0.1.6: [--prefix=$INSTALL_ROOT]
make -j 2
make install
patch -p1 --force -i $TMP/ruby-patch.XXX
ruby-3.2.0: [--prefix=$INSTALL_ROOT,--with-ext=openssl,psych,+]
make -j 2
make install
OUT
}

@test "yaml is linked from Homebrew" {
  cached_tarball "ruby-3.2.0" configure

  brew_libdir="$TMP/homebrew-yaml"
  mkdir -p "$brew_libdir"

  stub_repeated uname '-s : echo Linux'
  stub_repeated brew "--prefix libyaml : echo '$brew_libdir'"
  stub_make_install

  run_inline_definition <<DEF
install_package "ruby-3.2.0" "http://ruby-lang.org/ruby/2.0/ruby-3.2.0.tar.gz"
DEF
  assert_success

  unstub uname
  unstub brew
  unstub make

  assert_build_log <<OUT
ruby-3.2.0: [--prefix=$INSTALL_ROOT,--with-libyaml-dir=$brew_libdir,--with-ext=openssl,psych,+]
make -j 2
make install
OUT
}

@test "gmp is linked from Homebrew" {
  cached_tarball "ruby-3.2.0" configure

  gmp_libdir="$TMP/homebrew-gmp"
  mkdir -p "$gmp_libdir"

  stub_repeated brew "--prefix gmp : echo '$gmp_libdir'"
  stub_make_install

  run_inline_definition <<DEF
install_package "ruby-3.2.0" "http://ruby-lang.org/ruby/2.0/ruby-3.2.0.tar.gz"
DEF
  assert_success

  unstub brew
  unstub make

  assert_build_log <<OUT
ruby-3.2.0: [--prefix=$INSTALL_ROOT,--with-gmp-dir=$gmp_libdir,--with-ext=openssl,psych,+]
make -j 2
make install
OUT
}

@test "readline is linked from Homebrew" {
  cached_tarball "ruby-3.2.0" configure

  readline_libdir="$TMP/homebrew-readline"
  mkdir -p "$readline_libdir"

  stub_repeated brew "--prefix readline : echo '$readline_libdir'"
  stub_make_install

  run_inline_definition <<DEF
install_package "ruby-3.2.0" "http://ruby-lang.org/ruby/2.0/ruby-3.2.0.tar.gz"
DEF
  assert_success

  unstub brew
  unstub make

  assert_build_log <<OUT
ruby-3.2.0: [--prefix=$INSTALL_ROOT,--with-readline-dir=$readline_libdir,--with-ext=openssl,psych,+]
make -j 2
make install
OUT
}

@test "readline is not auto-discovered for Ruby 3.3" {
  cached_tarball "ruby-3.3.0" configure

  readline_libdir="$TMP/homebrew-readline"
  mkdir -p "$readline_libdir"

  stub_repeated brew "--prefix readline : echo '$readline_libdir'"
  stub_make_install

  run_inline_definition <<DEF
install_package "ruby-3.3.0" "http://ruby-lang.org/ruby/3.0/ruby-3.3.0.tar.gz"
DEF
  assert_success

  unstub brew
  unstub make

  assert_build_log <<OUT
ruby-3.3.0: [--prefix=$INSTALL_ROOT,--with-ext=openssl,psych,+]
make -j 2
make install
OUT
}

@test "readline is not linked from Homebrew when explicitly defined" {
  cached_tarball "ruby-3.2.0" configure

  readline_libdir="$TMP/homebrew-readline"
  mkdir -p "$readline_libdir"

  stub_repeated brew "--prefix readline : echo '$readline_libdir'" ' : false'
  stub_make_install

  export RUBY_CONFIGURE_OPTS='--with-readline-dir=/custom'
  run_inline_definition <<DEF
install_package "ruby-3.2.0" "http://ruby-lang.org/ruby/2.0/ruby-3.2.0.tar.gz"
DEF
  assert_success

  unstub brew
  unstub make

  assert_build_log <<OUT
ruby-3.2.0: [--prefix=$INSTALL_ROOT,--with-ext=openssl,psych,+,--with-readline-dir=/custom]
make -j 2
make install
OUT
}

@test "use system OpenSSL" {
  cached_tarball "ruby-3.2.0" configure

  stub_repeated uname '-s : echo Linux'
  stub_repeated brew false
  # shellcheck disable=SC2016
  stub cc '-xc -E - : [[ "$(cat)" == *OPENSSL_VERSION_TEXT* ]] && printf "# <unrelated> 4.0.2\n\"OpenSSL 1.0.3a  1 Aug 202\"\n0 errors.\n"'
  stub_make_install

  mkdir -p "$INSTALL_ROOT"/openssl/ssl # OPENSSLDIR
  run_inline_definition <<DEF
install_package "openssl-1.1.1w" "https://www.openssl.org/source/openssl-1.1.1w.tar.gz" openssl --if needs_openssl_102_300
install_package "ruby-3.2.0" "http://ruby-lang.org/ruby/2.0/ruby-3.2.0.tar.gz"
DEF
  assert_success

  unstub uname
  unstub brew
  unstub make

  assert_build_log <<OUT
ruby-3.2.0: [--prefix=$INSTALL_ROOT,--with-ext=openssl,psych,+]
make -j 2
make install
OUT
}

@test "install bundled OpenSSL on Linux" {
  cached_tarball "openssl-1.1.1w" config
  cached_tarball "ruby-3.2.0" configure

  mkdir -p "${TMP}/ssl/certs"
  touch "${TMP}/ssl/cert.pem"

  stub_repeated uname '-s : echo Linux'
  stub_repeated brew false
  stub cc '-xc -E - : echo "OpenSSL 1.0.1a  1 Aug 2023"' # system_openssl_version
  stub openssl "version -d : echo 'OPENSSLDIR: \"${TMP}/ssl\"'"
  stub_make_install "install_sw"
  stub_make_install

  mkdir -p "$INSTALL_ROOT"/openssl/ssl # OPENSSLDIR
  run_inline_definition <<DEF
install_package "openssl-1.1.1w" "https://www.openssl.org/source/openssl-1.1.1w.tar.gz" openssl --if needs_openssl_102_300
install_package "ruby-3.2.0" "http://ruby-lang.org/ruby/2.0/ruby-3.2.0.tar.gz"
DEF
  assert_success

  unstub uname
  unstub brew
  unstub cc
  # Depending on certain system certificate files being present under /etc/,
  # `openssl version -d` might not have been called, so avoid unstubbing it
  # since that would verify the number of invocations.
  #unstub openssl
  unstub make

  assert_build_log <<OUT
openssl-1.1.1w: [--prefix=${INSTALL_ROOT}/openssl,--openssldir=${INSTALL_ROOT}/openssl/ssl,--libdir=lib,zlib-dynamic,no-ssl3,shared,-Wl,-rpath,${INSTALL_ROOT}/openssl/lib]
make -j 2
make install_sw install_ssldirs
ruby-3.2.0: [--prefix=$INSTALL_ROOT,--with-openssl-dir=$INSTALL_ROOT/openssl,--with-ext=openssl,psych,+] PKG_CONFIG_PATH=${TMP}/install/openssl/lib/pkgconfig
PKG_CONFIG_PATH=${TMP}/install/openssl/lib/pkgconfig make -j 2
make install
OUT
}

@test "install bundled OpenSSL on macOS" {
  cached_tarball "openssl-1.1.1w" config
  cached_tarball "ruby-3.2.0" configure

  stub_repeated uname '-s : echo Darwin'
  stub security \
    'find-certificate -a -p /Library/Keychains/System.keychain : echo "System.keychain"' \
    'find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain : echo "SystemRootCertificates.keychain"'
  stub_repeated brew false
  stub cc '-xc -E - : echo "OpenSSL 1.0.1a  1 Aug 2023"' # system_openssl_version
  stub openssl
  stub_make_install "install_sw"
  stub_make_install

  mkdir -p "$INSTALL_ROOT"/openssl/ssl # OPENSSLDIR
  run_inline_definition <<DEF
install_package "openssl-1.1.1w" "https://www.openssl.org/source/openssl-1.1.1w.tar.gz" openssl --if needs_openssl_102_300
install_package "ruby-3.2.0" "http://ruby-lang.org/ruby/2.0/ruby-3.2.0.tar.gz"
DEF
  assert_success

  unstub uname
  unstub security
  unstub brew
  # Depending on the state of system `/usr/bin/openssl` in the test runner,
  # `cc` might not have been called, so avoid unstubbing it since that would
  # verify the number of invocations.
  #unstub cc
  unstub openssl
  unstub make

  # No rpath on macOS, OpenSSL sets it itself: https://wiki.openssl.org/index.php/Compilation_and_Installation#Using_RPATHs
  assert_build_log <<OUT
openssl-1.1.1w: [--prefix=${INSTALL_ROOT}/openssl,--openssldir=${INSTALL_ROOT}/openssl/ssl,--libdir=lib,zlib-dynamic,no-ssl3,shared]
make -j 2
make install_sw install_ssldirs
ruby-3.2.0: [--prefix=$INSTALL_ROOT,--with-openssl-dir=$INSTALL_ROOT/openssl,--with-ext=openssl,psych,+] PKG_CONFIG_PATH=${TMP}/install/openssl/lib/pkgconfig
PKG_CONFIG_PATH=${TMP}/install/openssl/lib/pkgconfig make -j 2
make install
OUT

  run cat "$INSTALL_ROOT"/openssl/ssl/cert.pem
  assert_output <<PEM
System.keychain
SystemRootCertificates.keychain
PEM
}

@test "skip bundling OpenSSL if custom openssl dir was specified" {
  cached_tarball "ruby-3.2.0" configure

  stub_repeated uname '-s : echo Darwin'
  stub_repeated brew false
  stub_make_install

  RUBY_CONFIGURE_OPTS="--with-openssl-dir=/path/to/openssl" run_inline_definition <<DEF
install_package "openssl-1.1.1w" "https://www.openssl.org/source/openssl-1.1.1w.tar.gz" openssl --if needs_openssl_102_300
install_package "ruby-3.2.0" "http://ruby-lang.org/ruby/2.0/ruby-3.2.0.tar.gz"
DEF
  assert_success

  unstub uname
  unstub brew
  unstub make

  assert_build_log <<OUT
ruby-3.2.0: [--prefix=$INSTALL_ROOT,--with-ext=openssl,psych,+,--with-openssl-dir=/path/to/openssl]
make -j 2
make install
OUT
}

@test "explicit OpenSSL dir sets PKG_CONFIG_PATH for older Rubies" {
  cached_tarball "ruby-2.7.3" configure

  stub_repeated uname '-s : echo Darwin'
  stub_repeated brew false
  stub_make_install

  PKG_CONFIG_PATH=/orig/searchpath RUBY_CONFIGURE_OPTS="--with-openssl-dir=/path/to/openssl" run_inline_definition <<DEF
install_package "ruby-2.7.3" "http://ruby-lang.org/ruby/2.0/ruby-2.7.3.tar.gz"
DEF
  assert_success

  unstub uname
  unstub brew
  unstub make

  assert_build_log <<OUT
ruby-2.7.3: [--prefix=$INSTALL_ROOT,--with-ext=openssl,psych,+,--with-openssl-dir=/path/to/openssl] PKG_CONFIG_PATH=/path/to/openssl/lib/pkgconfig:/orig/searchpath
PKG_CONFIG_PATH=/path/to/openssl/lib/pkgconfig:/orig/searchpath make -j 2
make install
OUT
}

@test "link to Homebrew OpenSSL" {
  cached_tarball "ruby-3.2.0" configure

  local homebrew_prefix="${TMP}/homebrew"
  executable "${homebrew_prefix}/opt/openssl@3/bin/openssl" <<EXE
#!/$BASH
[ "\$1" = "version" ] || exit 1
echo 'OpenSSL 3.2.1  20 Dec 2019'
EXE
  executable "${homebrew_prefix}/opt/openssl@3.1/bin/openssl" <<EXE
#!/$BASH
[ "\$1" = "version" ] || exit 1
echo 'OpenSSL 3.1.22  20 Dec 2019'
EXE
  executable "${homebrew_prefix}/opt/openssl@3.0/bin/openssl" <<EXE
#!/$BASH
[ "\$1" = "version" ] || exit 1
echo 'OpenSSL 3.0.2  20 Dec 2019'
EXE
  executable "${homebrew_prefix}/opt/openssl@1.1/bin/openssl" <<EXE
#!/$BASH
[ "\$1" = "version" ] || exit 1
echo 'OpenSSL 1.1.1v  20 Dec 2019'
EXE

  stub_repeated uname '-s : echo Linux'
  stub cc '-xc -E - : echo "OpenSSL 1.0.1a  1 Aug 2023"'
  stub_repeated brew \
    'list : printf "git\nopenssl@3\nopenssl-utils\nopenssl@1.1\nopenssl@3.0\nwget\nopenssl@3.1"' \
    "--prefix : echo '$homebrew_prefix'/opt/\$2 "
  stub_make_install

  run_inline_definition <<DEF
install_package "openssl-1.1.1w" "https://www.openssl.org/source/openssl-1.1.1w.tar.gz" openssl --if needs_openssl:1.1.0-3.0.x
install_package "ruby-3.2.0" "http://ruby-lang.org/ruby/2.0/ruby-3.2.0.tar.gz"
DEF
  assert_success

  unstub uname
  unstub cc
  unstub brew
  unstub make

  assert_build_log <<OUT
ruby-3.2.0: [--prefix=$INSTALL_ROOT,--with-openssl-dir=$TMP/homebrew/opt/openssl@3.0,--with-ext=openssl,psych,+]
make -j 2
make install
OUT
}

@test "forward extra command-line arguments as configure flags" {
  cached_tarball "ruby-3.2.0" configure

  stub_repeated brew false
  stub_make_install

  cat > "$TMP/build-definition" <<DEF
install_package "ruby-3.2.0" "http://ruby-lang.org/ruby/2.0/ruby-3.2.0.tar.gz"
DEF

  RUBY_CONFIGURE_OPTS='--with-readline-dir=/custom' run ruby-build "$TMP/build-definition" "$INSTALL_ROOT" -- cppflags="-DYJIT_FORCE_ENABLE -DRUBY_PATCHLEVEL_NAME=test" --with-openssl-dir=/path/to/openssl
  assert_success

  unstub brew
  unstub make

  assert_build_log <<OUT
ruby-3.2.0: [--prefix=$INSTALL_ROOT,cppflags=-DYJIT_FORCE_ENABLE -DRUBY_PATCHLEVEL_NAME=test,--with-openssl-dir=/path/to/openssl,--with-ext=openssl,psych,+,--with-readline-dir=/custom]
make -j 2
make install
OUT
}

@test "number of CPU cores defaults to 2" {
  cached_tarball "ruby-3.2.0" configure

  stub_repeated uname '-s : echo Darwin'
  stub sysctl false
  stub_make_install

  export -n MAKE_OPTS
  run_inline_definition <<DEF
install_package "ruby-3.2.0" "http://ruby-lang.org/ruby/2.0/ruby-3.2.0.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
ruby-3.2.0: [--prefix=$INSTALL_ROOT,--with-ext=openssl,psych,+]
make -j 2
make install
OUT
}

@test "number of CPU cores is detected on Mac" {
  cached_tarball "ruby-3.2.0" configure

  stub_repeated uname '-s : echo Darwin'
  stub sysctl '-n hw.ncpu : echo 4'
  stub_make_install

  export -n MAKE_OPTS
  run_inline_definition <<DEF
install_package "ruby-3.2.0" "http://ruby-lang.org/ruby/2.0/ruby-3.2.0.tar.gz"
DEF
  assert_success

  unstub uname
  unstub sysctl
  unstub make

  assert_build_log <<OUT
ruby-3.2.0: [--prefix=$INSTALL_ROOT,--with-ext=openssl,psych,+]
make -j 4
make install
OUT
}

@test "number of CPU cores is detected on FreeBSD" {
  cached_tarball "ruby-3.2.0" configure

  stub_repeated uname '-s : echo FreeBSD'
  stub sysctl '-n hw.ncpu : echo 1'
  stub_make_install

  export -n MAKE_OPTS
  RUBY_CONFIGURE_OPTS="--with-openssl-dir=/test" run_inline_definition <<DEF
install_package "ruby-3.2.0" "http://ruby-lang.org/ruby/2.0/ruby-3.2.0.tar.gz"
DEF
  assert_success

  unstub uname
  unstub sysctl
  unstub make

  assert_build_log <<OUT
ruby-3.2.0: [--prefix=$INSTALL_ROOT,--with-ext=openssl,psych,+,--with-openssl-dir=/test]
make -j 1
make install
OUT
}

@test "using MAKE_INSTALL_OPTS" {
  cached_tarball "ruby-3.2.0" configure

  stub_repeated uname '-s : echo Linux'
  stub_make_install

  export MAKE_INSTALL_OPTS="--globalmake"
  export RUBY_MAKE_INSTALL_OPTS="RUBYMAKE=true with spaces"
  run_inline_definition <<DEF
install_package "ruby-3.2.0" "http://ruby-lang.org/ruby/2.0/ruby-3.2.0.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
ruby-3.2.0: [--prefix=$INSTALL_ROOT,--with-ext=openssl,psych,+]
make -j 2
make install --globalmake RUBYMAKE=true with spaces
OUT
}

@test "nested install destination" {
  export RUBY_BUILD_CACHE_PATH="$FIXTURE_ROOT"

  run ruby-build -d "$FIXTURE_ROOT"/definitions/without-checksum "$INSTALL_ROOT"
  assert_success
  refute [ -d "$INSTALL_ROOT"/bin ]
  assert [ -x "$INSTALL_ROOT"/without-checksum/bin/package ]
}

@test "nested install destination with ruby prefix" {
  cached_tarball "ruby-3.2.0" configure

  stub_repeated brew false
  stub_make_install

  mkdir -p "$TMP"/definitions
  cat > "$TMP"/definitions/3.2.0 <<DEF
install_package "ruby-3.2.0" "http://ruby-lang.org/ruby/2.0/ruby-3.2.0.tar.gz"
DEF

  RUBY_BUILD_DEFINITIONS="$TMP"/definitions run ruby-build --dir ruby-3.2.0 "$INSTALL_ROOT"
  assert_success

  unstub brew
  unstub make

  assert_build_log <<OUT
ruby-3.2.0: [--prefix=$INSTALL_ROOT/ruby-3.2.0,--with-ext=openssl,psych,+]
make -j 2
make install
OUT
}

@test "definition file with ruby prefix" {
  export RUBY_BUILD_CACHE_PATH="$FIXTURE_ROOT"

  cd "$TMP"
  cat > ruby-123-internal <<DEF
install_package "package-1.0.0" "http://example.com/packages/package-1.0.0.tar.gz" copy
DEF

  run ruby-build ruby-123-internal "$INSTALL_ROOT"
  assert_success
  assert [ -x "$INSTALL_ROOT"/bin/package ]
}

@test "custom relative install destination" {
  export RUBY_BUILD_CACHE_PATH="$FIXTURE_ROOT"

  cd "$TMP"
  install_fixture definitions/without-checksum ./here
  assert_success
  assert [ -x ./here/bin/package ]
}

@test "can use RUBY_CONFIGURE to apply a patch" {
  cached_tarball "ruby-3.2.0" configure

  executable "${TMP}/custom-configure" <<CONF
#!$BASH
apply -p1 -i /my/patch.diff
exec ./configure "\$@"
CONF

  stub_repeated uname '-s : echo Linux'
  stub apply 'echo apply "$@" >> build.log'
  stub_make_install

  RUBY_CONFIGURE="${TMP}/custom-configure" run_inline_definition <<DEF
install_package "ruby-3.2.0" "http://ruby-lang.org/pub/ruby-3.2.0.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make
  unstub apply

  assert_build_log <<OUT
apply -p1 -i /my/patch.diff
ruby-3.2.0: [--prefix=$INSTALL_ROOT,--with-ext=openssl,psych,+]
make -j 2
make install
OUT
}

@test "Ruby 2.4 and older does not pass --with-ext" {
  cached_tarball "ruby-2.4.10" configure

  stub_repeated uname '-s : echo Linux'
  stub_make_install

  run_inline_definition <<DEF
install_package "ruby-2.4.10" "http://ruby-lang.org/pub/ruby-2.4.10.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
ruby-2.4.10: [--prefix=$INSTALL_ROOT]
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

@test "dev Ruby install strategy" {
  cached_tarball "ruby-3.2.0" configure

  stub_repeated uname '-s : echo Linux'
  stub_repeated brew false
  # shellcheck disable=SC2016
  stub autoreconf ' : echo "autoreconf $(inspect_args "$@")" >> build.log'
  stub_make_install "update-gems"

  run_inline_definition <<DEF
install_package "ruby-3.2.0" "http://ruby-lang.org/ruby/3.0/ruby-3.2.0.tar.gz" autoconf enable_shared standard_install_with_bundled_gems
DEF
  assert_success

  unstub uname
  unstub brew
  unstub make
  unstub autoreconf

  assert_build_log <<OUT
autoreconf -i
ruby-3.2.0: [--prefix=${TMP}/install,--enable-shared,--with-ext=openssl,psych,+]
make -j 2
make update-gems extract-gems install
OUT
}

@test "mruby strategy" {
  executable "$TMP/minirake" <<OUT
#!$BASH
set -e
IFS=,
echo "\$0 [\$*]" >> '$INSTALL_ROOT'/build.log
mkdir -p build/host/bin
touch build/host/bin/{mruby,mirb}
chmod +x build/host/bin/{mruby,mirb}
OUT
  cached_tarball "mruby-1.0" "minirake:$TMP/minirake" include/mruby.h

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
./minirake []
OUT

  assert [ -w "$INSTALL_ROOT/bin/mruby" ]
  assert [ -e "$INSTALL_ROOT/bin/ruby" ]
  assert [ -e "$INSTALL_ROOT/bin/irb" ]
  assert [ -e "$INSTALL_ROOT/include/mruby.h" ]
}

@test "rbx uses bundle then rake" {
  cached_tarball "rubinius-2.0.0" Gemfile configure

  stub gem false
  stub rake false
  stub bundle \
    '--version : echo 1' \
    ' : echo bundle "$@" >> build.log' \
    "exec rake install : { cat build.log; echo bundle \"\$@\"; } >> '$INSTALL_ROOT/build.log'"

  run_inline_definition <<DEF
install_package "rubinius-2.0.0" "http://releases.rubini.us/rubinius-2.0.0.tar.gz" rbx
DEF
  assert_success

  unstub bundle

  assert_build_log <<OUT
bundle --path=vendor/bundle
rubinius-2.0.0: [--prefix=$INSTALL_ROOT] RUBYOPT=-rrubygems 
bundle exec rake install
OUT
}

@test "fixes rbx binstubs" {
  executable "${TMP}/rbx-rake" <<OUT
#!rbx
puts 'rake'
OUT
  executable "${TMP}/rbx-irb" <<OUT
#!rbx
print '>>'
OUT
  cached_tarball "rubinius-2.0.0" configure bin/ruby \
    gems/bin/rake:"$TMP"/rbx-rake \
    gems/bin/irb:"$TMP"/rbx-irb

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
  executable "${TMP}/jruby-bin" <<OUT
#!${BASH}
IFS=,
echo "jruby [\$*]" >> ../build.log
OUT
  executable "${TMP}/jruby-gem" <<OUT
#!/usr/bin/env jruby
nice gem things
OUT
  cached_tarball "jruby-1.7.9" bin/foo.exe bin/bar.dll bin/baz.bat \
    bin/jruby:"$TMP"/jruby-bin \
    bin/gem:"$TMP"/jruby-gem

  run_inline_definition <<DEF
install_package "jruby-1.7.9" "http://jruby.org/downloads/jruby-bin-1.7.9.tar.gz" jruby
DEF
  assert_success

  assert_build_log <<OUT
jruby [gem,install,jruby-launcher,--no-document]
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
  assert_output_contains "ERROR: Java >= 7 required, but your Java version was:"
}

@test "JRuby Java is outdated" {
  cached_tarball "jruby-9000.dev" bin/jruby

  stub java "-version : echo 'java version \"1.6.0_21\"' >&2"

  run_inline_definition <<DEF
require_java7
install_package "jruby-9000.dev" "http://ci.jruby.org/jruby-dist-9000.dev-bin.tar.gz" jruby
DEF
  assert_failure
  assert_output_contains "ERROR: Java >= 7 required, but your Java version was:"
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

@test "JRuby Java 11 version string" {
  cached_tarball "jruby-9000.dev" bin/jruby

  stub java "-version : echo 'openjdk version \"11.0.10\" 2021-01-19' >&2"

  run_inline_definition <<DEF
require_java 8
install_package "jruby-9000.dev" "http://ci.jruby.org/jruby-dist-9000.dev-bin.tar.gz" jruby
DEF
  assert_success
}

@test "JRuby Java 17 version string" {
  cached_tarball "jruby-9000.dev" bin/jruby

  stub java "-version : echo 'openjdk version \"17\" 2021-09-14' >&2"

  run_inline_definition <<DEF
require_java 8
install_package "jruby-9000.dev" "http://ci.jruby.org/jruby-dist-9000.dev-bin.tar.gz" jruby
DEF
  assert_success
}

@test "TruffleRuby post-install hook" {
  executable "${TMP}/hook.sh" <<OUT
echo Running post-install hook >> build.log
OUT
  cached_tarball "truffleruby-test" bin/truffleruby lib/truffle/post_install_hook.sh:"$TMP"/hook.sh

  run_inline_definition <<DEF
install_package "truffleruby-test" "URL" truffleruby
DEF
  assert_success
  run cat "$INSTALL_ROOT"/build.log
  assert_success "Running post-install hook"
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

@test "does not initialize LDFLAGS directories" {
  cached_tarball "ruby-3.2.0" configure

  export LDFLAGS="-L ${BATS_TEST_DIRNAME}/what/evs"
  run_inline_definition <<DEF
install_package "ruby-3.2.0" "http://ruby-lang.org/ruby/2.0/ruby-3.2.0.tar.gz" ldflags_dirs
DEF
  assert_success

  assert [ ! -d "${INSTALL_ROOT}/lib" ]
  assert [ ! -d "${BATS_TEST_DIRNAME}/what/evs" ]
}
