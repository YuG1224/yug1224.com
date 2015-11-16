bodyParser = require "body-parser"
cookieParser = require "cookie-parser"
compression = require "compression"
# csrf = require "csrf"
express = require "express"
fs = require "fs"
http = require "http"
# moment = require "moment"
path = require "path"

config = require "#{__dirname}/config"


app = express()
server = http.createServer app

app.set "port", config.port
app.set "views", "#{__dirname}/views"
app.set "view engine", "jade"
app.set "x-powered-by", false
app.use compression
  level: 1
app.use bodyParser.json()
app.use bodyParser.urlencoded
  extended: true
app.use cookieParser()

# # csrf対策
# app.use csrf()
# app.use (err, req, res, next) ->
#   if err.code isnt "EBADCSRFTOKEN"
#     return next err
#   res.status 403
#     .send "session has expired or form tampered with"
#   return
# app.use (req, res, next) ->
#   res.csrfToken = req.csrfToken()
#   next()
#   return

# 昔のURLをリダイレクト
redirect = require "./routes/redirect"
app.use (req, res, next) ->
  if (req.method in ["GET", "HEAD"]) && redirect[req.url]
    res.redirect 301, "/archives#{redirect[req.url]}"
  next()
  return

# URLルーティング
pages = require "./routes/pages"
archives = require "./routes/archives"
categories = require  "./routes/categories"
xml = require "./routes/xml"

app.get "/", pages.show
app.get "/pages/:page", pages.show
app.get "/archives", archives.index
app.get "/archives/:_id", archives.show
app.get "/categories/:category", categories.show
app.get "/atom.xml", xml.atom
app.get "/sitemap.xml", xml.sitemap

# APIルーティング
# files = []
# for val in fs.readdirSync "#{__dirname}/routes/v0"
#   files.push val.replace /\.js$/, ""
# for val in files
#   api = require "#{__dirname}/routes/v0/#{val}"
#   if api.index then app.get "/v0/#{val}", api.index
#   if api.new then app.get "/v0/#{val}/new", api.new
#   if api.create then app.post "/v0/#{val}", api.create
#   if api.show then app.get "/v0/#{val}/:id", api.show
#   if api.edit then app.get "/v0/#{val}/:id/edit", api.edit
#   if api.update then app.put "/v0/#{val}/:id", api.update
#   if api.destroy then app.delete "/v0/#{val}/id", api.destroy

app.use express.static "#{__dirname}/../dist"

server.listen app.get("port"), ->
  console.log "Server listen on port #{app.get('port')}"
  return
