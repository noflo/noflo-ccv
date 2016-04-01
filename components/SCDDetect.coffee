noflo = require 'noflo'
temporary = require 'temporary'
fs = require 'fs'
path = require 'path'
exec = require('child_process').exec

# @runtime noflo-nodejs
# @name SCDDetect

writeCanvasTempFile = (canvas, callback) ->
  tmpFile = new temporary.File

  rs = canvas.pngStream()
  ws = fs.createWriteStream tmpFile.path
  rs.once 'error', (error) ->
    callback error
    tmpFile.unlink()
    return
  ws.once 'error', (error) ->
    callback error
    tmpFile.unlink()
    return
  ws.once 'open', (fd) ->
    if fd < 0
      callback new Error 'Bad file descriptor'
      tmpFile.unlink()
      return
    ws.once 'close', ->
      fs.fsync fd, ->
        try
          callback null, tmpFile
        catch error
          callback error
          tmpFile.unlink()
  rs.pipe ws

runScdDetect = (tmpFile, cascade, callback) ->
  bin = path.join __dirname, '../build/Release/scddetect'
  exec "#{bin} #{tmpFile.path} #{cascade}", (err, stdout, stderr) ->
    if err
      callback err
      tmpFile.unlink()
      return
    else
      out = JSON.parse stdout
      if out.length > 1
        out.sort (a,b) -> return b.confidence-a.confidence
      callback null, out
      tmpFile.unlink()

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'smile-o'
  c.description = 'SURF-Cascade Detection'

  c.inPorts.add 'canvas',
    datatype: 'object'
    description: 'Canvas of image to be detected'
  c.inPorts.add 'cascade',
    datatype: 'string'
    description: 'The file that contains a SCD classifier cascade (sqlite3)'

  c.outPorts.add 'out',
    datatype: 'object'
    description: 'Bounding boxes of detected faces'
  c.outPorts.add 'error',
    datatype: 'object'
    required: false

  noflo.helpers.WirePattern c,
    in: 'canvas'
    params: 'cascade'
    out: 'out'
    forwardGroups: true
    async: true
  , (canvas, groups, out, callback) ->
    if not c.params.cascade
      cascade = path.join __dirname, '../cascades/face.sqlite3'
    else
      cascade = c.params.cascade
    writeCanvasTempFile canvas, (err, tmpFile) ->
      if err
        if err.code is 'ENOMEM'
          console.log 'SCDDetect ERROR, sending empty faces', err
          out.send []
          do callback
          return
        return callback err
      return callback err if err
      runScdDetect tmpFile, cascade, (err, val) ->
        return callback err if err
        out.send val
        do callback

  c
