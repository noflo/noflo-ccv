noflo = require 'noflo'
path = require 'path'
utils = require '../utils'

# @runtime noflo-nodejs
# @name SWTDetect

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'font'
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
    out: ['out', 'error']
    forwardGroups: true
    async: true
  , (canvas, groups, outPorts, callback) ->
    utils.writeCanvasTempFile canvas, (err, tmpFile) ->
      if canvas?.width? and canvas?.width < 0
        outPorts.error.send new Error "Image has negative value for width"
        do callback
        return
      if canvas?.height? and canvas?.height < 0
        outPorts.error.send new Error "Image has negative value for height"
        do callback
        return
      if err
        outPorts.error.send err
        do callback
        return
      bin = path.join __dirname, "../build/Release/swtdetect"
      cmd = "#{bin} #{tmpFile.path}"
      utils.runCmd cmd, tmpFile, (err, val) ->
        if err
          outPorts.error.send err
          do callback
          return
        outPorts.out.send val
        do callback
