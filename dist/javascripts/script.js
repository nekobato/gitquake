(function() {
  var Git, Log, View, git, hash_history, log, view;

  hash_history = {};

  Git = function() {};

  Git.prototype.branch = function(callback) {
    return $.ajax({
      url: '/branch',
      dataType: 'json'
    }).done(function(data) {
      return callback(data);
    });
  };

  Git.prototype.show = function(hash, callback) {
    return $.ajax({
      url: "/commit/" + hash,
      dataType: 'json'
    }).done(function(data) {
      return callback(data);
    });
  };

  Git.prototype.log = function(branch, callback) {
    return $.ajax({
      url: "/log/" + branch,
      dataType: 'json'
    }).done(function(data) {
      return callback(data);
    });
  };

  git = new Git;

  View = function() {};

  View.prototype.branch = function(data) {
    return $('#table-branch').append(_.template($('#git-branch').text(), data));
  };

  View.prototype.log = function(data) {
    return $('#table-log').append(_.template($('#git-log').text(), data));
  };

  view = new View;

  Log = function() {};

  Log.prototype.branch = function(data, callback) {
    var i, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      i = data[_i];
      _results.push(callback(i));
    }
    return _results;
  };

  Log.prototype.log = function(data, callback) {
    var i, _i, _len, _ref, _results;
    if (!data.result) {
      return false;
    }
    _ref = data.result;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      if (!log[i.hash]) {
        _results.push(log[i.hash] = i.time);
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  log = new Log;

  git.branch(function(data) {
    var branch, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      branch = data[_i];
      _results.push(git.log(branch, function(data) {
        return hash_history.push(data.result);
      }));
    }
    return _results;
  });

  git.branch(function(data) {
    return log.branch(data, function(data) {
      return log.log(data, function(data) {});
    });
  });

}).call(this);
