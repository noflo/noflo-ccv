noflo = require 'noflo'
temporary = require 'temporary'
fs = require 'fs'
path = require 'path'
exec = require('child_process').exec
utils = require '../utils'

# @runtime noflo-nodejs
# @name SCDDetect

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
    out: ['out', 'error']
    forwardGroups: true
    async: true
  , (canvas, groups, outPorts, callback) ->
    if not c.params.cascade
      cascade = path.join __dirname, '../cascades/face.sqlite3'
    else
      cascade = c.params.cascade
    utils.writeCanvasTempFile canvas, (err, tmpFile) ->
      if err
        if err.code is 'ENOMEM'
          console.log 'SCDDetect ERROR, sending empty faces', err
          outPorts.out.send []
          do callback
          return
        outPorts.error.send err
        do callback
        return
      cmd = path.join __dirname, "../build/Release/scddetect"
      utils.runCmd cmd, tmpFile, cascade, (err, val) ->
        if err
          outPorts.error.send err
          do callback
          return
        outPorts.out.send val
        do callback
