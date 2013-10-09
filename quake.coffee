module.exports = 
QuakeMonitor = (repository) ->
	eEmitter = new events.EventEmitter
	console.info 'start monitoring'
	fs.watch "#{repository}/refs/heads/", (e, filename) ->
		console.info "#{filename} : #{e}"
		if e is 'rename'
			exec "cd #{repository} && git log #{filename} --date=iso --pretty=format:'%h,%an,%ad,%s'", (err, stdout, stderr) ->
				eEmitter.emit 'uplift',
					name: filename
					log: stdout.toString().split(os.EOL)
		else
			exec "cd #{repository} && git show #{filename} --date=iso --pretty=format:'%h,%an,%ad,%s'", (err, stdout, stderr) ->
				eEmitter.emit 'quake',
					name: filename
					log: stdout.toString().split(os.EOL)
			@
		@
	eEmitter