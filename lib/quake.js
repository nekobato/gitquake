(function() {
  var GitQuake, child_p, events, fs, os;

  child_p = require('child_process');

  events = require('events');

  fs = require('fs');

  os = require('os');

  GitQuake = function(repo) {
    return this.repo = repo;
  };

  GitQuake.prototype.branch = function(callback) {
    child_p.exec("cd " + this.repo + " && git branch", function(err, stdout, stderr) {
      var branches, i, res, _i, _len;
      if (err) {
        throw err;
      }
      res = [];
      branches = stdout.toString().split(os.EOL);
      branches.pop();
      for (_i = 0, _len = branches.length; _i < _len; _i++) {
        i = branches[_i];
        res.push({
          branch: i.slice(2)
        });
      }
      return callback(res);
    });
    return this;
  };

  GitQuake.prototype.showBranch = function(branch, callback) {
    child_p.exec("cd " + this.repo + " && git show-branch --merge-base " + branch, function(err, stdout, stderr) {
      if (err) {
        throw err;
      }
      return callback(stdout.toString());
    });
    return this;
  };

  GitQuake.prototype.log = function(branch, callback) {
    child_p.exec("cd " + this.repo + " && git log " + branch + " --date=iso --pretty=format:'%h,%an,%ad,%s'", function(err, stdout, stderr) {
      var line, logs, match, _i, _len, _ref;
      if (err) {
        throw err;
      }
      logs = [];
      _ref = stdout.toString().split(os.EOL);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        match = line.match(/^(.+),(.+),(.+),(.+)/);
        logs.push({
          hash: RegExp.$1,
          author: RegExp.$2,
          time: RegExp.$3,
          message: RegExp.$4
        });
      }
      return callback({
        branch: branch,
        result: logs
      });
    });
    return this;
  };

  GitQuake.prototype.commit = function(hash, callback) {
    child_p.exec("cd " + this.repo + " && git show " + hash + " --date=iso -p --pretty=format:'%b'", function(err, stdout, stderr) {
      var commits, line, _i, _len, _ref;
      if (err) {
        throw err;
      }
      commits = [];
      _ref = stdout.toString().split(os.EOL);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        if (line.match(/^@@(.+)@@$/)) {
          commits.push(RegExp.$1);
        }
      }
      return callback({
        name: hash,
        result: commits
      });
    });
    return this;
  };

  module.exports = GitQuake;

}).call(this);
