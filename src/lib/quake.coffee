child_p = require 'child_process'
events = require 'events'
fs = require 'fs'
os = require 'os'

GitQuake = (repo) ->

  @repo = repo

GitQuake.prototype.branch = (callback) ->
  child_p.exec "cd #{@repo} && git branch", (err, stdout, stderr) ->
    throw err if err

    res = []

    branches = stdout.toString().split(os.EOL)
    branches.pop()
    for i in branches
      res.push { branch: i.slice(2) }

    callback res
  @

GitQuake.prototype.showBranch = (branch, callback) ->
  child_p.exec "cd #{@repo} && git show-branch --merge-base #{branch}", (err, stdout, stderr) ->
    throw err if err

    callback stdout.toString()
  @

GitQuake.prototype.log = (branch, callback) ->
  child_p.exec "cd #{@repo} && git log #{branch} --date=iso --pretty=format:'%h,%an,%ad,%s'", (err, stdout, stderr) ->
    throw err if err
    logs = []
    for line in stdout.toString().split(os.EOL)
      match = line.match /^(.+),(.+),(.+),(.+)/
      logs.push
        hash: RegExp.$1
        author: RegExp.$2
        time: RegExp.$3
        message: RegExp.$4

    callback { branch: branch, result: logs }
  @

GitQuake.prototype.commit = (hash, callback) ->
  child_p.exec "cd #{@repo} && git show #{hash} --date=iso -p --pretty=format:'%b'", (err, stdout, stderr) ->
    throw err if err
    commits = []
    for line in stdout.toString().split(os.EOL)
      commits.push RegExp.$1 if line.match /^@@(.+)@@$/

    callback { name: hash, result: commits }
  @

module.exports = GitQuake