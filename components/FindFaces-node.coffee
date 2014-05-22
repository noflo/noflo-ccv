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

    @inPorts.in.on 'begingroup', (group) =>
      @outPorts.faces.beginGroup group
    @inPorts.in.on "data", (data) =>
      result = ccv.detect_objects
        canvas: data,
        interval: 5,
        min_neighbors: 1
      @outPorts.faces.send result
    @inPorts.in.on 'endgroup', =>
      @outPorts.faces.endGroup()
    @inPorts.in.on 'disconnect', =>
      @outPorts.faces.disconnect()

exports.getComponent = -> new FindFaces
