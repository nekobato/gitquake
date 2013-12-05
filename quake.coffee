child_p = require 'child_process'
events = require 'events'
fs = require 'fs'
os = require 'os'

module.exports = (repository) ->

	branch: (callback) ->
		child_p.exec "cd #{repository} && git branch", (err, stdout, stderr) ->
			if ! err
				callback stdout
		@

	log: (branch, callback) ->
		child_p.exec "cd #{repository} && git log #{branch} --date=iso --pretty=format:'%h,%an,%ad,%s'", (err, stdout, stderr) ->
			if !err
				callback
					name: branch
					result: stdout.toString().split(os.EOL)
		@

	commit: (hash, callback) ->
		child_p.exec "cd #{repository} && git log #{hash} --date=iso -p", (err, stdout, stderr) ->
			if !err
				callback
					name: hash
					result: stdout.toString().split(os.EOL)
		@

	emitter: () ->
		ev = events.eventEmitter
		fs.watch "#{repository}/refs/heads/", (e, filename) ->
			child_p.exec "cd #{repository} && git log #{filename} --date=iso --pretty=format:'%h,%an,%ad,%s'", (err, stdout, stderr) ->
				ev.emit 'quake',
					name: filename
					log: stdout.toString().split(os.EOL)
			@
		ev