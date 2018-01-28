# Bork [![](https://travis-ci.org/mattly/bork.svg)](https://travis-ci.org/mattly/bork)

Bork puts the 'sh' back into IT. [Bork Bork Bork](https://www.youtube.com/results?search_query=swedish+chef).

## the Swedish Chef Puppet of Config Management

Bork is a bash DSL for making declarative assertions about the state of a system.

Bork is written against Bash 3.2 and common unix utilities such as sed, awk and
grep. It is designed to work on any UNIX-based system and maintain awareness of
platform differences between BSD and GPL versions of unix utilities.

# Installation

## From source

1. Clone this repository:
  `git clone https://github.com/mattly/bork /usr/local/src/bork`

1. Symlink the bork binaries into your `$PATH`:
```bash
  ln -sf /usr/local/src/bork/bin/bork /usr/local/bin/bork
```

## via Homebrew (Mac OS X)

1. Install via Homebrew:
  `brew install bork`

# Usage and Operations

Running bork without arguments will output some help:

```
bork usage:

bork operation [config-file] [options]

where "operation" is one of:

- check:      perform 'status' for a single command
    example:  bork check ok github mattly/dotfiles
- compile:    compile the config file to a self-contained script output to STDOUT
    --conflicts=(y|yes|n|no)  If given, sets an automatic answer for conflict resolution.
    example:  bork compile dotfiles.sh --conflicts=y > install.sh
- do:         perform 'satisfy' for a single command
    example:  bork do ok github mattly/dotfiles
- satisfy:    satisfy the config file's conditions if possible
- status:     determine if the config file's conditions are met
- types:      list types and their usage information
```

Let's explore these in more depth:

## Assertions and Config Files

At the heart of bork is making **assertions** in a **declarative** manner via
the `ok` function. That is, you tell it *what* you want the system to look like
instead of *how* to make it look like that. An assertion takes a **type** and a
number of arguments. It invokes the type's handler function with an *action*
such as `status`, `install`, or `upgrade`, which determines the imperative
commands needed to test the assertion or bring it up to date. There are a number
of included types in the `types` directory, and bork makes it easy to create
your own.

Here's a basic example:

```bash
ok brew                                       # presence and updatedness of Homebrew
ok brew git                                   # presence and updatedness of Homebrew git package
ok directory $HOME/code                       # presence of the ~/code directory
ok github $HOME/code/dotfiles mattly/dotfiles # presence, drift of git repository in ~/code/dotfiles
cd $HOME
for file in $HOME/code/dotfiles/configs/*
do                                            # for each file in ~/code/dotfiles/configs,
  ok symlink ".$(basename $file)" $file       # presense of a symlink to file in ~ with a leading dot
done
```

When run, bork will test each `ok` assertion and determine if it's met or not.
If not, bork can go ahead and *satisfy* the assertion by installing, upgrading, or
altering the configuration of the item to match the assertion. It will then test
the assertion again. Declarations are idempotent -- if the assertion is already
met, bork will not do anything.

When you're happy with your config script, you can compile it to a standalone
script which does not require bork to run. The compiled script can be passed
around via curl, scp or the like and run on completely new systems.

## Assertion Types

You can run `bork types` from the command line to get a list of the assertion types
and some basic information about their usage and options.

### Generic assertions
```
          check: runs a given command.  OK if returns 0, FAILED otherwise.
```

### File System
```
      directory: asserts presence of a directory
           file: asserts the presence, checksum, owner and permissions of a file
       download: asserts the presence of a file compared to an http(s) url
        symlink: assert presence and target of a symlink
```

### Source Control
```
            git: asserts presence and state of a git repository
         github: front-end for git type, uses github urls
```

### Language Package Managers
```
            gem: asserts the presence of a gem in the environment's ruby
            npm: asserts the presence of a nodejs module in npm's global installation
            pip: asserts presence of packages installed via pip
          pipsi: asserts presence of pipsi or packages installed via pipsi
            apm: asserts the presence of an atom package
         go-get: asserts the presence of a go package
```

### Mac OS X specific
```
           brew: asserts presence of packages installed via Homebrew on Mac OS X
       brew-tap: asserts a Homebrew formula repository has been tapped; does NOT assert updatedness of a tap's formula. Use `ok brew` for that.
           cask: asserts presence of apps installed via caskroom.io on Mac OS X
       defaults: asserts settings for OS X's 'defaults' system
            mas: asserts a Mac app is installed and up-to-date from the App Store
                 via the 'mas' utility https://github.com/argon/mas
         scutil: verifies OS X machine name with scutil
```

### Linux specific:
```
            apt: asserts packages installed via apt-get on Debian or Ubuntu Linux
            yum: asserts packages installed via yum on CentOS or RedHat Linux
         zypper: asserts packages installed via zypper (SUSE)
```

### User management (currently Linux-only)
```
          group: asserts presence of a unix group (Linux only, for now)
           user: assert presence of a user on the system
```

### UNIX utilities
```
       iptables: asserts presence of iptables rule
```

## Runtime Operations

Per the usage guide, bork has a few main modes of operation:

- `status`: Reports on the status of the assertions in a config file.
- `satisfy`: Checks the status of assertions in a config file, satisfying them
  where needed.
- `compile`: Compiles a config file to a standalone script.
- `check`: Performs a status report on a single assertion.
- `do`: Performs a satisfy operation on a single assertion.

### bork status myconfig.sh

The `status` command will confirm that assertions are met or not, and output
their status. It will not take any action to satisfy those assertions. There are
a handful of statuses an assertion can return, and this since this mode is the
closest bork can do to a true `dry run`(*) you can use it to test a script
against a pre-existing machine.

* Some types, such as `git`, need to modify local state by talking to the network
(such as performing `git fetch`), without modifying the things the assertion aims
to check.

The status command will give you output such as:

```
outdated: brew
ok: brew git
missing: brew fish
ok: directory /Users/mattly/code/mattly
conflict (upgradable): github mattly/dotfiles
local git repository has uncommitted changes
ok: symlink /Users/mattly/.gitignore /Users/mattly/code/mattly/dotfiles/configs/gitignore
conflict (clobber required): symlink /Users/mattly/.lein /Users/mattly/code/mattly/dotfiles/configs/lein
not a symlink: /Users/mattly/.lein
mismatch (upgradable): defaults com.apple.dock tilesize integer 36
expected type: integer
received type: float
expected value: 36
received value: 55
```

Each item reports its status like so:

- `ok`: The assertion is met as best we can determine.
- `missing`: The assertion is not met, and no trace of it ever being met was found.
- `outdated`: The assertion is met, but can be upgraded to a newer version.
- `mismatch (upgradable)`: The assertion is not met as specified, something is
  different. It can be satisfied easily. An explanation will be given.
- `conflict (upgradable)`: The assertion is not met as specified. It can be
  satisfied easily, but doing so may result in data loss.
- `conflict (clobber required)`: The assertion is not met as specified. Bork
  cannot currently satisfy this assertion. In the future, it will be able to,
  but doing so may result in data loss.

### bork check ok github mattly/dotfiles

The `check` command will take a single assertion on the command line and perform
a `status` check as above for it.

### bork satisfy myconfig.sh

The `satisfy` command is where the real magic happens. For every assertion in
the config file, bork will check its status as described in the `status` command
above, and if it is not `ok` it will attempt to make it `ok`, typically via
*installing* or *upgrading* something -- but sometimes a *conflict* is detected
which could lose data, such as a local git repository having uncommitted
changes. In that case, bork will warn you about the problem and ask if you want
to proceed. Sometimes conflicts are detected which bork does not know how to
resolve — it will warn you about the problem so you can fix it yourself.

### bork do ok github mattly/dotfiles

The `do` command will take a single assertion on the command line and perform a
`satisfy` operation on it as above.

### bork compile myconfig.sh

The `compile` command will output to STDOUT a standalone shell script that does
not require bork to run. You may pass this around as with any file via curl or
scp or whatever you like and run it. Any sub-configs via `include` will be
included in the output, and any type that needs to include resources to do what
it does, such as the `file` type, will include their resources in the script as
base64 encoded data.

### Custom Types

Writing new types is pretty straightforward, and there is a guide to writing
them in the `docs/` directory. If you wish to use a type that is not in bork's
`types` directory, you can let bork know about it with the `register`
declaration:

```bash
register etc/pgdb.sh
ok pgdb my_app_db
```

### Composing Config Files

You may compose config files into greater operations with the `include`
directive with a path to a script relative to the current script's directory.

```bash
# this is main.sh
include databases.sh
include etc/projects.sh
```

```bash
# this is etc/projects.sh
include project-one.sh
include project-two.sh
# these will be read from the etc/ directory
```

### Taking Further Action on Changes

Bork doesn't have callbacks per-se, but after each assertion there are a handful
of functions you can call to take further action:

```bash
ok brew fish
if did_install; then
  sudo echo "/usr/local/bin/fish" >> /etc/shells
  chsh -s /usr/local/bin/fish
end
```
There are four functions to help you take further actions on change:

- `did_install`: did the previous assertion result in the item being installed
  from scratch?
- `did_upgrade`: did the previous assertion result in the existing item being
  upgraded?
- `did_update`: did the previous assertion result in either the item being
  installed or upgraded?
- `did_error`: did attempting to install or upgrade the previous assertion
  result in an error?

## Contributing

1. Fork it
2. Create your feature branch: `git checkout -b feature/my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin feature/my-new-feature`
5. Submit a pull request

### Contribution Guidelines

1. Prefer clarity of intent over brevity. Bash can be an obtuse language, but it
   doesn't *have* to be. Many people have said bork has some of the clearest
   bash code they've ever seen, and that's a standard to strive for.

2. Favor helper abstractions over arbitrary platform-specific checks. See
   [`md5cmd`](lib/helpers/md5cmd.sh), [`http`](lib/helpers/http.sh), and
   [`permission_cmd`](lib/helpers/permission_cmd.sh), and look at how they're
   used.

3. Types are independent, stateless, and atomic. Do not attempt to maintain a
   cache in a type file unless you're talking to the network. An assertion is
   the *whole* of the assertion — don't attempt to create a multi-stage
   assertion type that depends on maintaining state. Find a way to express the
   whole of the assertion in one go.

4. Leave Dependency Management to the user. Is a needed binary not installed for
   a type? Return `$STATUS_FAILED_PRECONDITION` in your status check. Let the
   user decide the best way to satisfy any dependencies.

## Community

Feel free to join us in IRC:

- Hostname: `irc.freenode.org`
- Channel: `#bork.sh`
- [Web IRC client in case you don't have a native one](https://kiwiirc.com/client/irc.freenode.net/bork.sh)

## Requirements / Dependencies

* Bash 3.2

## Version

0.10.0

## License

[Apache License 2.0](LICENSE)
