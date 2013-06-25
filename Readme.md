# Bork, your Sweedish Chef Puppet

Bork puts the 'sh' back into IT. [Bork Bork
Bork](https://www.youtube.com/results?search_query=swedish+chef).

While you could technically call Bork a bash-based DSL for system configuration
managment, please don't.

by Matthew Lyon <matthew@lyonheart.us>

## Bare Minimum Requirements

Bork should run on any modern UNIX system's base install. It requires:

- bash
- grep
- sed
- awk

You will also need a way to move files around. You can either scp them or have
curl installed already.

If you're using a modern unix variant and the base requirements are not met by
your distribution, we'd like to work with you to figure out how to bootstrap

### Usage

    ./{runner} {config}

## Concepts

Bork takes **config** scripts and runs them via a **runner**. The config scripts
describe a setup (i.e., install git, postgresql, etc) and the runner provides
functions for interpreting the config's directives.

### Runner

The runner is responsible for knowing about **sources** which the config can
provide from.

#### Sources

A source is a shell function that, given arguments from the config, knows if
a given item needs to be installed, updated or removed. Example sources include:

- **brew**: Homebrew on MacOS X. A coming **pkg** will use this on OS X.
- **github**: A git repository on GitHub. A coming **git** will pull from
  anywhere.
- **rbenv**: A version of ruby to install via [rbenv][].
- **nodenv**: A version of node.js to install via [nodenv][].
- more coming, including archive (with & without make support), url, etc.

### Config

A config describes a set of **items** to pull from various **sources**. It is
a bash script that is executed by the runner.

## Why

You might ask, why not use [Chef][] or [Puppet][] instead? Good question.
They're existing mature tools for doing this kind of thing, with vibrant
communities. However, after working with both, I wanted something dramatically
simpler. Both of these tools are architected primarily around commercial use.
Both are responsible for managing roles across large groups of machines. Both
have a lot of concepts to wrap your head around before you can get started. Both
require a fair amount of setup on a machine before you can actually use them.

Bork is a shell script. Excuse me, a shell **program**. You run it how you want.

### Look At All The Things It's **NOT** Doing

To the degree Bork is opinionated, it is *very* opinionated about what it does
not want responsibility for:

- **Collaboration**: Use GitHub. Or Whatever.
- **Versioning**: Bring your own VCS.
- **Orchestration**: There are plenty of good tools that do this already.
  [Fabric][] and [Capistrano][] come immediately to mind.
- **Role Management**: Just include and/or source another config.
- **Dependency Management**: This should be outsourced to your package manager,
  then managed inline in your scripts. For example, the 'rbenv' package should
  be installed before calling an rbenv source. This is coding 101.

### Problems

- Will likely need a way to rehash after things are installed.
- Will need a way to add to $PATH for things like nodenv that don't go to path.

## Roadmap

- source: pull from url or local file and install via make
- config: clean way to include other config scripts
- config: ability to build a set of configs into a single one for easy transport
- config: group items into bundles (f.e. 'vim plugins')
- config: callbacks for items and groups (after: install, update)
- config: templates to setup
- runner: implement update
- runner: `--no-update` flag
- runner: `--only {group, pkg}` flag

## License

Bork is copyright 2013 Matthew Lyon and licensed under the Apache 2.0 License.
Full text to come.

[rbenv]: https://github.com/sstephenson/rbenv
[nodenv]: https://github.com/OiNutter/nodenv
[Chef]: http://www.opscode.com/chef/
[Puppet]: http://puppetlabs.com/
[Fabric]: http://docs.fabfile.org/
[Capistrano]: http://capistranorb.com/
