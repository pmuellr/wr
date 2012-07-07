var FileWatcher, FileWatcherNoPoll, FileWatcherPoll, fs, path;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

fs = require('fs');

path = require('path');

module.exports = FileWatcher = (function() {

  FileWatcher.get = function(fileSet, opts) {
    if (opts.poll) {
      return new FileWatcherPoll(fileSet, opts);
    } else {
      return new FileWatcherNoPoll(fileSet, opts);
    }
  };

  function FileWatcher(fileSet, opts) {
    this.fileSet = fileSet;
    this.opts = opts;
  }

  FileWatcher.prototype.fileChanged = function(fileName) {
    var newMtime, oldMtime, stats;
    if (fs.existsSync(fileName)) {
      oldMtime = this.fileSet.getMtime(fileName);
      stats = fs.statSync(fileName);
      newMtime = (stats != null ? stats.mtime.getTime() : void 0) || 0;
      if (oldMtime === newMtime) return;
    }
    if (fileName) this.fileSet.logInfo("file changed: " + fileName);
    this.stopWatching();
    return this.fileSet.fileChanged();
  };

  FileWatcher.prototype.getCB = function(fileName) {
    var _this = this;
    return function() {
      return _this.fileChanged(fileName);
    };
  };

  return FileWatcher;

})();

FileWatcherNoPoll = (function() {

  __extends(FileWatcherNoPoll, FileWatcher);

  function FileWatcherNoPoll(fileSet, opts) {
    FileWatcherNoPoll.__super__.constructor.apply(this, arguments);
  }

  FileWatcherNoPoll.prototype.watch = function(files) {
    var file, watcher, _i, _len;
    this.watchers = [];
    for (_i = 0, _len = files.length; _i < _len; _i++) {
      file = files[_i];
      try {
        watcher = fs.watch(file, {
          persist: true
        }, this.getCB(file));
        this.watchers.push(watcher);
      } catch (e) {
        this.fileSet.logError("exception watching '" + file + "': " + e);
        if (e.code === "EMFILE") {
          this.fileSet.logError("increase available file handles with `ulimit -n <number>`");
        }
        return;
      }
    }
  };

  FileWatcherNoPoll.prototype.stopWatching = function() {
    var watcher, _i, _len, _ref;
    _ref = this.watchers;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      watcher = _ref[_i];
      watcher.close();
    }
    return this.watchers = [];
  };

  return FileWatcherNoPoll;

})();

FileWatcherPoll = (function() {

  __extends(FileWatcherPoll, FileWatcher);

  function FileWatcherPoll(fileSet, opts) {
    FileWatcherPoll.__super__.constructor.apply(this, arguments);
  }

  FileWatcherPoll.prototype.watch = function(files) {
    var file, options, _i, _len, _ref;
    this.files = files;
    options = {
      interval: 1000 * this.opts.poll,
      persistent: true
    };
    _ref = this.files;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      file = _ref[_i];
      try {
        fs.watchFile(file, options, this.getCB(file));
      } catch (e) {
        this.fileSet.logError("exception watching '" + file + "': " + e);
        return;
      }
    }
  };

  FileWatcherPoll.prototype.stopWatching = function() {
    var file, _i, _len, _ref, _results;
    _ref = this.files;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      file = _ref[_i];
      _results.push(fs.unwatchFile(file));
    }
    return _results;
  };

  return FileWatcherPoll;

})();
