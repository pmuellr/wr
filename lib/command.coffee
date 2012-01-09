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

optimist = require 'optimist'

#-------------------------------------------------------------------------------
exports.run = ->

    argv = optimist
        .usage('Usage: $0 [-cvV] command [file ...]')
        .boolean( 'v')
        .alias(   'v', 'verbose')
        .describe('v', 'generate verbose diagnostics')

        .alias(   'c', 'chime')
        .describe('c', 'generate a diagnostic every so many minutes')

        .boolean( 'V')
        .describe('V', 'print the version')

        .boolean( '?')
        .describe('?', 'print help')

        .boolean( 'h')
        .describe('h', 'print help')

        .argv

    #----

    if argv["?"] or argv.h
        optimist.showHelp()
        process.exit 1

    #----

    if argv.V
        console.log(getVersion())
        process.exit 0

    #----

    args = argv._

    if args.length == 0
        optimist.showHelp()
        process.exit 1

    cmd = args[0]

    if cmd == '?'
        optimist.showHelp()
        process.exit 1

    if args.length == 1
        files = ["."]
    else
        files = args.slice(1)

    #----

    run cmd, files, argv

#-------------------------------------------------------------------------------
run = (cmd, files, opts) ->

    console.log "run '#{cmd}' when #{JSON.stringify(files)} changes using '#{JSON.stringify(opts)}'"

#-------------------------------------------------------------------------------
getVersion = () ->
    fs   = require 'fs'
    path = require 'path'

    packageJsonName  = path.join(path.dirname(fs.realpathSync(__filename)), '../package.json')

    json = fs.readFileSync(packageJsonName)
    values = JSON.parse(json)

    return values.version
