noflo = require 'noflo'
ccv = require 'ccv'

class FindFaces extends noflo.Component
  constructor: ->
    @inPorts =
      canvas: new noflo.Port 'object'
    @outPorts =
      faces: new noflo.Port 'array'

    @inPorts.canvas.on "data", (data) =>
      result = ccv.detect_objects
        "canvas": data,
        "interval" : 5,
        "min_neighbors" : 1
      @outPorts.faces.send result

exports.getComponent = -> new FindFaces
