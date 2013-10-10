#!/usr/bin/env node

# Module dependencies.
path   = require("path")
fs     = require("fs")
os     = require("os")
exec   = require("child_process").exec
events = require('events')
async  = require('async')
__     = require('underscore')

# Command Option
gitdir = process.argv[2]


express = require('express')
app     = express()
server  = require('http').createServer(app)

# all environments
app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, "public"))
app.use express.errorHandler()  if "development" is app.get("env")

server.listen(app.settings.port)

# routes
routes = require("./routes")
app.get "/", routes.index


# monitor git

emitquake = (file) ->
	exec "cd #{gitdir} && git log #{file} --date=iso --pretty=format:'%h,%an,%ad,%s'", (err, stdout, stderr) ->
		if ! stderr
			emitter.emit 'quake',
				name: file
				log: stdout.toString().split(os.EOL)
			@

QuakeMonitor = (gitdir) ->
	fs.watch "#{gitdir}/refs/heads/", (e, filename) ->
		console.info "#{filename} : #{e}" # info
		emitquake(filename)
	

emitter = new events.EventEmitter
monitor = new QuakeMonitor(gitdir)

# socket.io
io = require('socket.io').listen server, {log: false}
io.on 'connection', (socket) ->

	console.log process.memoryUsage() #debug

	# on connection
	console.info 'connection appeared'
	fs.readdir "#{gitdir}/refs/heads/", (err, files) ->
		async.each files, (file, res) ->
			emitquake(file)
	
	# on quake
	emitter.on 'quake', (data)->
		socket.emit 'quake', data
		@

	# on disconnect
	socket.on 'disconnect', ->
		console.log 'client disconnected'
		@
	@
