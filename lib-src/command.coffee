#-------------------------------------------------------------------------------
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

fs       = require 'fs'
path     = require 'path'

colors   = require 'colors'
optimist = require 'optimist'

wr       = require './wr'

existsSync = fs.existsSync || path.existsSync

Colors = null

#-------------------------------------------------------------------------------
exports.run = ->

    args = process.argv.slice(2)

    if args.length == 0
        if existsSync('.wr')
            stats = fs.statSync('.wr')
            if stats.isFile()
                args = getDotWrContents(".wr")

    optimist = optimist(args)
    argv = optimist
        .usage('Usage: $0 [options] command [file ...]')

        .alias(   'v', 'verbose')
        .boolean( 'verbose')
        .describe('verbose', 'generate verbose diagnostics')

        .alias(   'c', 'chime')
        .default( 'chime', 5)
        .describe('chime', 'generate a diagnostic every so many minutes')

        .boolean( 'exec')
        .describe('exec', 'run command with exec instead of spawn')

        .alias(   'p', 'poll')
        .describe('poll', 'use poll-based file watching')

        .boolean( 'V')
        .describe('V', 'print the version')

        .string(  'color-stdout')
        .default( 'color-stdout',  '')
        .describe('color-stdout',  'color of stdout')

        .string(  'color-stderr')
        .default( 'color-stderr',  'red')
        .describe('color-stderr',  'color of stderr')

        .string(  'color-info')
        .default( 'color-info',    'blue.inverse.white')
        .describe('color-info',    'color of info messages')

        .string(  'color-success')
        .default( 'color-success', 'green.inverse.white')
        .describe('color-success', 'color of success messages')

        .string(  'color-error')
        .default( 'color-error',   'red.inverse.white')
        .describe('color-error',   'color of error messages')

        .boolean( '?')
        .describe('?', 'print help')

        .boolean( 'h')
        .describe('h', 'print help')

        .argv

    #----

    if argv.chime
        if typeof argv.chime != 'number'
            console.error "the chime option value is not a number"
            process.exit 1

    if argv.poll
        if typeof argv.poll != 'number'
            console.error "the poll option value is not a number"
            process.exit 1


    printHelp() if argv["?"] or argv.h

    if argv.V
        console.log(getVersion())
        process.exit 0

    args = argv._

    printHelp() if args.length == 0

    cmd = args[0]

    printHelp() if cmd == '?'

    if args.length == 1
        files = ["."]
    else
        files = args.slice(1)

    #----

    opts = {}

    opts.verbose     = argv.verbose
    opts.chime       = argv.chime
    opts.exec        = argv.exec
    opts.poll        = argv.poll

    Colors = opts.colors =
        stdout:  argv['color-stdout']
        stderr:  argv['color-stderr']
        info:    argv['color-info']
        success: argv['color-success']
        error:   argv['color-error']

    for type, color of opts.colors
        opts.colors[type] = colorizer color

    opts.logError    = logError
    opts.logSuccess  = logSuccess
    opts.logInfo     = logInfo

    ###
    console.log """
        cmd:         #{cmd}
        files:       #{JSON.stringify(files)}
        opts:        #{JSON.stringify(opts)}
        argv: #{JSON.stringify(argv,null,4)}
    """
    ###

    wr.run cmd, files, opts

#-------------------------------------------------------------------------------
colorizer = (colorNames) ->
    colorNames = colorNames.split "."

    for colorName in colorNames
        continue if colorName is ""

        if typeof colors[colorName] isnt "function"
            console.log "invalid color: #{colorName}"
            process.exit 1

    return (string) ->
        for colorName in colorNames
            continue if colorName is ""
            string = colors[colorName].call(colors, string)

        return string

#-------------------------------------------------------------------------------
printHelp = () ->
    optimist.showHelp()

    console.error "for more info see: https://github.com/pmuellr/wr"

    process.exit 1

#-------------------------------------------------------------------------------
getDotWrContents = () ->
    contents = fs.readFileSync('.wr', 'utf8')
    lines    = contents.split('\n')

    args = []
    for line in lines
        line = line.replace(/#.*/,'')
        line = line.replace(/(^\s+)|(\s+$)/g,'')
        continue if line == ''

        if line[0] == '-'
            pattern = /(\S*)(\s*(.*))/
            groups = line.match(pattern)
            if groups[3] != ''
                args.push groups[1]
                args.push groups[3]
                continue

        args.push line

    args

#-------------------------------------------------------------------------------
getVersion = () ->

    packageJsonName  = path.join(path.dirname(fs.realpathSync(__filename)), '../package.json')

    json = fs.readFileSync(packageJsonName, 'utf8')
    values = JSON.parse(json)

    return values.version

#---------------------------------------------------------------------------
logError = (message) ->
    date    = new Date()
    time    = date.toLocaleTimeString()
    message = Colors.error "#{time} wr: #{message}"

    console.log message

#---------------------------------------------------------------------------
logSuccess = (message) ->
    date    = new Date()
    time    = date.toLocaleTimeString()
    message = Colors.success "#{time} wr: #{message}"

    console.log message

#---------------------------------------------------------------------------
logInfo = (message) ->
    date    = new Date()
    time    = date.toLocaleTimeString()
    message = Colors.info "#{time} wr: #{message}"

    console.log message
