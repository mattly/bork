# Change Log
All notable changes to this project will be documented in this file, from 2016-03-24 going forward. This project adheres to [Semantic Versioning](http://semver.org/).

## [0.11.0] - 2018-01-27

Hey folks, sorry it's been a while! I started a new job not long after 0.10.0 was relased and then had my first child not long after that. I'm finally feeling a bit like I have some spare time. -- [@mattly][]

### Added
- new `--owner`, `--group`, and `--mode` flags for the `directory` type that do what you think they do. Thanks [@jitakirin][]
- `zypper` type for working with the SUSE package manager. Thanks [@jitakirin][]
- `pipsi` type for installing python packages to virtualenvs. Thanks [@jitakirin][]
- Reference to `#bork` freenode IRC channel in Readme.
- `go-get` type for asserting the presence of a go package. Thanks [@edrex][]
- Use `apm-beta` over `apm` if it is available. Thanks [@frdmn][]

### Improved
- Let homebrew itself tell us whether it is outdated. Thanks [@frdmn][]

### Fixed
- Use `npm install` to update npm packages, because `npm upgrade` could install things "newer" than the latest, causing an "outdated" status from bork. By [@mattly][]
- Don't check a user's shell if not requested. Thanks [@jitakirin][]
- Fix for removing an item from a bag value. Thanks [@ngkz][]
- Add version flag to `brew cask` check to bypass warning. Thanks [@rmhsilva][]
- Readme typo fix. Thanks [@indigo423][]
- force legacy listing format for PIP for conformative parsing. Thanks [@frdmn][]
- fix apt-status for outdated packages. Thanks [@dylanvaughn][]
- bypass homebrew not to auto-update itself when performing checks. Thanks [@frdmn][]
- the `desired_type` variable on the `defaults` type is now escaped when checking. Thanks [@bcomnes][]
- the `--size` flag check on the `download` type. Thanks [@bcomnes][]
- Some typos in the readme. Thanks [@rgieseke][]

## [0.10.0] - 2016-03-29

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

[@bcomnes]: https://github.com/bcomnes
[@dylanvaughn]: https://github.com/dylanvaughn
[@edrex]: https://github.com/edrex
[@frdmn]: https://github.com/frdmn
[@indigo423]: https://github.com/indigo423
[@jitakirin]: https://github.com/jitakirin
[@mattly]: https://github.com/mattly
[@ngkz]: https://github.com/ngkz
[@rgieseke]: https://github.com/rgieseke
[@rmhsilva]: https://github.com/rmhsilva
