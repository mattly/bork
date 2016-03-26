# Bork [![](https://travis-ci.org/mattly/bork.svg)](https://travis-ci.org/mattly/bork)

Bork puts the 'sh' back into IT. [Bork Bork Bork](https://www.youtube.com/results?search_query=swedish+chef).

### the Swedish Chef Puppet of Config Management

Bork is a bash DSL for making declarative assertions about the state of a system.  Here's a basic example:

```bash
ok brew                                         # tests presence and updatedness of homebrew
ok brew git                                     # tests presence and updatedness of homebrew git package
ok directory $HOME/code                         # tests presence of the ~/code directory
cd $HOME/code
ok github mattly/dotfiles                       # tests presence, drift of git repository in ~/code/dotfiles
cd $HOME
for file in $HOME/code/dotfiles/configs/*; do   # for each file in ~/code/dotfiles/configs,
  ok symlink ".$(basename $file)" $file         # tests presense of a symlink to that file in ~ with a leading dot
done
```

When run, bork will test each `ok` assertion and determine if it's met or not.
If not, bork can go ahead and "truth" the assertion by installing, upgrading, or
altering the configuration of the item to match the assertion. It will then test
the assertion again. Declarations are idempotent -- if the assertion is already
met, bork will not do anything.

When you're happy with your config script, you can compile it to a standalone
script which does not require bork to run. The compiled script can be passed
around via curl, scp or the like and run on completely new systems.

Bork is written against Bash 3.2 and common unix utilities such as sed, awk and
grep. It is designed to work on any UNIX-based system and maintain awareness of
platform differences between BSD and GPL versions of unix utilities.

## Installation

### From source

1. Clone this repository:  
  `git clone https://github.com/mattly/bork /usr/local/src/bork`
1. Symlink the bork binaries into your `$PATH`:  
  `ln -sf /usr/local/src/bork/bin/bork /usr/local/bin/bork`  
  `ln -sf /usr/local/src/bork/bin/bork-compile /usr/local/bin/bork-compile`  

### via Homebrew (Mac OS X)

1. Install via Homebrew:  
  `brew install bork`

## Usage and Operations

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

### Included Types

You can run `bork types` from the command line to get a list of the assertion types
and some basic information about their usage and options. Here's that same output
from a recent version of bork, organized a bit:

#### Generic assertions
```
          check: runs a given command.  OK if returns 0, FAILED otherwise.
                 * check evalstr
                 > check "[ -d $HOME/.ssh/id_rsa ]"
                 > if check_failed; then ...
```

#### File System
```
      directory: asserts presence of a directory
                 > directories ~/.ssh
           file: asserts the presence, checksum, owner and permissions of a file
                 * file target-path source-path [arguments]
                 --permissions=755       permissions for the file
                 --owner=owner-name      owner name of the file
        symlink: assert presence and target of a symlink
                 > symlink .vimrc ~/code/dotfiles/configs/vimrc
```

#### Source Control
```
            git: asserts presence and state of a git repository
                 > git git@github.com:mattly/bork
                 --branch=gh-pages                (specify branch or tag)
         github: front-end for git type, uses github urls
                 > ok github mattly/bork
                 --branch=gh-pages        (specify branch or tag)
```

#### Language Package Managers
```
            gem: asserts the presence of a gem in the environment's ruby
                 > gem bundler
            npm: asserts the presence of a nodejs module in npm's global installation
                 > npm grunt-cli
            pip: asserts presence of packages installed via pip
                 > pip pygments
```

#### MacOS X specific
```
       brew-tap: asserts a homebrew forumla repository has been tapped
                 > brew-tap homebrew/games    (taps homebrew/games)
                 --pin                        (pins the formula repository)
           brew: asserts presence of packages installed via homebrew on mac os x
                 * brew                  (installs homebrew)
                 * brew package-name     (instals package)
                 --from=caskroom/cask    (source repository)
           cask: asserts presenece of apps installed via caskroom.io on Mac OS X
                 * cask app-name         (installs cask)
                 --appdir=/Applications  (changes symlink path)
       defaults: asserts settings for OS X's 'defaults' system
                 * defaults domain key type value
                 > defaults com.apple.dock autohide bool true
            mas: asserts a Mac app is installed and up-to-date from the App Store
                 via the 'mas' utility https://github.com/argon/mas
                 app id is required, can be obtained from 'mas' utility, name is optional
                 !WARNING! 'mas' will currently perform *all* pending upgrades when upgrading any app
                 > mas 497799835 Xcode    (installs/upgrades Xcode)
         scutil: Verifies OS X machine name with scutil
                 > scutil ComputerName bork
```

#### Linux specific:
```
            apt: asserts packages installed via apt-get on debian or ubuntu linux
                 * apt package-name
            yum: asserts packages installed via yum on CentOS or RedHat linux
                 * yum package-name
```

#### User management (currently Linux-only)
```
          group: asserts presence of a unix group (linux only, for now)
                 > group admin
           user: assert presence of a user on the system
                 > user admin
                 --shell=/bin/fish
                 --groups=admin,deploy
```

#### UNIX utilities
```
       iptables: asserts presence of iptables rule
                 NOTE: does not assert ordering of rules
                 > iptables INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
```

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
ok: defaults com.apple.dashboard mcx-disabled bool true
mismatch (upgradable): defaults com.apple.dock tilesize integer 36
expected type: integer
received type: float
expected value: 36
received value: 55
outdated: brew
ok: brew git
ok: directory /Users/mattly/code/mattly
conflict (upgradable): github mattly/dotfiles
local git repository has uncommitted changes
ok: symlink /Users/mattly/.gitignore /Users/mattly/code/mattly/dotfiles/configs/gitignore
conflict (clobber required): symlink /Users/mattly/.lein /Users/mattly/code/mattly/dotfiles/configs/lein
not a symlink: /Users/mattly/.lein
outdated: brew openssl
missing: brew hub
ok: brew tig
missing: brew fish
```

### bork check ok github mattly/dotfiles

The `check` command will take a single assertion on the command line and perform
a `status` check as above for it.

### bork satisfy myconfig.sh

The `satisfy` command is where the real magic happens. For every assertion in
the config file, bork will check its status as described in the `status` command
above, and if it is not `ok` it will attempt to make it `ok`, typically via
*installing* or *upgrading* something -- but sometimes a *clobber* is required
which could lose data, such as a local git repository having uncommitted
changes. In that case, bork will warn you about the problem and ask if you want
to proceed. Sometimes the assertion has a *conflict* that bork does not know how
to resolve: it will warn you about the problem so you can fix it yourself.

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

### Assertions and Config Files

At the heart of bork is making **assertions** in a **declarative** manner via
the `ok` function. That is, you tell it *what* you want done instead of *how* to
do it. An assertion takes a **type** and a number of arguments. It invokes the
type's handler function with an *action* such as `status`, `install`, or
`upgrade`, which determines the imperative commands needed to test the assertion
or bring it up to date. There are a number of included types in the `types`
directory, and bork makes it easy to create your own.

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

## Requirements / Dependencies

* Bash 3.2

## Version

0.9.1

## License

[Apache License 2.0](LICENSE)
