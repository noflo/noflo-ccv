noflo = require 'noflo'
ccv = require 'ccv'

class FindFaces extends noflo.Component
  description: 'Finds faces from a canvas or img element.'
  icon: 'smile-o'
  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
    @outPorts =
      faces: new noflo.Port 'array'

    @inPorts.in.on "data", (data) =>
      result = ccv.detect_objects
        canvas: data,
        cascade: 'face',
        interval: 5,
        min_neighbors: 1
      @outPorts.faces.send result

exports.getComponent = -> new FindFaces
