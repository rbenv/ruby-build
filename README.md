# ruby-build

ruby-build is a command-line utility that makes it easy to install virtually any
version of Ruby, from source.

It is available as a plugin for [rbenv][] that
provides the `rbenv install` command, or as a standalone program.

## Installation

```sh
# Using Homebrew on macOS
$ brew install ruby-build

# As an rbenv plugin
$ mkdir -p "$(rbenv root)"/plugins
$ git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

# As a standalone program
$ git clone https://github.com/rbenv/ruby-build.git
$ PREFIX=/usr/local ./ruby-build/install.sh
```

### Upgrading

```sh
# Via Homebrew
$ brew update && brew upgrade ruby-build

# As an rbenv plugin
$ git -C "$(rbenv root)"/plugins/ruby-build pull
```

## Usage

### Basic Usage

```sh
# As an rbenv plugin
$ rbenv install --list                 # lists all available versions of Ruby
$ rbenv install 2.2.0                  # installs Ruby 2.2.0 to ~/.rbenv/versions

# As a standalone program
$ ruby-build --definitions             # lists all available versions of Ruby
$ ruby-build 2.2.0 ~/local/ruby-2.2.0  # installs Ruby 2.2.0 to ~/local/ruby-2.2.0
```

ruby-build does not check for system dependencies before downloading and
attempting to compile the Ruby source. Please ensure that [all requisite
libraries][build-env] are available on your system.

### Advanced Usage

#### Custom Build Definitions

If you wish to develop and install a version of Ruby that is not yet supported
by ruby-build, you may specify the path to a custom “build definition file” in
place of a Ruby version number.

Use the [default build definitions][definitions] as a template for your custom
definitions.

#### Custom Build Configuration

The build process may be configured through the following environment variables:

| Variable                 | Function                                                                                         |
| ------------------------ | ------------------------------------------------------------------------------------------------ |
| `TMPDIR`                 | Where temporary files are stored.                                                                |
| `RUBY_BUILD_BUILD_PATH`  | Where sources are downloaded and built. (Default: a timestamped subdirectory of `TMPDIR`)        |
| `RUBY_BUILD_CACHE_PATH`  | Where to cache downloaded package files. (Default: `~/.rbenv/cache` if invoked as rbenv plugin)  |
| `RUBY_BUILD_HTTP_CLIENT` | One of `aria2c`, `curl`, or `wget` to use for downloading. (Default: first one found in PATH)    |
| `RUBY_BUILD_ARIA2_OPTS`  | Additional options to pass to `aria2c` for downloading.                                          |
| `RUBY_BUILD_CURL_OPTS`   | Additional options to pass to `curl` for downloading.                                            |
| `RUBY_BUILD_WGET_OPTS`   | Additional options to pass to `wget` for downloading.                                            |
| `RUBY_BUILD_MIRROR_URL`  | Custom mirror URL root.                                                                          |
| `RUBY_BUILD_MIRROR_PACKAGE_URL` | Custom complete mirror URL (e.g. http://mirror.example.com/package-1.0.0.tar.gz).                  |
| `RUBY_BUILD_SKIP_MIRROR` | Bypass the download mirror and fetch all package files from their original URLs.                 |
| `RUBY_BUILD_ROOT`        | Custom build definition directory. (Default: `share/ruby-build`)                                 |
| `RUBY_BUILD_DEFINITIONS` | Additional paths to search for build definitions. (Colon-separated list)                         |
| `CC`                     | Path to the C compiler.                                                                          |
| `RUBY_CFLAGS`            | Additional `CFLAGS` options (_e.g.,_ to override `-O3`).                                         |
| `CONFIGURE_OPTS`         | Additional `./configure` options.                                                                |
| `MAKE`                   | Custom `make` command (_e.g.,_ `gmake`).                                                         |
| `MAKE_OPTS` / `MAKEOPTS` | Additional `make` options.                                                                       |
| `DESTDIR`                | Install compiled Ruby to this directory instead of path e.g. `DESTDIR/usr/local/bin/ruby`        |
| `MAKE_INSTALL_OPTS`      | Additional `make install` options (use DESTDIR above to set the DESTDIR option)                  |
| `RUBY_CONFIGURE_OPTS`    | Additional `./configure` options (applies only to Ruby source).                                  |
| `RUBY_MAKE_OPTS`         | Additional `make` options (applies only to Ruby source).                                         |
| `RUBY_MAKE_INSTALL_OPTS` | Additional `make install` options (applies only to Ruby source).                                 |

#### Applying Patches

Both `rbenv install` and `ruby-build` support the `--patch` (`-p`) flag to apply
a patch to the Ruby (/JRuby/Rubinius/TruffleRuby) source code before building.
Patches are read from `STDIN`:

```sh
# applying a single patch
$ rbenv install --patch 1.9.3-p429 < /path/to/ruby.patch

# applying a patch from HTTP
$ rbenv install --patch 1.9.3-p429 < <(curl -sSL http://git.io/ruby.patch)

# applying multiple patches
$ cat fix1.patch fix2.patch | rbenv install --patch 1.9.3-p429
```

#### Checksum Verification

If you have the `shasum`, `openssl`, or `sha256sum` tool installed, ruby-build will
automatically verify the SHA2 checksum of each downloaded package before
installing it.

Checksums are optional and specified as anchors on the package URL in each
definition. All definitions bundled with ruby-build include checksums.

#### Package Mirrors

To speed up downloads, ruby-build fetches package files from a mirror hosted on
Amazon CloudFront. To benefit from this, the packages must specify their checksum:

```sh
# example:
install_package "ruby-2.6.5" "https://ruby-lang.org/ruby-2.6.5.tgz#<SHA2>"
```

ruby-build will first try to fetch this package from `$RUBY_BUILD_MIRROR_URL/<SHA2>`
(note: this is the complete URL), where `<SHA2>` is the checksum for the file. It
will fall back to downloading the package from the original location if:
- the package was not found on the mirror;
- the mirror is down;
- the download is corrupt, i.e. the file's checksum doesn't match;
- no tool is available to calculate the checksum; or
- `RUBY_BUILD_SKIP_MIRROR` is enabled.

You may specify a custom mirror by setting `RUBY_BUILD_MIRROR_URL`.

If a mirror site doesn't conform to the above URL format, you can specify the
complete URL by setting `RUBY_BUILD_MIRROR_PACKAGE_URL`. It behaves the same as
`RUBY_BUILD_MIRROR_URL` except being a complete URL.

The default ruby-build download mirror is sponsored by
[Basecamp](https://basecamp.com/).

#### Keeping the build directory after installation

Both `ruby-build` and `rbenv install` accept the `-k` or `--keep` flag, which
tells ruby-build to keep the downloaded source after installation. This can be
useful if you need to use `gdb` and `memprof` with Ruby.

Source code will be kept in a parallel directory tree `~/.rbenv/sources` when
using `--keep` with the `rbenv install` command. You should specify the
location of the source code with the `RUBY_BUILD_BUILD_PATH` environment
variable when using `--keep` with `ruby-build`.

## Getting Help

Please see the [ruby-build wiki][wiki] for solutions to common problems.

If you can't find an answer on the wiki, open an issue on the [issue tracker][].
Be sure to include the full build log for build failures.


  [rbenv]: https://github.com/rbenv/rbenv
  [definitions]: https://github.com/rbenv/ruby-build/tree/master/share/ruby-build
  [wiki]: https://github.com/rbenv/ruby-build/wiki
  [build-env]: https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
  [issue tracker]: https://github.com/rbenv/ruby-build/issues
