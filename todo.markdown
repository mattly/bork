# meta
- dependencies
	brew: check if brew is installed, install if not
- includes
- "any" change flagger
- runner
- flag to not update remotes

# declarations
## git
- fetch update from remotes
- use merge instead of pull
- specify alternate refs than "master"
- --tmpdir option
- --shallow opion, default to full

## github
- arg to toggle between http and ssh url schemes

## brew
- fetch update from remote
- specify 'brew install/upgrade' options, such as --env --cc, etc
- specify / compare package options, fe reattach-to-user-namespace --wrap-pbcopy-and-pbpaste
- manage taps, or at least specify formula from a tap

# Others
- permissions
- hg
- npm, pip, gem, cabal, etc
	note to pedants: this is for system ruby/npm/etc, not your f***in project.
	Some people still think gems, npm, etc are still viable distribution
	vehicles for general-purpose executables and as such one cannot simply
	install something like pygments or grunt or sass without first getting
	to know the package manager for the language the tool I want to use is
	written in.
- cron
- defaults
- launchd
- templates of some kind?
	ok, so how can we deal with templates sanely here?
	I'm thinking, 1) provide "has_file" decl that checks for existence and
	strings, and then 2) if missing or wrong, BYO template renderer
