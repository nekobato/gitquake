
###
Module dependencies.
###
express = require("express")
routes = require("./routes")
user = require("./routes/user")
http = require("http")
path = require("path")
app = express()
fs = require("fs")
os = require("os")
exec = require("child_process").exec
socketio = require("socket.io")
events = require('events')
async = require('async')

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

# server
server = http.createServer(app)
server.listen app.get("port"), ->
  console.info "Express server listening on port " + app.get("port")

# monitor git
QuakeMonitor = () ->
	eEmitter = new events.EventEmitter
	console.info 'start monitoring'
	fs.watch "#{repository}/refs/heads/", (e, filename) ->
		exec "cd #{repository} && git show #{filename} --pretty=format:'%h,%an,%ad,%s'", (err, stdout, stderr) ->
			stdout.toString().match /^(.+),(.+),(.+),(.+)(\n|\r)/
			info =
				branch: filename
				hash: RegExp.$1
				author: RegExp.$2
				date: RegExp.$3
				msg: RegExp.$4
			console.log info
			eEmitter.emit('quake', info) if info
			@
		@
	eEmitter

monitor = new QuakeMonitor()

# log history
History = () ->
	logs = []
	fs.readdir "#{repository}/refs/heads/", (err, files) ->
		async.each files, (file, res) ->
			exec "cd #{repository} && git log #{file} --date=iso --pretty=format:'%h,%an,%ad,%s'", (err, stdout, stderr) ->
				logs.push
					name: file
					log: stdout.toString().split(os.EOL)
	logs

logs = new History()

# socket.io
io = socketio.listen(server, {log: false})
io.on 'connection', (socket) ->
	console.info 'connection appeared'
	socket.emit 'logs', logs
	# TODO get all branch's latest 20 commit log in each connection
	monitor.on 'quake', (data)->
		socket.emit 'quake', data
		@
	socket.on 'disconnect', ->
		console.log 'client disconnected'
		@
	@
