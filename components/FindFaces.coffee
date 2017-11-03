noflo = require 'noflo'
ccv = require 'ccv'

# @runtime noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Finds faces from a canvas or img element.'
  c.icon = 'smile-o'
  c.inPorts.add 'in',
    datatype: 'object'
  c.outPorts.add 'faces',
    datatype: 'array'
  c.forwardBrackets =
    in: ['faces']
  c.process (input, output) ->
    return unless input.hasData 'in'
    data = input.getData 'in'
    result = ccv.detect_objects
      canvas: data,
      cascade: 'face',
      interval: 5,
      min_neighbors: 1
    result.sort (a,b) -> return b.confidence-a.confidence
    for face in result
      face.x = Math.round face.x
      face.y = Math.round face.y
      face.width = Math.round face.width
      face.height = Math.round face.height
    output.sendDone
      faces: result
