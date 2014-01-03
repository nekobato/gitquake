hash_history = {}

# Call APIs
Git = () ->
Git.prototype.branch = (callback) ->
	$.ajax({url: '/branch', dataType: 'json'})
	.done (data) ->
		callback(data)
Git.prototype.show = (hash, callback) ->
	$.ajax({url: "/commit/#{hash}", dataType: 'json'})
	.done (data) ->
		callback(data)
Git.prototype.log = (branch, callback) ->
	$.ajax({url: "/log/#{branch}", dataType: 'json'})
	.done (data) ->
		callback(data)
git = new Git

# Views
View = () ->
View.prototype.branch = (data) ->
	$('#table-branch').append _.template($('#git-branch').text(), data)
View.prototype.log = (data) ->
	$('#table-log').append _.template($('#git-log').text(), data)
view = new View

# Logs
Log = () ->
Log.prototype.branch = (data, callback) ->
	for i in data
		callback i
Log.prototype.log = (data, callback) ->
	return false if not data.result
	for i in data.result
		log[i.hash] = i.time if not log[i.hash]
log = new Log

git.branch (data) ->
	for branch in data
		git.log branch, (data) ->
			hash_history.push {data.result}
		# push commits to log

