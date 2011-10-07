# ruby-build

ruby-build provides a simple way to compile and install different
versions of Ruby on UNIX-like systems.

### Installing ruby-build

ruby-build depends on curl to download binaries. This ships with OSX. If you are using ubuntu install it with `apt-get install curl`.

    $ git clone git://github.com/sstephenson/ruby-build.git
    $ cd ruby-build
    $ ./install.sh

This will install ruby-build into `/usr/local`. If you do not have
write permission to `/usr/local`, you will need to run `sudo
./install.sh` instead. You can install to a different prefix by
setting the `PREFIX` environment variable.

### Installing Ruby

To install a Ruby version, run the `ruby-build` command with the path
to a definition file and the path where you want to install it. (A
number of [built-in
definitions](https://github.com/sstephenson/ruby-build/tree/master/share/ruby-build)
may be specified instead.)

    $ ruby-build 1.9.2-p290 ~/local/ruby-1.9.2-p290
    ...
    $ ~/local/ruby-1.9.2-p290/bin/ruby --version
    ruby 1.9.2p290 (2011-07-09 revision 32553) [x86_64-darwin11.0.0]

You can use it with [rbenv](https://github.com/sstephenson/rbenv):

    $ ruby-build 1.9.2-p290 ~/.rbenv/versions/1.9.2-p290

ruby-build provides an `rbenv-install` command that shortens this to:

    $ rbenv install 1.9.2-p290

### Version History

#### 20110928

* ruby-build now uses the `--with-gcc` configure flag on OS X Lion.
* Added definitions for REE 1.8.7-2010.02 and 1.8.6-2009.06.
* Modified `rbenv-install` to run `rbenv rehash` after installation.
* Added a Ruby 1.9.3-rc1 definition.
* Updated the JRuby defintions to install the `jruby-launcher` gem.
* Updated the rbx-2.0.0 definition to point to the master branch.
* Added a jruby-1.7.0-dev definition.
* Added a Ruby 1.9.4-dev definition.

#### 20110914

* Added an rbx-2.0.0-dev definition for Rubinius 2.0.0 from git.
* Added support for setting `./configure` options with the
  `CONFIGURE_OPTS` environment variable.
* Added a 1.9.3-dev definition for Ruby 1.9.3 from Git.
* Added support for fetching package sources via Git.
* Added an `rbenv-install` script which provides an `install` command
  for rbenv users.

#### 20110906.1

* Changed the REE definition not to install its default gem
  collection.
* Reverted a poorly-tested change that intended to enable support for
  relative installation paths.

#### 20110906

 * Initial public release.

### License

(The MIT License)

Copyright (c) 2011 Sam Stephenson

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
