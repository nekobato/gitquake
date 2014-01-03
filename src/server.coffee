#!/usr/bin/env node

# Module dependencies.
GitQuake = require './lib/quake'
express = require 'express'
http  = require 'http'
path = require 'path'
os = require 'os'
_ = require 'underscore'

# Command Option
gitdir = process.argv[2]

# express
app = express()

app.set "port", process.env.PORT or 3006
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, "dist"))
app.use express.errorHandler()  if "development" is app.get("env")

# routes
server = http.createServer(app)

quake = new GitQuake("./test/repository")
events = quake.eventEmitter

app.get "/", (req, res) ->
	res.render 'index'

app.get "/branch", (req, res) ->
	quake.branch (result) ->
		res.send result

app.get "/show_branch/:branch", (req, res) ->
	quake.showBranch req.params.branch, (result) ->
		res.send result

app.get "/log/:branch", (req, res) ->
	quake.log req.params.branch, (result) ->
		res.send result

app.get "/commit/:hash", (req, res) ->
	quake.commit req.params.hash, (result) ->
		res.send result


server.listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")

# socket.io
io = require('socket.io').listen(server, {log: false})
	.on 'connection', (socket) ->
		console.info "connection appeared #{process.memoryUsage()}" #debug
		# TODO eventemitter

		#socket events
		socket.on 'disconnect', ->
			console.log 'client disconnected'
			@
		@