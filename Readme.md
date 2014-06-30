# Bork

Bork puts the 'sh' back into IT. [Bork Bork Bork](https://www.youtube.com/results?search_query=swedish+chef).

## a Sweedish Chef Puppet

Bork is a bash-based DSL for making assertions about the state of a system.  

Bork was born out of frustrations with using tools like [Chef][] and [Puppet][] (or puppet-based [Boxen][]) for config management.  It aims to do one thing well: config management.  It does not on its own perform orchestration, role management, collaboration or versioning tools, or dependency management.  You *could* hack together an orchestration system on top of bork (if you think about orchestration in terms of making assertions), but on its own, bork knows nothing about that.  I use bork to setup my development machines, my vagrant images, my production servers, and manage my vim plugins.

Bork is written against Bash 3.2 and common unix utilities such as sed, awk and grep.  It is designed to work on any UNIX-based system, and be aware of platform differences between BSD and GPL versions of unix utilities.

[Chef]: http://www.opscode.com/chef/
[Puppet]: http://puppetlabs.com/
[Boxen]: https://boxen.github.com/

## Config Scripts

A Bork config is a bash script that bork runs.  Here's a basic example:

```bash
ok brew                         # presence, updated-ness of homebrew
ok brew git                     # presence, updated-ness of git homebrew package
ok directory $HOME/code         # presence of the ~/code directory
destination $HOME/code          # following command targets ~/code
ok github mattly/dotfiles       # presence, status of code in ~/code/dotfiles
                                #   matching git repository at 
                                #   https://github.com/mattly/dotfiles

destination $HOME               # following command targets $HOME
for file in $HOME/code/dotfiles/configs/*; do
  ok symlink ".$(basename $file)" $file             
                                # presence of symlink in $HOME for each file in
done                            #   ~/code/dotfiles/configs with a leading dot

destination $HOME/code/dotfiles/vim/bundle
ok github tpope/vim-pathogen    # presence, status of pathogen
ok github shougo/vimproc        # presence, status of vimproc
if did_update; then             # if vimproc is installed or updated, re-make it
  (cd vimproc && make clean && make)
fi
```

If this were 'setup.sh', you could check the status of these assertions with `bork status setup.sh`, or perform them `bork satisfy setup.sh`.  You can compile them into a standalone script with `bork compile setup.sh > install.sh`, and put that file on another machine without bork installed on it and it would perform the `satisfy` operation with `./install.sh` or check its status with `./install.sh status`.

The declaration `ok` tells bork that the following type and arguments should be present.  Bork makes no assumptions about things you don't tell it about -- so if for example the homebrew package "emacs" was installed manually, bork won't complain, and this is by design.  Eventually bork will have a negative declaration to assert the absence of something and remove it if desired.

## Assertion Types

You can run `bork types` to get a list of the assertion types, and some basic info about their usage and options.  Here's an overview:

### General:
- `gem`: presence of a ruby gem installed via `gem`
- `git`: presence and updatedness of a cloned git repository
- `github`: front-end for git that uses github URLs
- `pip`: presence of a python package installed via `pip`

### Mac OS X:
- `brew`: presence of a package installed via homebrew, or homebrew itself.
- `cask`: presence of an app installed via caskroom.io.
- `defaults`: settings for the OS X defaults system.

### Linux:
- `apt`: presence & updatedness of a package installed via `apt-get`.

### Unix:
- `group`: presence of a user group
- `iptables`: presence of an iptables rule
- `user`: presence, shell, group memberships of a user account

### File System:
- `directory`: presence of a directory
- `file`: presence, contents, owner and permissions of a file
- `symlink`: presence and target of a symlink

Writing new types is pretty straightforward, and there is a guide to writing them in the `docs/` directory.  There is a hitlist of new types in `todo.markdown` and features for existing types in the comments at the top of their scripts.
