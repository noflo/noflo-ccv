noflo = require 'noflo'
ccv = require 'face-detect'

# @runtime noflo-nodejs
# @name FindFaces

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'smile-o'
  c.description = 'Finds faces from a canvas element.'

  c.inPorts.add 'in',
    datatype: 'object'
  c.outPorts.add 'faces',
    datatype: 'array'

  noflo.helpers.WirePattern c,
    in: 'in'
    out: 'faces'
    forwardGroups: true
    async: true
  , (data, groups, out, callback) ->
    result = ccv.detect_objects
      canvas: data,
      interval: 5,
      min_neighbors: 1
    result.sort (a,b) -> return b.confidence-a.confidence
    for face in result
      face.x = Math.round face.x
      face.y = Math.round face.y
      face.width = Math.round face.width
      face.height = Math.round face.height
    out.send result
    do callback

  c
