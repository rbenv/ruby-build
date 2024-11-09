# ruby-build

ruby-build is a command-line tool that simplifies installation of any Ruby version from source on Unix-like systems.

It is available as a plugin for [rbenv][] as the `rbenv install` command, or as a standalone program as the `ruby-build` command.

## Installation

### Homebrew package manager
```sh
brew install ruby-build
```

Upgrade with:
```sh
brew upgrade ruby-build
```

### Clone as rbenv plugin using git
```sh
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
```

Upgrade with:
```sh
git -C "$(rbenv root)"/plugins/ruby-build pull
```

### Install manually as a standalone program

First, download a tarball from https://github.com/rbenv/ruby-build/releases/latest. Then:
```sh
tar -xzf ruby-build-*.tar.gz
PREFIX=/usr/local ./ruby-build-*/install.sh
```

## Usage

### Basic Usage

```sh
# As a standalone program
$ ruby-build --list                        # lists latest stable releases for each Ruby
$ ruby-build --definitions                 # lists all definitions, including outdated ones
$ ruby-build 3.2.2 ~/.rubies/ruby-3.2.2    # installs Ruby 3.2.2
$ ruby-build -d ruby-3.2.2 ~/.rubies       # alternate form for the previous example

# As an rbenv plugin
$ rbenv install 3.2.2  # installs Ruby 3.2.2 to ~/.rbenv/versions/3.2.2
```

> [!WARNING]
> ruby-build mostly does not verify that system dependencies are present before downloading and attempting to compile Ruby from source. Please ensure that [all requisite libraries][build-env] such as build tools and development headers are already present on your system.

Basically, what ruby-build does when installing a Ruby version is this:
- Downloads an official tarball of Ruby source code;
- Extracts the archive into a temporary directory on your system;
- Executes `./configure --prefix=/path/to/destination` in the source code;
- Runs `make install` to compile Ruby;
- Verifies that the installed Ruby is functional.

Depending on the context, ruby-build does a little bit more than the above: for example, it will try to link Ruby to the appropriate OpenSSL version, even if that means downloading and compiling OpenSSL itself; it will discover and link to Homebrew-installed instances of some libraries like libyaml and readline, etc.

### Advanced Usage

#### Custom Build Definitions

To install a version of Ruby that is not recognized by ruby-build, you can specify the path to a custom build definition file in place of a Ruby version number.

Check out [default build definitions][definitions] as examples on how to write definition files.

#### Custom Build Configuration

The build process may be configured through the following environment variables:

| Variable                        | Function                                                                                         |
| ------------------------------- | ------------------------------------------------------------------------------------------------ |
| `TMPDIR`                        | Where temporary files are stored.                                                                |
| `RUBY_BUILD_BUILD_PATH`         | Where sources are downloaded and built. (Default: a timestamped subdirectory of `TMPDIR`)        |
| `RUBY_BUILD_CACHE_PATH`         | Where to cache downloaded package files. (Default: `~/.rbenv/cache` if invoked as rbenv plugin)  |
| `RUBY_BUILD_HTTP_CLIENT`        | One of `aria2c`, `curl`, or `wget` to use for downloading. (Default: first one found in PATH)    |
| `RUBY_BUILD_ARIA2_OPTS`         | Additional options to pass to `aria2c` for downloading.                                          |
| `RUBY_BUILD_CURL_OPTS`          | Additional options to pass to `curl` for downloading.                                            |
| `RUBY_BUILD_WGET_OPTS`          | Additional options to pass to `wget` for downloading.                                            |
| `RUBY_BUILD_MIRROR_URL`         | Custom mirror URL root.                                                                          |
| `RUBY_BUILD_MIRROR_PACKAGE_URL` | Custom complete mirror URL (e.g. http://mirror.example.com/package-1.0.0.tar.gz).                |
| `RUBY_BUILD_SKIP_MIRROR`        | Bypass the download mirror and fetch all package files from their original URLs.                 |
| `RUBY_BUILD_TARBALL_OVERRIDE`   | Override the URL to fetch the ruby tarball from, optionally followed by `#checksum`.             |
| `RUBY_BUILD_DEFINITIONS`        | Colon-separated list of paths to search for build definition files.                              |
| `RUBY_BUILD_ROOT`               | The path prefix to search for build definitions files. *Deprecated:* use `RUBY_BUILD_DEFINITIONS`|
| `RUBY_BUILD_VENDOR_OPENSSL`     | Build and vendor openssl even if the system openssl is compatible                                |
| `CC`                            | Path to the C compiler.                                                                          |
| `RUBY_CFLAGS`                   | Additional `CFLAGS` options (_e.g.,_ to override `-O3`).                                         |
| `CONFIGURE_OPTS`                | Additional `./configure` options.                                                                |
| `MAKE`                          | Custom `make` command (_e.g.,_ `gmake`).                                                         |
| `MAKE_OPTS` / `MAKEOPTS`        | Additional `make` options.                                                                       |
| `MAKE_INSTALL_OPTS`             | Additional `make install` options.                                                               |
| `RUBY_CONFIGURE_OPTS`           | Additional `./configure` options (applies only to Ruby source).                                  |
| `RUBY_MAKE_OPTS`                | Additional `make` options (applies only to Ruby source).                                         |
| `RUBY_MAKE_INSTALL_OPTS`        | Additional `make install` options (applies only to Ruby source).                                 |
| `NO_COLOR`                      | Disable ANSI colors in output. The default is to use colors for output connected to a terminal.  |
| `CLICOLOR_FORCE`                | Use ANSI colors in output even when not connected to a terminal.                                 |

#### Applying Patches

Both `rbenv install` and `ruby-build` commands support the `-p/--patch` flag to apply a patch to the Ruby source code before building. Patches are read from standard input:

```sh
# applying a single patch
$ rbenv install --patch 1.9.3-p429 < /path/to/ruby.patch

# applying a patch from HTTP
$ rbenv install --patch 1.9.3-p429 < <(curl -sSL http://git.io/ruby.patch)

# applying multiple patches
$ cat fix1.patch fix2.patch | rbenv install --patch 1.9.3-p429
```

#### Checksum Verification

All Ruby definition files bundled with ruby-build include checksums for packages, meaning that all externally downloaded packages are automatically checked for integrity after fetching.

See the next section for more information on how to author checksums.

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


  [rbenv]: https://github.com/rbenv/rbenv#readme
  [definitions]: https://github.com/rbenv/ruby-build/tree/master/share/ruby-build
  [wiki]: https://github.com/rbenv/ruby-build/wiki
  [build-env]: https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
  [issue tracker]: https://github.com/rbenv/ruby-build/issues
