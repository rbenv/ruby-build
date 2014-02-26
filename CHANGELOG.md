## Version History

#### 20140225
* Add JRuby 1.7.11
* Add support for JRuby 9000 bundled with the Graal VM

#### 20140224.1
* Add Ruby 2.0.0-p451
* Add Ruby 2.1.1

#### 20140224
* Add Ruby 1.9.3-p545
* Add mruby 1.0.0
* Improve Java 7 detection

#### 20140214
* Install libyaml 0.1.5 for Ruby 2.x
* Require Java 7 for jruby-9000-dev
* Update MagLev branch from master-1.9 to master

#### 20140210
* Add Rubinius 2.2.4
* Add JRuby 9000-dev

#### 20140204
* Add Rubinius 2.2.4
* Update libyaml to version 0.1.5

Note: If Psych::LIBYAML_VERSION < '0.1.5' you should update and rebuild Ruby.
For more informaton see CVE-2013-6393.

#### 20140110.1
* Fix bug in JRuby 1.7.10 definition

#### 20140110
* Add JRuby 1.7.10
* Add Rubinius 2.2.2
* Add Rubinius 2.2.3

#### 20131225.1
* Fix typos in Ruby 2.1.0, 2.1.0-dev, and 2.2.0-dev definitions

#### 20131225
* Add Ruby 1.8.7-p375
* Add Ruby 1.9.2-p326
* Update Ruby 2.1.0-dev git branch
* Add Ruby 2.1.0
* Add Ruby 2.2.0-dev

#### 20131220.1
* Fix JRuby installation on non-BSD systems

#### 20131220
* Transform JRuby shebangs to absolute paths, fixing edge-case recursion in rbenv
* Add `--patch` command-line option to patch Ruby from stdin before building
* Add Ruby 2.1.0-rc1

#### 20131211
* Fix extracting topaz-dev archive
* Auto-detect and link to Homebrew's readline
* Fix irb, rake, rdoc, ri for rbx-2.2.1

#### 20131206
* Add JRuby 1.7.9

#### 20131122.1
* Fix typo in 2.1.0-preview2 definition

#### 20131122
* Add Ruby 1.9.3-p484
* Add Ruby 2.0.0-p353
* Add Ruby 2.1.0-preview2
* Add Rubinius 2.2.0
* Add Rubinius 2.2.1

#### 20131115
* Add JRuby 1.7.7
* Add JRuby 1.7.8

#### 20131030
* Install the Rubinius bundle in isolation
* Fix false "BUILD FAILED" message when installing Rubinius
* Fix installing REE on OS X 10.8+ with no XQuartz

#### 20131028
* Abort early for invalid TMPDIR
* Enable compiling Ruby 1.8 on OS X 10.8+ without extra flags
* Detect number of CPU cores used for `make`
* Fix installing Ruby 2.1.0 from trunk
* Install Rake and Bundler in isolation when required
* Clearer error message when HTTP download fails
* Set default MAKE=gmake on FreeBSD
* Support relative path as install prefix
* Use libyaml from Homebrew if available

#### 20131024
* Add JRuby 1.7.6
* Add Rubinius 2.1.0
* Add Rubinius 2.1.1

#### 20131008
* Add JRuby 1.7.5
* Add Rubinius 2.0.0

#### 20130923
* Add Ruby 2.1.0-preview1

#### 20130907
* Revert using mirror site

#### 20130901
* Use www.dnsbalance.ring.gr.jp
* Do not set the Rubinius gems directory to the prefix

#### 20130806
* Change protocol of the ruby-lang.org server from HTTP to FTP

#### 20130628
* Add Ruby 2.0.0-p247
* Add Ruby 1.9.3-p448
* Add Ruby 1.8.7-p374
* Add MagLev 2.0.0-dev from git
* Use Homebrew openssl if available

#### 20130518
* Add JRuby 1.7.4

#### 20130514
* Add Ruby 2.0.0-p195
* Add Ruby 1.9.3-p429
* Add Ruby 1.9.2-p0
* Add Ruby 1.9.1-p430

