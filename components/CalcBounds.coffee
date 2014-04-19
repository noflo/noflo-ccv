noflo = require 'noflo'

class CalcBounds extends noflo.Component
  description: 'Calculates the bounds of an array of rectangles'
  icon: 'crop'
  constructor: ->
    @inPorts = new noflo.InPorts
      rectangles:
        datatype: 'array'
    @outPorts = new noflo.OutPorts
      bounds:
        datatype: 'object'
        description: 'minX, minY, maxX, maxY, width, height, ratio'

    @inPorts.rectangles.on "data", (data) =>
      #TODO error handling
      return unless data.length and @outPorts.bounds.isAttached()

      dims =
        minX: Infinity
        minY: Infinity
        maxX: -Infinity
        maxY: -Infinity
        width: 0
        height: 0
        ratio: 1

      for rect in data
        if rect.x?
          if dims.minX > rect.x
            dims.minX = rect.x
          if dims.minY > rect.y
            dims.minY = rect.y
          if dims.maxX < rect.x+rect.width
            dims.maxX = rect.x+rect.width
          if dims.maxY < rect.y+rect.height
            dims.maxY = rect.y+rect.height
        else if rect[0]? # array-type rectangles
          if dims.minX > face[0]
            dims.minX = face[0]
          if dims.minY > face[1]
            dims.minY = face[1]
          if dims.maxX < face[0]+face[2]
            dims.maxX = face[0]+face[2]
          if dims.maxY < face[1]+face[3]
            dims.maxY = face[1]+face[3]

      return unless isFinite(dims.minX) and isFinite(dims.minY) and isFinite(dims.maxX) and isFinite(dims.maxY)

      dims.minX = Math.round(dims.minX)
      dims.minY = Math.round(dims.minY)
      dims.maxX = Math.round(dims.maxX)
      dims.maxY = Math.round(dims.maxY)
      dims.width = dims.maxX - dims.minX
      dims.height = dims.maxY - dims.minY
      dims.ratio = dims.width/dims.height

      @outPorts.bounds.send(dims)


exports.getComponent = -> new CalcBounds
