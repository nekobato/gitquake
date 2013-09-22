(function() {
  var commit, hashs, socket;

  commit = function(data, branch) {
    var info;
    data.match(/^(.+),(.+),(.+),(.+)/);
    return info = {
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
    var data, hash, _i, _len;
    data = commit(d.log, d.branch);
    if (!$('.quakeplate.' + data.branch)) {
      $('.quakearea').append(_.template($('#quakeplate-template').text(), data));
    }
    for (_i = 0, _len = hashs.length; _i < _len; _i++) {
      hash = hashs[_i];
      if (hash === data.hash) {
        data.num = $.inArray(hash, hashs);
        $('.quakeplate.' + data.branch).append(_.template($('#quakemsg-template').text(), data));
      }
    }
    data.num = $('.quakeplate.' + data.branch).children('.commit').length;
    $('.quakeplate.' + data.branch).append(_.template($('#quakemsg-template').text(), data));
    return this;
  });

  socket.on('logs', function(data) {
    var backhash, branch, commits, i, info, line, _i, _j, _k, _len, _len1, _len2, _ref;
    commits = [];
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      branch = data[_i];
      $('.quakearea').append(_.template($('#quakeplate-template').text(), branch));
      _ref = branch.log;
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        line = _ref[_j];
        info = commit(line, branch.name);
        commits.push(info);
      }
    }
    commits = _.sortBy(commits, function(i) {
      return i.date[0];
    });
    i = 0;
    for (_k = 0, _len2 = commits.length; _k < _len2; _k++) {
      commit = commits[_k];
      if (commit.hash !== backhash) {
        hashs.push(commit.hash);
        i++;
      }
      commit.num = i;
      $('.quakeplate.' + commit.branch).append(_.template($('#quakemsg-template').text(), commit));
      backhash = commit.hash;
    }
    return this;
  });

}).call(this);
