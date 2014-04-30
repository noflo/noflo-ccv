noflo = require 'noflo'
ccv = require 'face-detect'
#Canvas = require 'canvas'

class FindFaces extends noflo.Component
  description: 'Finds faces from a canvas element.'
  icon: 'smile-o'
  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
      #url: new noflo.Port 'string' #TODO
    @outPorts =
      faces: new noflo.Port 'array'

    @inPorts.in.on "data", (data) =>
      result = ccv.detect_objects
        canvas: data,
        interval: 5,
        min_neighbors: 1
      @outPorts.faces.send result

exports.getComponent = -> new FindFaces
