# ruby-build

ruby-build is an [rbenv](https://github.com/sstephenson/rbenv) plugin
that provides an `rbenv install` command to compile and install
different versions of Ruby on UNIX-like systems.

You can also use ruby-build without rbenv in environments where you
need precise control over Ruby version installation.


## Installation

### Installing as an rbenv plugin (recommended)

Installing ruby-build as an rbenv plugin will give you access to the
`rbenv install` command.

    git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

This will install the latest development version of ruby-build into
the `~/.rbenv/plugins/ruby-build` directory. From that directory, you
can check out a specific release tag. To update ruby-build, run `git
pull` to download the latest changes.

### Installing as a standalone program (advanced)

Installing ruby-build as a standalone program will give you access to
the `ruby-build` command for precise control over Ruby version
installation. If you have rbenv installed, you will also be able to
use the `rbenv install` command.

    git clone https://github.com/sstephenson/ruby-build.git
    cd ruby-build
    ./install.sh

This will install ruby-build into `/usr/local`. If you do not have
write permission to `/usr/local`, you will need to run `sudo
./install.sh` instead. You can install to a different prefix by
setting the `PREFIX` environment variable.

To update ruby-build after it has been installed, run `git pull` in
your cloned copy of the repository, then re-run the install script.

### Installing with Homebrew (for OS X users)

Mac OS X users can install ruby-build with the
[Homebrew](http://mxcl.github.com/homebrew/) package manager. This
will give you access to the `ruby-build` command. If you have rbenv
installed, you will also be able to use the `rbenv install` command.

*This is the recommended method of installation if you installed rbenv
 with Homebrew.*

    brew install ruby-build

Or, if you would like to install the latest development release:

    brew install --HEAD ruby-build


## Usage

### Using `rbenv install` with rbenv

To install a Ruby version for use with rbenv, run `rbenv install` with
the exact name of the version you want to install. For example,

    rbenv install 1.9.3-p392

Ruby versions will be installed into a directory of the same name
under `~/.rbenv/versions`.

To see a list of all available Ruby versions, run `rbenv install --list`.
You may also tab-complete available Ruby
versions if your rbenv installation is properly configured.

### Using `ruby-build` standalone

If you have installed ruby-build as a standalone program, you can use
the `ruby-build` command to compile and install Ruby versions into
specific locations.

Run the `ruby-build` command with the exact name of the version you
want to install and the full path where you want to install it. For
example,

    ruby-build 1.9.3-p392 ~/local/ruby-1.9.3-p392

To see a list of all available Ruby versions, run `ruby-build
--definitions`.

Pass the `-v` or `--verbose` flag to `ruby-build` as the first
argument to see what's happening under the hood.

### Custom definitions

Both `rbenv install` and `ruby-build` accept a path to a custom
definition file in place of a version name. Custom definitions let you
develop and install versions of Ruby that are not yet supported by
ruby-build.

See the [ruby-build built-in
definitions](https://github.com/sstephenson/ruby-build/tree/master/share/ruby-build)
as a starting point for custom definition files.

### Special environment variables

You can set certain environment variables to control the build
process.

* `TMPDIR` sets the location where ruby-build stores temporary files.
* `RUBY_BUILD_BUILD_PATH` sets the location in which sources are
  downloaded and built. By default, this is a subdirectory of
  `TMPDIR`.
* `RUBY_BUILD_CACHE_PATH`, if set, specifies a directory to use for
  caching downloaded package files.
* `RUBY_BUILD_MIRROR_URL` overrides the default mirror URL root to one
  of your choosing.
* `RUBY_BUILD_SKIP_MIRROR`, if set, forces ruby-build to download
  packages from their original source URLs instead of using a mirror.
* `CC` sets the path to the C compiler.
* `CONFIGURE_OPTS` lets you pass additional options to `./configure`.
* `MAKE` lets you override the command to use for `make`. Useful for
  specifying GNU make (`gmake`) on some systems.
* `MAKE_OPTS` (or `MAKEOPTS`) lets you pass additional options to
  `make`.
* `RUBY_CONFIGURE_OPTS` and `RUBY_MAKE_OPTS` allow you to specify
  configure and make options for buildling MRI. These variables will
  be passed to Ruby only, not any dependent packages (e.g. libyaml).

### Checksum verification

If you have the `md5`, `openssl`, or `md5sum` tool installed,
ruby-build will automatically verify the MD5 checksum of each
downloaded package before installing it.

Checksums are optional and specified as anchors on the package URL in
each definition. (All bundled definitions include checksums.)

### Package download mirrors

ruby-build will first attempt to download package files from a mirror
hosted on Amazon CloudFront. If a package is not available on the
mirror, if the mirror is down, or if the download is corrupt,
ruby-build will fall back to the official URL specified in the
defintion file.

You can point ruby-build to another mirror by specifying the
`RUBY_BUILD_MIRROR_URL` environment variable--useful if you'd like to
run your own local mirror, for example. Package mirror URLs are
constructed by joining this variable with the MD5 checksum of the
package file.

If you don't have an MD5 program installed, ruby-build will skip the
download mirror and use official URLs instead. You can force
ruby-build to bypass the mirror by setting the
`RUBY_BUILD_SKIP_MIRROR` environment variable.

The official ruby-build download mirror is sponsored by
[37signals](http://37signals.com/).

### Package download caching

You can instruct ruby-build to keep a local cache of downloaded
package files by setting the `RUBY_BUILD_CACHE_PATH` environment
variable. When set, package files will be kept in this directory after
the first successful download and reused by subsequent invocations of
`ruby-build` and `rbenv install`.

The `rbenv install` command defaults this path to `~/.rbenv/cache`, so
in most cases you can enable download caching simply by creating that
directory.

### Keeping the build directory after installation

Both `ruby-build` and `rbenv install` accept the `-k` or `--keep`
flag, which tells ruby-build to keep the downloaded source after
installation. This can be useful if you need to use `gdb` and
`memprof` with Ruby.

Source code will be kept in a parallel directory tree
`~/.rbenv/sources` when using `--keep` with the `rbenv install`
command. You should specify the location of the source code with the
`RUBY_BUILD_BUILD_PATH` environment variable when using `--keep` with
`ruby-build`.


## Getting Help

Please see the [ruby-build
wiki](https://github.com/sstephenson/ruby-build/wiki) for solutions to
common problems.

If you can't find an answer on the wiki, open an issue on the [issue
tracker](https://github.com/sstephenson/ruby-build/issues). Be sure to
include the full build log for build failures.


### License

(The MIT License)

Copyright (c) 2012 Sam Stephenson

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
