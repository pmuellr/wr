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

`-c minutes --chime=minutes`

> Write a diagnostic message after `minutes` have elapsed since last running
> a command, to remind you `wr` is running.  The default is 5 minutes.
> Use the value 0 to disable the chime.

`-v --verbose`

> Generate additional diagnostic information.

`--stdoutcolor color`

`--stderrcolor color`

> Display stdout and stderr in specific colors; color values:
> `black red green yellow blue magenta cyan white`.

`--exec`

> Use exec instead of spawn to run the command.

`-V`

> Display the version number and exit.

`-?, -h`

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

ENVIRONMENT
-----------

If the current directory has a `.wr` file in it, that file is assumed
to have the contents of a `wr` invocation in it, one argument per line.
The file may contain blank lines or lines starting with the `#` character,
which are considered comments.

The stdout and stderr from the command being run are passed directory to
`wr`'s stdout and stderr.  stdin for the command will not be available
for the command.

Diagnostic information from `wr` will be written to stderr.

The command will be run in either spawn or exec mode, as determined by
command-line options.  Here are the differences:

exec:

* the command will not be parsed, as will be run as given
* stdout and stderr output will be buffered until the command is complete

spawn:

* the command will be parsed into space separated tokens, probably
misinterpreting any quotes you have in your command
* stdout and stderr output will not be buffered

HISTORY
-------

`wr` is a port of Patrick Mueller's [run-when-changed.py](https://gist.github.com/240922)
script to node.

* 2012-01-09: version 1.0.0
* 2012-01-10: version 1.0.1 - fixed some stupid bugs