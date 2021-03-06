_       = require "lodash"
ws      = require "ws"
uid     = require "uid"
http    = require "http"
express = require "express"

{ Station }    = require "../../models"
{ log, config} = require "../../utils"


module.exports = router = do express.Router

server = http.createServer()
server.listen config.get("streaming:port"), (err) ->
  log.info "Streaming server started on port #{config.get('streaming:port')}"

defaults =
  width  : 640
  height : 360

streams = require "./clients"
sockets = {}


# WebSocket server
socketServer = new ws.Server
  server : server

socketServer.on "connection", (socket) ->
  stationName = socket.upgradeReq.url.substring(1)

  station = streams[ stationName ]
  if not station?
    log.warn "The station #{stationName} isn't streaming"
    return do socket.close

  STREAM_MAGIC_BYTES = 'jsmp' # Must be 4 bytes
  streamHeader = new Buffer(8)
  streamHeader.write STREAM_MAGIC_BYTES
  streamHeader.writeUInt16BE station.width, 4
  streamHeader.writeUInt16BE station.height, 6

  socket.send streamHeader,
    binary : true

  id = uid 24

  if not sockets[stationName]?
    sockets[stationName] = {}
  sockets[stationName][id] = socket

  socket.on "close", (code, message) ->
    delete sockets[stationName][id]


# HTTP Server to accept incomming MPEG Stream
router.all "/:name/:secret/:width/:height", (req, res, next) ->
  width  = req.params.width  ? defaults.width
  height = req.params.height ? defaults.height

  Station.findOne({ name : req.params.name })
  .exec (err, station) ->
    if err
      return next new Error "Database error #{err}"

    if not station?
      return next new Error "No such station!"

    if station.secret != req.params.secret
      return next new Error "Wrong secret!"

    if _.has streams, station.name
      return next new Error "The station is already streaming!"

    log.info "Streaming client ##{station.name} connected: #{width}x#{height}"

    streams[station.name] =
      width  : width
      height : height

    req.on "data", (data) ->
      # Broadcast to all
      if _.has sockets, station.name
        _.each sockets[ station.name ], (socket) ->
          socket.send data,
            binary : true

    # Close the connection when it's not active during the timeout
    req.setTimeout config.get("streaming:timeout"), ->
      log.warn "Timeout event for streaming client ##{station.name} fired"
      do req.socket.destroy

    req.on "close", ->
      log.info "Streaming client ##{station.name} disconnected"
      delete streams[ station.name ]
      do res.end

