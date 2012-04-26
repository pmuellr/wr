var FileSet;

FileSet = require('./FileSet');

module.exports.run = function(cmd, files, opts) {
  var fileSet;
  fileSet = new FileSet(files, opts);
  return fileSet.whenChangedRun(cmd);
};