#### 20130501
* Cache git clone directory
* Restore -O3 default when building with clang
* Build REE --without-tk on Darwin if X11 is missing
* Pass $RUBY_CONFIGURE_OPTS to REE installer with -c
* Default RBENV_VERSION to the globally-specified Ruby

#### 20130408
* Add mruby-dev
* Add topaz-dev :gem:
* List matching definitions on ambiguous version specification
* Use `--continue` when downloading tarball
* Keep source tarball if `--keep` or `tar xf` fails

#### 20130227
* Default Ruby CFLAGS to `-Wno-error=shorten-64-to-32`; don't set `CC`
* Upgrades rubygems for 1.9.1: 1.3.5 -> 1.3.7

#### 20130226
* Build a shared openssl to link to Ruby 2.0.0

#### 20130225
* Add Ruby 2.1.0-dev
* Rename the CAfile to cert.pem
* Fix exit status of install with verbose

#### 20130224
* Happy 20th :birthday:, Ruby!
* Add Ruby 2.0.0-p0
* Autoclean on unsuccessful installation

#### 20130222
* Upgrade to OpenSSL 1.0.1e
* Add JRuby 1.7.3
* Add Ruby 1.9.3-p392

#### 20130208
* Add Ruby 2.0.0-rc2
* Build OpenSSL for Ruby 2.0 on OS X

#### 20130206
* Add Ruby 1.9.3-p385

#### 20130129
* Change `rbenv install` to attempt to install the local app-specific
  version when it is invoked without any arguments
* Add interactive confirmation to `rbenv install` when the destination prefix
  exists. Pass `-f` or `--force` to force installation of versions that are
  already installed
* Add support for specifying which program to use for `make` via the `$MAKE`
  environment variable. FreeBSD users can now instruct ruby-build to use GNU
  make by setting `MAKE=gmake`
* Modify the post-install process to invoke `chmod` only for group- or
  world-writable directories
* Add `before_install` and `after_install` hooks for `rbenv install` plugins to
  facilitate post-installation automation

#### 20130118
* Add Ruby 2.0.0-rc1
* Add Ruby 1.9.3-p374

#### 20130104
* Add JRuby 1.7.2

#### 20121227
* Add Ruby 1.9.3-p362
* Add Ruby 1.8.7-p371
* Move the default ruby-build mirror from GitHub Downloads to Amazon CloudFront

#### 20121204
* Add JRuby 1.7.1

#### 20121201
* Add Ruby 2.0.0-preview2

#### 20121120
* Add optional package checksum support. When a package URL is annotated with
  an MD5 checksum, ruby-build will use it to verify the contents of the
  downloaded file. Package URLs in all existing definitions have been updated
  with checksum annotations
* Add an optional package download cache. When the `RUBY_BUILD_CACHE_PATH`
  environment variable is set to a directory of your choice, ruby-build will
  store downloaded packages there and reuse them for future installations
* Add mirror support for faster package downloads. Packages on the official
  ruby-build mirror will be served via S3. You can point ruby-build to your own
  local package mirror by setting the `RUBY_BUILD_MIRROR_URL` environment
  variable

#### 20121110
* Add Ruby 1.9.3-p327
* Fetch Ruby 2.0.0.dev and 1.9.3.dev via Git instead of Subversion

#### 20121104
* Add Ruby 2.0.0-preview1
* Add Rubinius 2.0.0-rc1

#### 20121022
* Add JRuby 1.7.0

#### 20121020

* Add Ruby 1.9.3-p286
* Add JRuby 1.7.0-rc2
* Add JRuby 1.7.0-rc1
* Add JRuby 1.6.8
* Add JRuby 1.5.6
* Fetch Ruby 2.0.0.dev via Subversion instead of Git
* Allow hooks to be defined for `rbenv-install`

#### 20120815

