var charm, fs, getDotWrContents, getVersion, logError, logInfo, logSuccess, optimist, path, printHelp, wr;

fs = require('fs');

path = require('path');

charm = require('charm');

optimist = require('optimist');

wr = require('./wr');

charm = charm(process.stderr);

exports.run = function() {
  var args, argv, cmd, files, opts, stats;
  args = process.argv.slice(2);
  if (args.length === 0) {
    if (fs.existsSync('.wr')) {
      stats = fs.statSync('.wr');
      if (stats.isFile()) args = getDotWrContents(".wr");
    }
  }
  optimist = optimist(args);
  argv = optimist.usage('Usage: $0 [options] command [file ...]').alias('v', 'verbose').boolean('verbose').describe('verbose', 'generate verbose diagnostics').alias('c', 'chime')["default"]('chime', 5).describe('chime', 'generate a diagnostic every so many minutes').boolean('exec').describe('exec', 'run command with exec instead of spawn').string('stdoutcolor').describe('stdoutcolor', 'display stdout in the specified color').string('stderrcolor').describe('stderrcolor', 'display stderr in the specified color').alias('p', 'poll').describe('poll', 'use poll-based file watching').boolean('V').describe('V', 'print the version').boolean('?').describe('?', 'print help').boolean('h').describe('h', 'print help').argv;
  if (argv.chime) {
    if (typeof argv.chime !== 'number') {
      console.error("the chime option value is not a number");
      process.exit(1);
    }
  }
  if (argv.poll) {
    if (typeof argv.poll !== 'number') {
      console.error("the poll option value is not a number");
      process.exit(1);
    }
  }
  if (argv["?"] || argv.h) printHelp();
  if (argv.V) {
    console.log(getVersion());
    process.exit(0);
  }
  args = argv._;
  if (args.length === 0) printHelp();
  cmd = args[0];
  if (cmd === '?') printHelp();
  if (args.length === 1) {
    files = ["."];
  } else {
    files = args.slice(1);
  }
  opts = {};
  opts.verbose = argv.verbose;
  opts.chime = argv.chime;
  opts.stdoutcolor = argv.stdoutcolor;
  opts.stderrcolor = argv.stderrcolor;
  opts.exec = argv.exec;
  opts.poll = argv.poll;
  opts.logError = logError;
  opts.logSuccess = logSuccess;
  opts.logInfo = logInfo;
  /*
      console.log """
          cmd:         #{cmd}
          files:       #{JSON.stringify(files)}
          opts:        #{JSON.stringify(opts)}
          argv: #{JSON.stringify(argv,null,4)}
      """
  */
  return wr.run(cmd, files, opts);
};

printHelp = function() {
  optimist.showHelp();
  console.error("for more info see: https://github.com/pmuellr/wr");
  return process.exit(1);
};

getDotWrContents = function() {
  var args, contents, groups, line, lines, pattern, _i, _len;
  contents = fs.readFileSync('.wr', 'utf8');
  lines = contents.split('\n');
  args = [];
  for (_i = 0, _len = lines.length; _i < _len; _i++) {
    line = lines[_i];
    line = line.replace(/#.*/, '');
    line = line.replace(/(^\s+)|(\s+$)/g, '');
    if (line === '') continue;
    if (line[0] === '-') {
      pattern = /(\S*)(\s*(.*))/;
      groups = line.match(pattern);
      if (groups[3] !== '') {
        args.push(groups[1]);
        args.push(groups[3]);
        continue;
      }
    }
    args.push(line);
  }
  return args;
};

getVersion = function() {
  var json, packageJsonName, values;
  packageJsonName = path.join(path.dirname(fs.realpathSync(__filename)), '../package.json');
  json = fs.readFileSync(packageJsonName, 'utf8');
  values = JSON.parse(json);
  return values.version;
};

logError = function(message) {
  var date, time;
  date = new Date();
  time = date.toLocaleTimeString();
  message = "" + time + " wr: " + message;
  return charm.push(true).display('bright').background('red').foreground('white').write(message).pop(true).write('\n').down(1);
};

logSuccess = function(message) {
  var date, time;
  date = new Date();
  time = date.toLocaleTimeString();
  message = "" + time + " wr: " + message;
  return charm.push(true).display('bright').background('green').foreground('white').write(message).pop(true).write('\n').down(1);
};

logInfo = function(message) {
  var date, time;
  date = new Date();
  time = date.toLocaleTimeString();
  message = "" + time + " wr: " + message;
  return charm.push(true).display('bright').background('blue').foreground('white').write(message).pop(true).write('\n').down(1);
};
