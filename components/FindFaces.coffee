noflo = require 'noflo'
ccv = require 'ccv'

# @runtime noflo-browser

class FindFaces extends noflo.Component
  description: 'Finds faces from a canvas or img element.'
  icon: 'smile-o'
  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
    @outPorts =
      faces: new noflo.Port 'array'

    @inPorts.in.on 'begingroup', (group) =>
      @outPorts.faces.beginGroup group
    @inPorts.in.on "data", (data) =>
      result = ccv.detect_objects
        canvas: data,
        cascade: 'face',
        interval: 5,
        min_neighbors: 1
      result.sort (a,b) -> return b.confidence-a.confidence
      @outPorts.faces.send result
    @inPorts.in.on 'endgroup', =>
      @outPorts.faces.endGroup()
    @inPorts.in.on 'disconnect', =>
      @outPorts.faces.disconnect()

exports.getComponent = -> new FindFaces
