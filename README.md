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
$ cd "$(rbenv root)"/plugins/ruby-build && git pull
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
| `RUBY_BUILD_SKIP_MIRROR` | Always download from official sources, not mirrors. (Default: unset)                             |
| `RUBY_BUILD_ROOT`        | Custom build definition directory. (Default: `share/ruby-build`)                                 |
| `RUBY_BUILD_DEFINITIONS` | Additional paths to search for build definitions. (Colon-separated list)                         |
| `CC`                     | Path to the C compiler.                                                                          |
| `RUBY_CFLAGS`            | Additional `CFLAGS` options (_e.g.,_ to override `-O3`).                                         |
| `CONFIGURE_OPTS`         | Additional `./configure` options.                                                                |
| `MAKE`                   | Custom `make` command (_e.g.,_ `gmake`).                                                         |
| `MAKE_OPTS` / `MAKEOPTS` | Additional `make` options.                                                                       |
| `MAKE_INSTALL_OPTS`      | Additional `make install` options.                                                               |
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
definition. (All bundled definitions include checksums.)

#### Package Mirrors

By default, ruby-build downloads package files from a mirror hosted on Amazon
CloudFront. If a package is not available on the mirror, if the mirror is
down, or if the download is corrupt, ruby-build will fall back to the official
URL specified in the definition file.

You can point ruby-build to another mirror by specifying the
`RUBY_BUILD_MIRROR_URL` environment variable--useful if you'd like to run your
own local mirror, for example. Package mirror URLs are constructed by joining
this variable with the SHA2 checksum of the package file.

If you don't have an SHA2 program installed, ruby-build will skip the download
mirror and use official URLs instead. You can force ruby-build to bypass the
mirror by setting the `RUBY_BUILD_SKIP_MIRROR` environment variable.

The official ruby-build download mirror is sponsored by
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
