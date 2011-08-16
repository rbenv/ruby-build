# ruby-build

ruby-build provides a simple way to compile and install different
versions of Ruby on UNIX-like systems.

### Installing ruby-build

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
