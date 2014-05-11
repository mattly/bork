# How To Write a Bork Assertion Type

So, you have something you'd like to be able to track with bork's `ok`
declaration.  Perhaps it's the presence of packages from yet another
programming language's packaging system, perhaps something you interact
with through the shell.  If you can programatically determine if it's
present, and programatically make it present, you can probably make a bork
assertion type out of it.

## Assertion Action Calls

Bork assertions are scripts that are called by the runner.  Ideally they could be run independently of the runner, provided the bork helpers are loaded via `bork load`, if they even call on the helpers.  The runner calls with an `action` and the arguments provided to `ok`.  For example, this call to `ok`:

    ok brew bats

is transformed into one or more of calls to the `brew` assertion:

    core/brew.sh status bats
    core/brew.sh install bats
    core/brew.sh upgrade bats

Most of the bork "core" assertions use a case statement to switch on the provided "action".

The runner decides what calls to perform based on its current operation and the state of the system.  Here are the actions a script can expect from the runner:

### status

    core/file.sh status path/to/targetfile path/from/sourcefile

When called with `status`, the assertion script should determine if the assertion is met, and return a code to indicate the current status of the assertion.  It _may_ echo messages to STDOUT indicating guidance to the user indicating any problems or warnings.

#### status return codes

- **0**: All is well, this assertion is satisfied.
- **10**: The assertion is not satisfied, call again with 'upgrade' to
  satisfy it.
- **11**: The assertion is not satisfied, but it appears an older version

