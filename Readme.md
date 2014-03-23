# Bork, your Sweedish Chef Puppet

Bork puts the 'sh' back into IT. [Bork Bork
Bork](https://www.youtube.com/results?search_query=swedish+chef).

Bork is a bash-based DSL for system configuration management.  Its goal is to
provide a zero-dependency solution for making assertions about the state of
a system and when needed, truthing them.

by Matthew Lyon <matthew@lyonheart.us>

## Bare Minimum Requirements

Bork is written against Bash 3.2. It may not perfectly run there yet, and that's
where you come in :) The goal is to run out-of-box on any modern UNIX system,
whcih should (hopefully) include sed, awk and grep.

If you're going to use it, you'll presumably need a way to copy files to your
target machine, such as scp or curl.

## Why

You might ask, why not use [Chef][] or [Puppet][] instead? Good question.
They're existing mature tools for doing this kind of thing, with vibrant
communities. However after working with both, I wanted something dramatically
simpler and less opinionated.

Bork is a shell program. You run it how you want.

## Concepts

### Configs

A config is a bash script that is run under a bork "harness" that makes
assertions about the state of a system. A basic config would look like this:

``` bash
use brew git github           # pulls these assertions out of stdlib into use
ok git                        # asserts system pkg manager has git package installed
directories ~/code            # asserts ~/code exists
destination push ~/code       # uses the "destination stack" to change the 'working' directory
ok github mattly/dotfiles     # asserts code from git@github.com:mattly/dotfiles 
                              #   exists in ~/code/dotfiles
pkg vim                       # asserts system pkg manager has vim package installed
destination push vim/bundle
ok github tpope/vim-pathogen  # asserts pathogen installed from github
github shougo/vimproc         # asserts vimproc installed from github
if did_update; then           # if vimproc was installed or updated, then re-run make
  (cd vimproc && make clean && make)
fi
```

This config could be tested by bork with `bork status vim.sh` or satisfied with
`bork satisfy vim.sh`. In the future, I'd like to provide a 'compile' option to
generate a single, portable shell script.

### Assertions

An assertion is basically something like:
- "this package should be installed"
- "this directory should exist"
- "these files should exist from somewhere else on the internet"
- "this file should be symlinked to somewhere else or have these permissions"

Use your imagination. Look in `core/` and `stdlib/` and see the existing ones:

* `pkg:` a pass-through to the system package manager. 
* `brew`: homebrew, used by the above
* `apt`: apt, used by pkg
* `git`: code from a git repository
* `github`: like previously, but with a github url pattern
* `directories`: that certain directories exist
* `symlink`: that certain files are symlinked elsewhere

More assertion types are planned:

* other package managers: apt, yum, etc.
* VCS managers: hg, darcs
* PL package managers: npm, rubygems, pip, cabal, etc. Note that bork is
  intended for global installation of these packages, not per-project; tools
  like Bundler or package.json are more appropriate for project-level assertions.
* Cron jobs, init.d files, launchctl tasks, etc
* Files exist with certain text, and some kind of template renderer
* OS X settings via defaults

### Look At All The Things It's NOT Doing

To the degree Bork is opinionated, it is *very* opinionated about what it does
not want responsibility for:

- **Collaboration**: Use GitHub. Or Whatever.
- **Versioning**: Bring your own VCS. Git, Mercurial, Darcs, CVS or whatever.
- **Orchestration**: There are plenty of good tools that do this already.
  [Fabric][] and [Capistrano][] come immediately to mind.
- **Role Management**: Just include another config. Compose configs from
  sub-configs.
- **Hardcore Dependency Management**: This should be outsourced to your package
  manager, then managed inline in your scripts. For example, the 'rbenv'
  package should be installed before calling an rbenv source. This is coding
  101, people. It ain't that hard.

## License

Bork is copyright 2013 Matthew Lyon and licensed under the MIT License. See
LICENSE for more information.

[rbenv]: https://github.com/sstephenson/rbenv
[nodenv]: https://github.com/OiNutter/nodenv
[Chef]: http://www.opscode.com/chef/
[Puppet]: http://puppetlabs.com/
[Fabric]: http://docs.fabfile.org/
[Capistrano]: http://capistranorb.com/