* Add MagLev 1.1.0-dev from git
* Add Ruby 1.8.7-p370 (for those having trouble
  installing 1.8.7 with newer versions of glibc, please see
  https://github.com/sstephenson/ruby-build/pull/195#issuecomment-7743664)
* Update the package URL in the definition for JRuby 1.7.0-preview1
* Add JRuby 1.7.0-preview2
* Update the Rubinius 2.0.0-dev definition to use the bundled RubyGems version
  instead of installing its own
* Add an `rbenv uninstall` command for removing installed versions
* Improved the option parsing for `ruby-build` and `rbenv-install` so
  options may be placed in any order, and short options may be
  combined (e.g. `-kv`)
* Add a `-l`/`--list` option to `rbenv install` to list all available
  definitions
* Add a `-v`/`--verbose` option to `rbenv install` to invoke `ruby-build` in
  verbose mode
* Documented the `-k`/`--keep` flag in the command-line help for
  `ruby-build` and `rbenv install`

#### 20120524

* Add JRuby 1.6.7.2 and 1.7.0-preview1
* Removed the definition for JRuby 1.7.0-dev (in general we do not
  like to remove definitions, but the JRuby team has deleted the
  1.7.0-dev package from their servers -- caveat emptor)
* Added support for specifying the build location with the
  `RUBY_BUILD_BUILD_PATH` environment variable
* Add a `-k`/`--keep` flag to `ruby-build` and `rbenv install` for
  keeping the source code around after installation
* Update the README to emphasize installation as an rbenv plugin

#### 20120423

* Improved error messages when dependencies are missing
* XCode 4.3+ may be used to build 1.9.3-p125 and later
* Update all Ruby 1.9.2 and 1.9.3 definitions to RubyGems 1.8.23
* Add REE 1.8.7-2012.02 and 1.8.7-2009.10
* Add JRuby 1.6.7
* Add Ruby 1.9.2-p318, 1.9.2-p320, and 1.9.3-p194

#### 20120216

* Add REE 1.8.7-2011.12 and 1.8.7-2012.01
* Add JRuby 1.6.5.1 and 1.6.6
* Add Ruby 1.8.7-p358 and 1.9.3-p125
* Update the README with instructions for installing ruby-build as an rbenv
  plugin

#### 20111230

* Add MagLev 1.0.0
* Added support for overriding `make` options with the
  `$MAKEOPTS`/`$MAKE_OPTS` environment variable
* Removed RubyGems installations from JRuby definitions in favor of
  the bundled RubyGems versions
* Add a `before_install_package` hook
* Add REE 1.8.7-2009.09 and 1.8.7-2010.01
* Add Ruby 1.8.6-p383, 1.8.7-p302 and 1.8.7-p357
* Update the JRuby 1.7.0-dev snapshot URL
* Changed the GCC detector to look for `gcc-*` anywhere in the
  `$PATH`, not just `/usr/bin`

#### 20111030

* Add Ruby 1.8.7-p334
* Renamed the 1.9.4-dev definition to 2.0.0-dev to reflect the new
  version numbering scheme
* ruby-build now automatically displays the last 10 lines of the error
  log, if any, when a build fails
* Improve the GCC detection routines and add a more helpful error message for
  Xcode 4.2 users
* JRuby installation no longer requires the install prefix to exist
  first
* You can now pass `$CONFIGURE_OPTS` to the REE definitions
* Add JRuby 1.6.5
* Add Ruby 1.9.2-p180
* Add Ruby 1.9.3-p0

#### 20110928

* ruby-build now uses the `--with-gcc` configure flag on OS X Lion
* Add REE 1.8.7-2010.02 and 1.8.6-2009.06
* Modified `rbenv-install` to run `rbenv rehash` after installation
* Add Ruby 1.9.3-rc1
* Update the JRuby defintions to install the `jruby-launcher` gem
* Update the Rubinius 2.0.0 definition to point to the master branch
* Add JRuby 1.7.0-dev
* Add Ruby 1.9.4-dev

#### 20110914

* Add Rubinius 2.0.0-dev for Rubinius 2.0.0 from git
* Added support for setting `./configure` options with the
  `CONFIGURE_OPTS` environment variable
* Add Ruby 1.9.3-dev from git
* Add support for fetching package sources via git
* Add an `rbenv-install` script which provides an `install` command for rbenv users

#### 20110906.1

* Changed the REE definition not to install its default gem
  collection
* Reverted a poorly-tested change that intended to enable support for
  relative installation paths

#### 20110906

 * Initial public release
