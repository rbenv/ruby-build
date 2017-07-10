# ruby-build

ruby-build (a.k.a. `rbenv install`) is a \*NIX utility that makes it easy to
install virtually any version of Ruby, from source.

It is available as a plugin for [rbenv](https://github.com/rbenv/rbenv), or as
a standalone program.

## Installation

**If you installed rbenv via Homebrew, you already have ruby-build.**

    # As an rbenv plugin (Recommended)
    $ git clone https://github.com/rbenv/ruby-build ~/.rbenv/plugins/ruby-build

    # As a standalone program (Advanced)
    $ git clone https://github.com/rbenv/ruby-build && $ ruby-build/install.sh

For more details on installing as a standalone program, see the [install
script source](https://github.com/rbenv/ruby-build/blob/master/install.sh).

### Upgrading

    # From source
    $ cd ~/.rbenv/plugins/ruby-build
    $ git pull

    # via Homebrew
    $ brew update && brew upgrade ruby-build # simple upgrade
    $ brew install --HEAD ruby-build         # installs the latest development release
    $ brew upgrade --fetch-HEAD ruby-build   # upgrades the HEAD package

## Usage

#### DEPENDENCY WARNING

Due to the considerable variation between different systems, ruby-build does
not check for dependencies before downloading and attempting to compile the
Ruby source. Before using ruby-build, please [consult the
wiki](https://github.com/rbenv/ruby-build/wiki#suggested-build-environment) to
ensure that all the requisite libraries are available on your system.
Otherwise, you may encounter segmentation faults or other critical errors.

### Basic Usage

#### With rbenv

ruby-build extends rbenv with the subcommand `rbenv install`. To see which versions of Ruby it knows about, run:

    $ rbenv install --list
    
To install one, call it again with the exact version name:

    $ rbenv install 2.2.0

`rbenv install` supports tab completion (if rbenv is properly configured). Each Ruby version built in this way is installed to `~/.rbenv/versions`.

See `rbenv help install` for more.

#### As a standalone

To see which versions of Ruby ruby-build knows about, run:

    $ ruby-build --definitions
    
To install one, specify both the exact version name and the destination directory:

    $ ruby-build 2.2.0 ~/local/ruby-2.2.0

### Advanced Usage

#### Custom Build Definitions

If you wish to develop and install a version of Ruby that is not yet supported
by ruby-build, you may specify the path to a custom “build definition file” in
place of a Ruby version number.

Use the [default build definitions][definitions] as a template for your custom
definitions.

[definitions]: https://github.com/rbenv/ruby-build/tree/master/share/ruby-build

#### Custom Build Configuration

The build process may be configured through the following environment variables:

| `TMPDIR`                 | Where temporary files are stored.                                                                |
| `RUBY_BUILD_BUILD_PATH`  | Where sources are downloaded and built. (Default: a timestamped subdirectory of `TMPDIR`)        |
| `RUBY_BUILD_CACHE_PATH`  | Where to cache downloaded package files. (Default: unset)                                        |
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
| `RUBY_CONFIGURE_OPTS`    | Additional `./configure` options (applies to MRI only, not dependent packages; _e.g.,_ libyaml). |
| `RUBY_MAKE_OPTS`         | Additional `make` options (applies to MRI only, not dependent packages; _e.g.,_ libyaml)         |
| `RUBY_MAKE_INSTALL_OPTS` | Additional `make install` options (applies to MRI only, not dependent packages; _e.g.,_ libyaml) |

#### Applying Patches

Both `rbenv install` and `ruby-build` support the `--patch` (`-p`) flag to apply a patch to the Ruby (/JRuby/Rubinius)
source code before building. Patches are read from `STDIN`:

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

#### Package Caching

You can instruct ruby-build to keep a local cache of downloaded package files
by setting the `RUBY_BUILD_CACHE_PATH` environment variable. When set, package
files will be kept in this directory after the first successful download and
reused by subsequent invocations of `ruby-build` and `rbenv install`.

The `rbenv install` command defaults this path to `~/.rbenv/cache`, so in most
cases you can enable download caching simply by creating that directory.

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

[wiki]: https://github.com/rbenv/ruby-build/wiki

If you can't find an answer on the wiki, open an issue on the [issue
tracker](https://github.com/rbenv/ruby-build/issues). Be sure to include
the full build log for build failures.
