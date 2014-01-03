(function() {
  var GitQuake, app, events, express, gitdir, http, io, os, path, quake, server, _;

  GitQuake = require('./lib/quake');

  express = require('express');

  http = require('http');

  path = require('path');

  os = require('os');

  _ = require('underscore');

  gitdir = process.argv[2];

  app = express();

  app.set("port", process.env.PORT || 3006);

  app.set("views", __dirname + "/views");

  app.set("view engine", "jade");

  app.use(express.favicon());

  app.use(express.logger("dev"));

  app.use(express.bodyParser());

  app.use(express.methodOverride());

  app.use(app.router);

  app.use(express["static"](path.join(__dirname, "dist")));

  if ("development" === app.get("env")) {
    app.use(express.errorHandler());
  }

  server = http.createServer(app);

  quake = new GitQuake("./test/repository");

  events = quake.eventEmitter;

  app.get("/", function(req, res) {
    return res.render('index');
  });

  app.get("/branch", function(req, res) {
    return quake.branch(function(result) {
      return res.send(result);
    });
  });

  app.get("/show_branch/:branch", function(req, res) {
    return quake.showBranch(req.params.branch, function(result) {
      return res.send(result);
    });
  });

  app.get("/log/:branch", function(req, res) {
    return quake.log(req.params.branch, function(result) {
      return res.send(result);
    });
  });

  app.get("/commit/:hash", function(req, res) {
    return quake.commit(req.params.hash, function(result) {
      return res.send(result);
    });
  });

  server.listen(app.get("port"), function() {
    return console.log("Express server listening on port " + app.get("port"));
  });

  io = require('socket.io').listen(server, {
    log: false
  }).on('connection', function(socket) {
    console.info("connection appeared " + (process.memoryUsage()));
    socket.on('disconnect', function() {
      console.log('client disconnected');
      return this;
    });
    return this;
  });

}).call(this);
