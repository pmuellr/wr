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

fs   = require 'fs'
path = require 'path'

existsSync = fs.existsSync || path.existsSync

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
    fileChanged: (fileName) ->
        if existsSync fileName
            oldMtime = @fileSet.getMtime(fileName)
        
            stats = fs.statSync(fileName)
            newMtime = stats?.mtime.getTime() || 0
            
            if oldMtime == newMtime
                return
     
        @fileSet.logInfo "file changed: #{fileName}" if fileName
        @stopWatching()
        @fileSet.fileChanged()

    #---------------------------------------------------------------------------
    getCB: (fileName) ->
        => @fileChanged(fileName)

#-------------------------------------------------------------------------------
class FileWatcherNoPoll extends FileWatcher

    #---------------------------------------------------------------------------
    constructor: (fileSet, opts) ->
        super

    #---------------------------------------------------------------------------
    watch: (files) ->
        @watchers = []
        for file in files
            try
                watcher = fs.watch(file, {persist: true}, @getCB(file))
                @watchers.push(watcher)
            catch e
                @fileSet.logError "exception watching '#{file}': #{e}"
                if e.code == "EMFILE"
                    @fileSet.logError "increase available file handles with `ulimit -n <number>`"
                return

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
        options =
            interval:   1000 * @opts.poll
            persistent: true

        for file in @files
            try
                fs.watchFile(file, options,  @getCB(file))
            catch e
                @fileSet.logError "exception watching '#{file}': #{e}"
                return

    #---------------------------------------------------------------------------
    stopWatching: () ->
        for file in @files
            fs.unwatchFile(file)

