quakeMessage = (data) ->

socket = io.connect '//localhost:3000'
socket.on 'quake', (data)->
	data.num = $('.quakeplate.' + data.branch).children('.commit').length
	console.log data
	$('.quakeplate.' + data.branch).append _.template($('#quakemsg-template').text(), data)
	@
socket.on 'logs', (data) ->
	commits = []
	for branch in data
		$('.quakearea').append _.template($('#quakeplate-template').text(), branch)
		for line in branch.log
			console.log line
			line.match /^(.+),(.+),(.+),(.+)/
			info =
				branch: branch.name
				hash: RegExp.$1
				author: RegExp.$2
				date: RegExp.$3
				msg: RegExp.$4
			commits.push info
	commits = _.sortBy commits, (i) ->
		i.date
	i = 0
	for commit in commits
		i++ if commit.hash != backhash
		commit.num = i
		$('.quakeplate.' + commit.branch).append _.template($('#quakemsg-template').text(), commit)
		backhash = commit.hash
	@
