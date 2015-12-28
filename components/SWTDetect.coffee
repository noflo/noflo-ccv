noflo = require 'noflo'
temporary = require 'temporary'
fs = require 'fs'
path = require 'path'
exec = require('child_process').exec

# @runtime noflo-nodejs
# @name SWTDetect

compute = (canvas, callback) ->
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
      # Delay it a bit to avoid premature stream ending
      setTimeout () ->
        onEnd tmpFile, callback
      , 100
    catch e
      callback e
      tmpFile.unlink()

onEnd = (tmpFile, callback) ->
  bin = path.join __dirname, '../build/Release/swtdetect'
  exec "#{bin} #{tmpFile.path}", (err, stdout, stderr) ->
    if stderr
      callback stderr
      tmpFile.unlink()
      return
    if err
      callback err
      tmpFile.unlink()
      return
    else
      out = JSON.parse stdout
      callback null, out
      tmpFile.unlink()

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'smile-o'
  c.description = 'Stroke Width Transform text detector'

  c.inPorts.add 'canvas',
    datatype: 'object'
    description: 'Canvas of image to be detected'

  c.outPorts.add 'out',
    datatype: 'object'
    description: 'Bounding boxes of detected text'
  c.outPorts.add 'error',
    datatype: 'object'
    required: false

  noflo.helpers.WirePattern c,
    in: 'canvas'
    out: 'out'
    forwardGroups: true
    async: true
  , (payload, groups, out, callback) ->
    compute payload, (err, val) ->
      return callback err if err
      out.send val
      do callback
  c
