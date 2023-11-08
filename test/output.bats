#!/usr/bin/env bats

load test_helper

@test "print_command" {
  mkdir -p "$TMP"

  cat <<EOF > "$TMP"/definition
print_command ./configure --prefix="\$PREFIX_PATH" --arg='with spaces'
EOF
  # substitute $TMPDIR in command invocations
  TMPDIR="/tmp/" run ruby-build "$TMP"/definition /tmp/path/to/prefix
  assert_output " ./configure \"--prefix=\$TMPDIR/path/to/prefix\" '--arg=with spaces'"
  # doesn't substitute TMPDIR if it didn't come from user's environment
  TMPDIR="" run ruby-build "$TMP"/definition /tmp/path/to/prefix
  assert_output " ./configure --prefix=/tmp/path/to/prefix '--arg=with spaces'"

  cat <<EOF > "$TMP"/definition
print_command install --bindir="$TMP"/home/.local/bin
EOF
  # substitute $HOME in command invocations
  HOME="$TMP"/home TMPDIR="" run ruby-build "$TMP"/definition /tmp/path/to/prefix
  assert_output " install \"--bindir=\$HOME/.local/bin\""
  # do not substitute $HOME if it's root path
  HOME="/" TMPDIR="" run ruby-build "$TMP"/definition /tmp/path/to/prefix
  assert_output " install --bindir=${TMP}/home/.local/bin"
}
