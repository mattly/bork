When writing a status clause, it is best practice to traverse the codes described above in order from highest to lowest, testing conditions as necessary.  If multiple conditions exist that would return the same status code, they should all be tested and echo any appropriate messages before returning the code.

#### Normal Status Codes

`0`: Satsified.  No further action needed.

`10`: Missing.  Satisfy with 'install'.

`11`: Outdated.  Satisfy with 'upgrade'.  Indicates the existing thing is behind.

`12`: Partial.  Satisfy with 'upgrade'.  Indicates the existing thing is incomplete.

`13`: Mismatched, Upgrade.  Satisfy with 'upgrade'.  No conflict (defined below) occurs, and the assertion is not 'outdated', but perhaps some options are different.

`14`: Mismatched, Clobber.  Satisfy with 'delete' followed by 'install'.  Not supported yet.

#### Conflict Status Codes

**Conflicts** are a class of responses which indicate the system is in a state where the process of satisfying the assertion will cause the existing state of the assertion to go away.  Examples include a file assertion having a different md5 sum, or a git repository having diverged from its upstream.  The script **should** echo one or more lines describing what is conflicted and what might be lost if the conflict resolves.

Conflicts are not currently resolvable, but a future version of bork will prompt the user or allow a --force option to satisfy the assertion.

`20`: Conflict, Upgrade.  Satisfy with 'upgrade'.  Some data might be lost, such as a file with a different md5 sum, uncommitted SCM changes, etc.

`21`: Conflict, Clobber.  Satisfy with 'delete' followed by 'install'.

`25`: Conflict, Halt.  The script does not know how to resolve this conflict.

#### Error Status Codes

**Errors** are a class of responses which indicate the script cannot proceed with satisfying this assertion.  The script **should** echo one or more lines describing the problem and hint at a solution.

`30`: Bad arguments.  The script was provided with arguments it cannot understand.

`31`: Failed arguments.  The script was provided with arguments that do not resolve into a resource the script can use to satisfy the result, or even further determine its status.

`32`: Failed argument precondition.  The script was provided with arguments that indicate it should do something the script knows it cannot do.  For example, use a git branch that doesn't exist.

`33`: Failed precondition.  The script cannot run, a requisite condition (f.e., git) is missing.

`34`: Unsupported platform.  The script cannot run on this host, the operating system is not supported.

