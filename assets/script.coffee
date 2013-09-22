commit = (data, branch) ->
	data.match /^(.+),(.+),(.+),(.+)/
	info =
		branch: branch
		hash: RegExp.$1
		author: RegExp.$2
		date: RegExp.$3.match(/^(.+) (.+) (.+)/)
		msg: RegExp.$4

hashs = []

socket = io.connect '//localhost:3000'

socket.on 'quake', (d) ->
	data = commit(d.log, d.branch)
	unless $('.quakeplate.' + data.branch)
		$('.quakearea').append _.template($('#quakeplate-template').text(), data)
	for hash in hashs
		if hash is data.hash
			data.num = $.inArray(hash, hashs)
			$('.quakeplate.' + data.branch).append _.template($('#quakemsg-template').text(), data)
	data.num = $('.quakeplate.' + data.branch).children('.commit').length
	$('.quakeplate.' + data.branch).append _.template($('#quakemsg-template').text(), data)
	@

socket.on 'logs', (data) ->
	commits = []
	for branch in data
		$('.quakearea').append _.template($('#quakeplate-template').text(), branch)
		for line in branch.log
			info = commit(line, branch.name)
			commits.push info
	commits = _.sortBy commits, (i) ->
		i.date[0]
	i = 0
	for commit in commits
		if commit.hash isnt backhash
			hashs.push commit.hash
			i++
		commit.num = i
		$('.quakeplate.' + commit.branch).append _.template($('#quakemsg-template').text(), commit)
		backhash = commit.hash
	@
