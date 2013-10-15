<!--
# Copyright (c) 2012 Patrick Mueller
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
-->

NAME
----

`wr` -- watch files and run a command when they change

SYNOPSIS
--------

    wr [-cvV] command [file ...]

DESCRIPTION
-----------

`wr` will watch the set of files and directories specified on the
command line, and run the specified command when any of the files
changes.  For each file operand which is a directory, all the files
in the directory (recursively)  will be watched.

If no files are specified, it's as if you passed "." as the file parameter.

The following options are available:

`-c --chime minutes`

> Write a diagnostic message after `minutes` have elapsed since last running
> a command, to remind you `wr` is running.  The default is 5 minutes.
> Use the value 0 to disable the chime.

`-v --verbose`

> Generate additional diagnostic information.

`--exec`

> Use exec instead of spawn to run the command.

`-p --poll seconds`

> Use a polling file watcher.  The default is to use a non-polling file watcher.
> The non-polling file watcher
> may have a relatively small maximum number of files it can watch (200),
> but the polling file watcher has no maximum.
> The polling file
> watcher may incur delays between a file changing and the command running,
> compared to the non-polling file watcher.

`-V`

> Display the version number and exit.

`-? -h`

> Display help.

EXAMPLES
--------

The following is how to run make when any file in the current directory
changes:

        wr make

More likely you can whittle the list of source files checked a bit.  The
following will run make any file in the `src`, `doc` or `test` directories
changes:

        wr make src doc test

To run a command with arguments, quote the command you want to run.  The
following will run the command "`echo a file changed`" when any file in the
current directory changes:

        wr "echo a file changed"

DIAGNOSTICS
-----------

wr will not normally exit.   Use ctrl-c or equivalent to kill the process
from the command-line.

Diagnostic information from `wr` will be written to stderr.

ENVIRONMENT
-----------

If the current directory has a `.wr` file in it, that file is assumed
to have the contents of a `wr` invocation in it.  Options, option/value
pairs, the command to run, and each file to be watched should be
specified on separate lines.
The file may contain blank lines or lines starting with the `#` character,
which are considered comments.

The stdout and stderr from the command being run are passed directory to
`wr`'s stdout and stderr.  stdin for the command will not be available
for the command.

The command will be run in either spawn or exec mode, as determined by
command-line options.  Here are the differences:

exec:

* the command will not be parsed, as will be run as given
* should handle i/o redirection shell operators
* stdout and stderr output will be buffered until the command is complete

spawn:

* the command will be parsed into space separated tokens, probably
misinterpreting any quotes you have in your command
* will not handle i/o redirection shell operators
* stdout and stderr output will not be buffered

HISTORY
-------

`wr` is a port of Patrick Mueller's [run-when-changed.py](https://gist.github.com/240922)
script to node.

**2012-05-03: version 1.2.0**

* [commit d684efb7](https://github.com/pmuellr/wr/commit/d684efb7182bd866c875be2bb459a692a5661599) - replaced charm w/colors

**2012-05-03: version 1.2.0**

* [issue 8](https://github.com/pmuellr/wr/issues/8) - add elapsed time to success and failure messages
* fixed bug where wr fired off it's command when the access time changed on a file

**2012-01-11: version 1.1.0**

* [issue 1](https://github.com/pmuellr/wr/issues/1) - chime should print the time
* [issue 2](https://github.com/pmuellr/wr/issues/2) - chime should default to 5 minutes
* [issue 3](https://github.com/pmuellr/wr/issues/3) - .wr file parser should accept option/value on a single line
* [issue 5](https://github.com/pmuellr/wr/issues/5) - provide option to use stat-based polling
* [issue 6](https://github.com/pmuellr/wr/issues/6) - use spawn instead of exec to run commands
* [issue 7](https://github.com/pmuellr/wr/issues/7) - colorize stdout and stderr

**2012-01-10: version 1.0.1**

* fixed some stupid bugs

**2012-01-09: version 1.0.0**

* initial release

