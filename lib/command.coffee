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

#-------------------------------------------------------------------------------
exports.run = ->

    optimist.usage 'Usage: $0 [-cvV] command [file ...]'

    optimist.alias('v', 'verbose')
    optimist.alias('c', 'chime')
    optimist.boolean('v')
    optimist.boolean('V')
    optimist.boolean('?')
    optimist.boolean('h')

    opts = optimist.argv

    argv = opts._

    run argv, opts

#-------------------------------------------------------------------------------
run = (argv, opts) ->
    if argv.length == 0
        optimist.showHelp()
        sys.exit(1)

    cmd = argv[0]

    if argv.length == 1
        files = ["."]
    else
        files = argv.slice 1

    fileSet = new FileSet(files)

    fileSet.whenChangedRun(cmd)

