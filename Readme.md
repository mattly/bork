# Bork, your Sweedish Chef Puppet

Bork puts the 'sh' back into IT. [Bork Bork
Bork](https://www.youtube.com/results?search_query=swedish+chef).

While you could technically call Bork a bash-based DSL for system configuration
managment, please don't. Bork might have to hurt you.

by Matthew Lyon <matthew@lyonheart.us>

## Bare Minimum Requirements

Bork should run on any modern UNIX system's base install. It requires bash and
some basic posix helpers.

You will also need a way to move files around. You can either scp them or have
curl installed already.

If you're using a modern unix variant and the base requirements are not met by
your distribution, we'd like to work with you to figure out how to bootstrap.

### Usage

    ./bork {config}

#### Config

A config is a bash script that uses bork's functions and helpers to describe the
state the system it's run on should be in. When ran, its **source** functions
do the heavy lifing of installing or updating components as needed.

Example:

``` bash
# setup for my mac-based dev environment
brew readline
brew openssl
brew git
brew ack
include pl/ruby                 # installs rbenv, ruby-build, various rubies
github mattly/dotfiles $HOME/code/dotfiles
brew vim
set_dir $HOME/code/dotfiles/vim/bundle
  github tpope/vim-pathogen     # installs to ....vim/bundle/vim-pathogen
  github altercation/vim-colors-solarized
unset_dir
```

#### Sources

A source is a shell function that, given arguments from the config, knows if
a given item needs to be installed, updated or removed. Example sources include:

- `brew`: Homebrew on MacOS X. A coming **pkg** will use this on OS X.
- `git`: A git repository at a location.
- `github`: A git repository on GitHub.
- `rbenv`: A version of ruby to install via [rbenv][].
- `nodenv`: A version of node.js to install via [nodenv][].
- more coming, including archive (with & without make support), url, etc.

##### Sources-Contrib

- `osx`: Modify system preferences in OS X

#### Helpers

- `include`: Includes by reference another config relative to the config's path.
- `set_dir`: Sets the default destination directory for sources.

## Why

You might ask, why not use [Chef][] or [Puppet][] instead? Good question.
They're existing mature tools for doing this kind of thing, with vibrant
communities. However after working with both, I wanted something dramatically
simpler and less opinionated.

Bork is a shell program. You run it how you want.

### Look At All The Things It's NOT Doing

To the degree Bork is opinionated, it is *very* opinionated about what it does
not want responsibility for:

- **Collaboration**: Use GitHub. Or Whatever.
- **Versioning**: Bring your own VCS.
- **Orchestration**: There are plenty of good tools that do this already.
  [Fabric][] and [Capistrano][] come immediately to mind.
- **Role Management**: Just include another config. Compose configs from
  sub-configs.
- **Dependency Management**: This should be outsourced to your package manager,
  then managed inline in your scripts. For example, the 'rbenv' package should
  be installed before calling an rbenv source. This is coding 101, people. It
  ain't that hard.

### Problems

- Will need a way to add to $PATH for things like nodenv that don't go to path.

## Roadmap

- source: pull from url or local file and install via make
- source: bootstrap homebrew
- config: ability to build a set of configs into a single one for easy transport
- config: group items into bundles (f.e. 'vim plugins')
- config: callbacks for items and groups (after: install, update)
- config: templates to setup
- runner: `--only {group}` flag

## License

Bork is copyright 2013 Matthew Lyon and licensed under the Apache 2.0 License.
Full text to come.

[rbenv]: https://github.com/sstephenson/rbenv
[nodenv]: https://github.com/OiNutter/nodenv
[Chef]: http://www.opscode.com/chef/
[Puppet]: http://puppetlabs.com/
[Fabric]: http://docs.fabfile.org/
[Capistrano]: http://capistranorb.com/
