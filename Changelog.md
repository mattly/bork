# Change Log
All notable changes to this project will be documented in this file, from 2016-03-24 going forward. This project adheres to [Semantic Versioning](http://semver.org/). 

## [0.10.0]

### Added

- `bag` helper: added `print` command to echo each item as a line
- `git` type: added an option to explicitly set the destination. These are equivalent:

    ```bash
    cd ~/code; ok git git@somewhere.com:/me/someproject.git
    ok git ~/code/someproject git@somewhere.com:/me/someproject.git
    ```
    
    I am inclined to deprecate the original implicit version, and welcome feedback about this.

- `github` type: made to work with explicit destination option for `git` above.
- `github` type: added `-ssh` option to specify `git@github.com:` style urls.
- new `apm` type for managing packages for the [Atom](https://atom.io) text editor. Thanks [@frdmn][]
- `npm` type: Tests!
- `npm` type: Added outdated/upgrade support.
- `Readme.md`: Added installation instructions, moved some sections around. Thanks [@frdmn][]
- `Changelog.md`: moved from `History.md`, improved organization.

### Deprecated

- `destination` declaration is now a proxy for unix `cd`, and will emit to STDERR a message stating it will be removed in the future.
  
### Removed

- `ok` declaration no longer runs commands from the set `destination`; it will run them from the current directory.

### Fixed

- `dict` type: fix handling for `dict` entries.
- `dict` type: alias `int` type to `integer`.
- `symlink` type: properly quote target in status checks.
- `npm` type: Some versions of the `npm` executable have a bug preventing `--depth 0` and `--parseable` from working together. We work around this by using only `--depth 0` and parsing that output manually.
- `file` type: during `compile` operation, if file is missing, will halt the compile and emit an error to STDERR.

## [0.9.1] — 2016-03-25

### Fixed

- Fix a regression introduced in fd49cab that assumed the bork script path (passed on the command line) was relative. Thanks @frdmn

## [0.9] – 2016-03-24

Initial tagged release, prompted by getting bork into homebrew. Conversely, about three years after I started working on this project.

[@frdmn]: https://github.com/frdmn
