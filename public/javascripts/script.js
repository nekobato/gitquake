(function() {
  var geninfo, hashs, socket;

  geninfo = function(data, branch) {
    data.match(/^(.+),(.+),(.+),(.+)/);
    return {
      branch: branch,
      hash: RegExp.$1,
      author: RegExp.$2,
      date: RegExp.$3.match(/^(.+) (.+) (.+)/),
      msg: RegExp.$4
    };
  };

  hashs = [];

  socket = io.connect('//localhost:3000');

  socket.on('quake', function(d) {
    if (hashs.indexOf(info.hash) > -1) {
      info.num = hashs.indexOf(info.hash) + 1;
      $('.quakeplate.' + info.branch).append(_.template($('#quakemsg-template').text(), info));
    } else {
      info.num = hashs.length + 1;
      $('.quakeplate.' + info.branch).append(_.template($('#quakemsg-template').text(), info));
    }
    return this;
  });

  socket.on('uplift', function(data) {
    var commit, commits, info, line, _i, _j, _len, _len1, _ref, _results;
    console.log(data);
    $('.quakearea').append(_.template($('#quakeplate-template').text(), data));
    commits = [];
    _ref = data.log;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      line = _ref[_i];
      info = geninfo(line, data.name);
      commits.push(info);
    }
    commits = _.sortBy(commits, function(i) {
      return i.date[0];
    });
    _results = [];
    for (_j = 0, _len1 = commits.length; _j < _len1; _j++) {
      commit = commits[_j];
      if (hashs.indexOf(commit.hash) > -1) {
        commit.num = hashs.indexOf(info.hash) + 1;
        _results.push($('.quakeplate.' + commit.branch).append(_.template($('#quakemsg-template').text(), commit)));
      } else {
        commit.num = hashs.length + 1;
        _results.push($('.quakeplate.' + info.branch).append(_.template($('#quakemsg-template').text(), commit)));
      }
    }
    return _results;
  });

  socket.on('log', function(data) {
    var backhash, commit, commits, info, line, num, _i, _j, _len, _len1, _ref;
    console.log(data);
    commits = [];
    $('.quakearea').append(_.template($('#quakeplate-template').text(), data));
    _ref = data.log;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      line = _ref[_i];
      info = geninfo(line, data.name);
      commits.push(info);
    }
    commits = _.sortBy(commits, function(i) {
      return i.date[0];
    });
    num = 0;
    for (_j = 0, _len1 = commits.length; _j < _len1; _j++) {
      commit = commits[_j];
      if (commit.hash !== backhash) {
        hashs.push(commit.hash);
        num++;
      }
      commit.num = num;
      $('.quakeplate.' + commit.branch).append(_.template($('#quakemsg-template').text(), commit));
      backhash = commit.hash;
    }
    return this;
  });

  socket.on('connect', function() {
    console.log('conection start');
    return socket.emit('log', {});
  });

}).call(this);
