logErrors = (err, req, res, next) ->
  console.error err.stack
  next err

clientErrorHandler = (err, req, res, next) ->
  if req.xhr
    res.send 500,
      error: "Something blew up!"

  else
    next err

errorHandler = (err, req, res, next) ->
  res.status 500
  res.render "error",
    error: err

mime = require("mime")
express = require("express")
reload = require("reload")
livereload = require("express-livereload")
path = require("path")
ffmpeg = require("fluent-ffmpeg")
reload = require("reload")
livereload = require("express-livereload")

app = express()

app.configuration = require('config.json')('./config.json')

app.locals.version = "0.1.0"

app.is_prod = app.configuration.is_prod
app.base = "http://localhost:7777"

viewsDir = path.join(__dirname, "views")

app.set "views", viewsDir
app.set "view engine", "ejs"
app.use(express.favicon())
app.use(express.logger('dev'))
app.use(express.static(__dirname + '/flowplayer'))

basicAuthMessage = 'Restrict area, please identify'

basicAuth = express.basicAuth( (username, password) ->
  return username is app.configuration.admin.user and app.configuration.admin.password is password
, basicAuthMessage)


app.get "/", basicAuth, (req,res) ->
  res.render 'index'

app.get "/video/:filename", basicAuth, (req, res) ->
  pathToMovie = "/home/malix/files/" + req.params.filename
  #type = mime.lookup(pathToMovie)
  #res.contentType type
  res.contentType('flv')
  proc = new ffmpeg(
    source: pathToMovie
    nolog: false
  ).usingPreset("flashvideo").writeToStream(res, (retcode, error) ->
    console.log ["conversion", retcode, error]
  )

app.use app.router
app.use logErrors
app.use clientErrorHandler
app.use errorHandler


port = process.env.PORT or 7777
server = require("http").createServer(app)
reload server, app, 1000


server.listen port, ->
  unless app.is_prod
    console.log "enabling live reload"
    livereload app, config =
      watchDir: viewsDir
      applyJSLive: true
  console.log "Server version #{app.locals.version} listening on " + port
