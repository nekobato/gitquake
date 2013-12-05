#!/usr/bin/env node

"use strict"

# Module dependencies.
GitQuake = require './quake'
express = require 'express'
path = require 'path'
os = require 'os'
_ = require 'underscore'

# Command Option
gitdir = process.argv[2]

gq = new GitQuake("./test/repository")
gqEmitter = gq.emitter()

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

server = require('http').createServer(app)

# routes
app.get "/", (req, res) ->
	res.render 'index'
	@
app.get "/branch", (req, res) ->
	gq.branch (result) ->
		res.send result
	@
app.get "/log/:branch", (req, res) ->
	console.log req.params.branch
	gq.log req.params.branch, (result) ->
		res.send result
	@
app.get "/commit/:hash", (req, res) ->
	gq.commit req.params.hash, (result) ->
		res.send result
	@

server.listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")

# socket.io
io = require('socket.io').listen server, {log: false}
io.on 'connection', (socket) ->
	console.info 'connection appeared'
	console.info process.memoryUsage() #debug
	# gq events
	gqEmitter.on 'quake', (data)->
		socket.emit 'quake', data
		@
	gqEmitter.on 'heartbeat', (data) ->
		console.log data
		@
	#socket events
	socket.on 'disconnect', ->
		console.log 'client disconnected'
		@
	@