var Executor, FileSet, FileWatcher, fs, path;

fs = require('fs');

path = require('path');

Executor = require('./Executor');

FileWatcher = require('./FileWatcher');

module.exports = FileSet = (function() {

  function FileSet(files, opts) {
    this.files = files;
    this.opts = opts;
    this.allFiles = [];
    this.allMtimes = {};
    this.chimeTimeout = null;
    if (!this.opts.logError) this.opts.logError = (function() {});
    if (!this.opts.logSuccess) this.opts.logSuccess = (function() {});
    if (!this.opts.logInfo) this.opts.logInfo = (function() {});
    this.executor = Executor.getExecutor(this, this.opts);
  }

  FileSet.prototype.getMtime = function(fileName) {
    return this.allMtimes[fileName] || 0;
  };

  FileSet.prototype.whenChangedRun = function(cmd) {
    this.cmd = cmd;
    this.expandFiles();
    if (this.allFiles.length === 0) {
      this.logError("no files found to watch");
      return;
    }
    this.chime();
    return this.watchFiles();
  };

  FileSet.prototype.fileChanged = function() {
    this.fileWatcher = null;
    return this.runCommand();
  };

  FileSet.prototype.chime = function() {
    this.logInfo("watching " + this.allFiles.length + " files, running '" + this.cmd + "'");
    return this.resetChime();
  };

  FileSet.prototype.resetChime = function() {
    var _this = this;
    if (!this.opts.chime) return;
    if (this.chimeTimeout) clearTimeout(this.chimeTimeout);
    return this.chimeTimeout = setTimeout(function() {
      return _this.chime();
    }, 1000 * 60 * this.opts.chime);
  };

  FileSet.prototype.resetAfterCommand = function() {
    this.expandFiles();
    if (this.allFiles.length === 0) {
      this.logError("no files found to watch");
      return;
    }
    this.watchFiles();
    return this.resetChime();
  };

  FileSet.prototype.runCommand = function() {
    this.opts.logInfo("running '" + this.cmd + "'");
    return this.executor.run(this.cmd);
  };

  FileSet.prototype.expandFiles = function() {
    var file, _i, _len, _ref, _results;
    this.allFiles = [];
    this.allMtimes = {};
    _ref = this.files;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      file = _ref[_i];
      _results.push(this.expandFile(file));
    }
    return _results;
  };

  FileSet.prototype.expandFile = function(fileName) {
    var entries, entry, stats, _i, _len, _results;
    if (!fs.existsSync(fileName)) {
      this.logError("File not found '" + fileName + "'");
      return;
    }
    stats = fs.statSync(fileName);
    if (stats.isFile()) {
      this.allFiles.push(fileName);
      return this.allMtimes[fileName] = stats.mtime.getTime();
    } else if (stats.isDirectory()) {
      this.allFiles.push(fileName);
      this.allMtimes[fileName] = stats.mtime.getTime();
      entries = fs.readdirSync(fileName);
      _results = [];
      for (_i = 0, _len = entries.length; _i < _len; _i++) {
        entry = entries[_i];
        _results.push(this.expandFile(path.join(fileName, entry)));
      }
      return _results;
    }
  };

  FileSet.prototype.watchFiles = function() {
    this.fileWatcher = FileWatcher.get(this, this.opts);
    return this.fileWatcher.watch(this.allFiles);
  };

  FileSet.prototype.logSuccess = function(message) {
    return this.opts.logSuccess(message);
  };

  FileSet.prototype.logError = function(message) {
    return this.opts.logError(message);
  };

  FileSet.prototype.logInfo = function(message) {
    return this.opts.logInfo(message);
  };

  FileSet.prototype.logVerbose = function(message) {
    if (!this.opts.verbose) return;
    return this.opts.logInfo(message);
  };

  return FileSet;

})();
