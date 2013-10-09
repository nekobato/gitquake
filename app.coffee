
###
Module dependencies.
###
express = require("express")
routes = require("./routes")
http = require("http")
path = require("path")
app = express()
fs = require("fs")
os = require("os")
exec = require("child_process").exec
socketio = require("socket.io")
events = require('events')
async = require('async')
__ = require('underscore')

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

repository = './test/repository'

# routes
app.get "/", routes.index

server = http.createServer(app)
server.listen app.get("port"), ->
  console.info "Express server listening on port " + app.get("port")

# monitor git
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

# log history
monitor = new QuakeMonitor(repository)

# socket.io
io = socketio.listen(server, {log: false})
io.on 'connection', (socket) ->
	console.info 'connection appeared'

	fs.readdir "#{repository}/refs/heads/", (err, files) ->
		async.each files, (file, res) ->
			exec "cd #{repository} && git log #{file} --date=iso --pretty=format:'%h,%an,%ad,%s'", (err, stdout, stderr) ->
				socket.emit 'log',
					name: file
					log: stdout.toString().split(os.EOL)

	console.log process.memoryUsage() #debug

	monitor.on 'quake', (data)->
		socket.emit 'quake', data
		@

	monitor.on 'uplift', (data) ->
		socket.emit 'uplift', data
		@

	socket.on 'disconnect', ->
		console.log 'client disconnected'
		@
	@
