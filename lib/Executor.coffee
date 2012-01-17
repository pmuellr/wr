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

childProcess = require 'child_process'

charm        = require 'charm'

#-------------------------------------------------------------------------------
module.exports = class Executor

    #---------------------------------------------------------------------------
    @getExecutor: (fileSet, opts) ->
        if opts.exec
            new ExecutorExec(fileSet, opts)
        else
            new ExecutorSpawn(fileSet, opts)

    #---------------------------------------------------------------------------
    constructor: (@fileSet, @opts) ->

    #---------------------------------------------------------------------------
    resetAfterCommand: () ->
        @fileSet.resetAfterCommand()

    #---------------------------------------------------------------------------
    timerStart: () ->
        @startTime = (new Date()).valueOf()

    #---------------------------------------------------------------------------
    timerElapsed: () ->
        ms = (new Date()).valueOf() - @startTime
        ms = Math.round(ms / 100)
        ms / 10

    #---------------------------------------------------------------------------
    logSuccess: (message) ->
        @opts.logSuccess message

    #---------------------------------------------------------------------------
    logError: (message) ->
        @opts.logError message

    #---------------------------------------------------------------------------
    logInfo: (message) ->
        @opts.logInfo message

    #---------------------------------------------------------------------------
    logVerbose: (message) ->
        return if not @opts.verbose

#-------------------------------------------------------------------------------
class ExecutorExec extends Executor

    #---------------------------------------------------------------------------
    constructor: (fileSet, opts) ->
        super

    #---------------------------------------------------------------------------
    run: (cmd) ->
        @timerStart()

        callback = (error, stdout, stderr) => @done(error, stdout, stderr)

        childProcess.exec(cmd, callback)

    #---------------------------------------------------------------------------
    done: (error, stdout, stderr) ->
        if not @opts.stdoutcolor
            process.stdout.write(stdout)
        else
            charm(process.stdout)
                .push(true)
                .foreground(@opts.stdoutcolor)
                .write(stdout)
                .pop(true)


        if not @opts.stderrcolor
            process.stderr.write(stderr)
        else
            charm(process.stderr)
                .push(true)
                .foreground(@opts.stderrcolor)
                .write(stderr)
                .pop(true)

        secs = @timerElapsed()

        if error
            @logError   "#{secs}s - command failed with rc:#{error.code}"
        else
            @logSuccess "#{secs}s - command succeeded"

        @resetAfterCommand()

#-------------------------------------------------------------------------------
class ExecutorSpawn extends Executor

    #---------------------------------------------------------------------------
    constructor: (fileSet, opts) ->
        super

    #---------------------------------------------------------------------------
    run: (cmd) ->
        @timerStart()

        [ cmd, args ] = @splitCmd(cmd)

        proc = childProcess.spawn(cmd, args)

        proc.stdin.end()
        proc.stdout.on('data', (data) => @stdout(data))
        proc.stderr.on('data', (data) => @stderr(data))

        proc.on('exit', (code, sig) => @exit(code, sig))

    #---------------------------------------------------------------------------
    stdout: (data) ->
        if not @opts.stdoutcolor
            process.stdout.write(data)
            return

        charm(process.stdout)
            .push(true)
            .foreground(@opts.stdoutcolor)
            .write(data)
            .pop(true)

    #---------------------------------------------------------------------------
    stderr: (data) ->
        if not @opts.stderrcolor
            process.stderr.write(data)
            return

        charm(process.stderr)
            .push(true)
            .foreground(@opts.stderrcolor)
            .write(data)
            .pop(true)

    #---------------------------------------------------------------------------
    exit: (code, sig) ->
        secs = @timerElapsed()

        if code == 0
            @logSuccess "#{secs}s - command succeeded"
        else if code
            @logError   "#{secs}s - command failed with rc:#{code}"
        else if sig
            @logError   "#{secs}s - command failed with signal:#{sig}"
        else
            @logError   "#{secs}s - command failed for some unknown reason"

        @resetAfterCommand()

    #---------------------------------------------------------------------------
    splitCmd: (cmd) ->
        cmd   = cmd.replace(/(^\s+)|(\s+$)/g,'')
        parts = cmd.split(/\s+/)

        cmd  = parts[0]
        args = parts.slice(1)

        [ cmd, args ]

