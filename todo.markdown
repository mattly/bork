# meta
- includes
- "any" change flagger
- flag to not update remotes

# types
## git
- use merge instead of pull
- specify alternate refs than "master"
- --tmpdir option
- --shallow opion, default to full

## github
- arg to toggle between http and ssh url schemes

## brew
- specify 'brew install/upgrade' options, such as --env --cc, etc
- specify / compare package options, fe reattach-to-user-namespace --wrap-pbcopy-and-pbpaste
- manage taps, or at least specify formula from a tap

# Others
- basics
  - file
  - symlink
  - directory
  - permissions
  - templates?

- scm pack
  - move git/github here?
  - hg
  - darcs

-sysadmin pack
  - users
  - groups
  - iptables
  - apt
  - cron
      http://stackoverflow.com/questions/610839/how-can-i-programmatically-create-a-new-cron-job

- mac pack
  - brew
  - brew cask
  - defaults
  - launchd

- pl pack
  - gem
  - rbenv
  - npm
  - nenv
  - pip
  - cabal

note to pedants: this is for system ruby/npm/etc, not your project.
Some people still think gems, npm, etc are still viable distribution
vehicles for general-purpose executables and as such one cannot simply
install something like pygments or grunt or sass without first getting
to know the package manager for the language the tool I want to use is
written in.

