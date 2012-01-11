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

fs = require 'fs'

#-------------------------------------------------------------------------------
module.exports = class FileWatcher

    #---------------------------------------------------------------------------
    @get: (fileSet, opts) ->
        if opts.poll
            return new FileWatcherPoll(fileSet, opts)
        else
            return new FileWatcherNoPoll(fileSet, opts)

    #---------------------------------------------------------------------------
    constructor: (@fileSet, @opts) ->

    #---------------------------------------------------------------------------
    fileChanged: () ->
        @stopWatching()
        @fileSet.fileChanged()

#-------------------------------------------------------------------------------
class FileWatcherNoPoll extends FileWatcher

    #---------------------------------------------------------------------------
    constructor: (fileSet, opts) ->
        super

    #---------------------------------------------------------------------------
    watch: (files) ->
        fileChanged = => @fileChanged()

        @watchers = []
        for file in files
            try
                watcher = fs.watch(file, {persist: true}, fileChanged)
                @watchers.push(watcher)
            catch e
                @fileSet.logError "exception watching '#{file}': #{e}"

    #---------------------------------------------------------------------------
    stopWatching: () ->
        for watcher in @watchers
            watcher.close()

        @watchers = []

#-------------------------------------------------------------------------------
class FileWatcherPoll extends FileWatcher

    #---------------------------------------------------------------------------
    constructor: (fileSet, opts) ->
        super

    #---------------------------------------------------------------------------
    watch: (@files) ->
        fileChanged = => @fileChanged()

        options =
            interval:   1000 * @opts.poll
            persistent: true

        for file in @files
            try
                fs.watchFile(file, options, fileChanged)
            catch e
                @fileSet.logError "exception watching '#{file}': #{e}"

    #---------------------------------------------------------------------------
    stopWatching: () ->
        for file in @files
            fs.unwatchFile(file)

