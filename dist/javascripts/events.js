(function() {
  var extract, git, history, view;

  history = [];

  extract = function(data, branch) {
    data.match(/^(.+),(.+),(.+),(.+)/);
    return {
      branch: branch,
      hash: RegExp.$1,
      author: RegExp.$2,
      date: RegExp.$3.match(/^(.+) (.+) (.+)/),
      msg: RegExp.$4
    };
  };

  /*
  socket = io.connect '//localhost:3006'
  
  socket.on 'quake', (d) ->
  	for log in d.log
  		commit = extract log
  		commit.branch = d.name
  		console.log commit
  		for h in history
  			history[h.indexOf(commit.hash)].branch[commit.branch] = true if commit.hash == h.history
  	console.log history
  	
  socket.on 'uplift', (data) ->
  	console.log data
  	$('.quakearea').append _.template($('#quakeplate-template').text(), data)
  	commits = []
  	for line in data.log
  		info = geninfo(line, data.name)
  		commits.push info
  	commits = _.sortBy commits, (i) ->
  		i.date[0]
  	for commit in commits
  		if hashs.indexOf(commit.hash) > -1
  			commit.num = hashs.indexOf(info.hash) + 1
  			$('.quakeplate.' + commit.branch).append _.template($('#quakemsg-template').text(), commit)
  		else
  			commit.num = hashs.length + 1
  			$('.quakeplate.' + info.branch).append _.template($('#quakemsg-template').text(), commit)
  
  socket.on 'log', (data) ->
  	console.log data
  	commits = []
  	$('.quakearea').append _.template($('#quakeplate-template').text(), data)
  	for line in data.log
  		info = geninfo(line, data.name)
  		commits.push info
  	commits = _.sortBy commits, (i) ->
  		i.date[0]
  	num = 0
  	for commit in commits
  		if commit.hash isnt backhash
  			hashs.push commit.hash
  			num++
  		commit.num = num
  		$('.quakeplate.' + commit.branch).append _.template($('#quakemsg-template').text(), commit)
  		backhash = commit.hash
  
  socket.on 'connect', () ->
  	console.log 'conection start'
  	socket.emit 'log', {}
  */


  git = {
    branch: function(callback) {
      return $.ajax({
        url: '/branch',
        dataType: 'json'
      }).done(function(data) {
        return callback(data);
      });
    },
    show: function(hash, callback) {
      return $.ajax({
        url: "/commit/" + hash,
        dataType: 'json'
      }).done(function(data) {
        return callback(data);
      });
    },
    log: function(branch, callback) {
      return $.ajax({
        url: "/log/" + branch,
        dataType: 'json'
      }).done(function(data) {
        return callback(data);
      });
    }
  };

  view = {
    branch: function(data) {
      var branch, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        branch = data[_i];
        _results.push($('#log-branch').append(_.template($('#git-branch').text(), branch)));
      }
      return _results;
    }
  };

  $(document).load(function() {
    console.log(git.branch);
    return git.branch(function(data) {
      return view.branch(data);
    });
  });

}).call(this);
