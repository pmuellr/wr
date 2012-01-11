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

fs           = require 'fs'
path         = require 'path'

charm        = require 'charm'

Executor     = require './Executor'

#-------------------------------------------------------------------------------
module.exports = class FileSet

    #---------------------------------------------------------------------------
    constructor: (@files, @opts) ->
        @allFiles     = []
        @watchers     = []
        @chimeTimeout = null

        @opts.logError   = (->) if !@opts.logError
        @opts.logSuccess = (->) if !@opts.logSuccess
        @opts.logInfo    = (->) if !@opts.logInfo

        @executor = Executor.getExecutor(@, @opts)

    #---------------------------------------------------------------------------
    whenChangedRun: (@cmd) ->
        @expandFiles()
        if @allFiles.length == 0
            @logError "no files found to watch"
            return

        @chime()
        @watchFiles()

    #---------------------------------------------------------------------------
    fileChanged: () ->
        @clearWatchers()
        @runCommand()

    #---------------------------------------------------------------------------
    chime:  ->
        @logInfo "watching #{@allFiles.length} files, running '#{@cmd}'"
        @resetChime()

    #---------------------------------------------------------------------------
    resetChime: ->
        return if !@opts.chime

        clearTimeout(@chimeTimeout) if @chimeTimeout

        @chimeTimeout = setTimeout(
            => @chime(),
            1000 * 60 * @opts.chime
        )

    #---------------------------------------------------------------------------
    resetAfterCommand:  ->
        @expandFiles()

        if @allFiles.length == 0
            @logError("no files found to watch")
            return

        @watchFiles()
        @resetChime()

    #---------------------------------------------------------------------------
    runCommand:  ->
        @opts.logInfo "running '#{@cmd}'"

        @executor.run(@cmd)

    #---------------------------------------------------------------------------
    expandFiles: ->
        @allFiles = []

        for file in @files
            @expandFile(file)

    #---------------------------------------------------------------------------
    expandFile: (fileName) ->
        if !path.existsSync(fileName)
            @logError("File not found '#{fileName}'")
            return

        stats = fs.statSync(fileName)

        if stats.isFile()
            @allFiles.push(fileName)

        else if stats.isDirectory()
            @allFiles.push(fileName)

            entries = fs.readdirSync(fileName)

            for entry in entries
                @expandFile path.join(fileName, entry)


    #---------------------------------------------------------------------------
    watchFiles:  ->
        fileChanged = => @fileChanged()
        for file in @allFiles
            try
                watcher = fs.watch(file, {persist: true}, fileChanged)
            catch e
                @logError "exception watching '#{file}': #{e}"
                continue

            @watchers.push(watcher)

    #---------------------------------------------------------------------------
    clearWatchers: () ->
        for watcher in @watchers
            watcher.close()

        @watchers = []

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

        @opts.logInfo message
