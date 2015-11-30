noflo = require 'noflo'
temporary = require 'temporary'
fs = require 'fs'
path = require 'path'
exec = require('child_process').exec

# @runtime noflo-nodejs
# @name SCDDetect

compute = (canvas, cascade, callback) ->
  # Get canvas
  ctx = canvas.getContext '2d'
  imageData = ctx.getImageData 0, 0, canvas.width, canvas.height
  data = imageData.data

  tmpFile = new temporary.File
  out = fs.createWriteStream tmpFile.path
  stream = canvas.pngStream()
  stream.on 'data', (chunk) ->
    out.write(chunk)
  stream.on 'end', () ->
    try
      onEnd tmpFile, cascade, callback
    catch e
      callback e
      tmpFile.unlink()

onEnd = (tmpFile, cascade, callback) ->
  bin = path.join __dirname, '../build/Release/scddetect'

  exec "#{bin} #{tmpFile.path} #{cascade}", (err, stdout, stderr) ->
    tmpFile.unlink()
    if err
      callback err
    else
      out = JSON.parse stdout
      if out.length > 1
        out.sort (a,b) -> return b.confidence-a.confidence
      callback null, out

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
  , (payload, groups, out, callback) ->
    if not c.params.cascade
      cascade = path.join __dirname, '../cascades/face.sqlite3'
    else
      cascade = c.params.cascade
    compute payload, cascade, (err, val) ->
      return callback err if err
      out.send val
      do callback
  c
