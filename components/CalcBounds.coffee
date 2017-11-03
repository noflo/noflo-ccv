noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Calculates the bounds of an array of rectangles'
  c.icon = 'crop'
  c.inPorts.add 'rectangles',
    datatype: 'array'
  c.outPorts.add 'bounds',
    datatype: 'object'
    description: 'minX, minY, maxX, maxY, width, height, ratio'
  c.forwardBrackets =
    rectangles: ['bounds']
  c.process (input, output) ->
    return unless input.hasData 'rectangles'
    data = input.getData 'rectangles'
    unless data.length
      #TODO error handling
      output.done()
      return

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

    unless isFinite(dims.minX) and isFinite(dims.minY) and isFinite(dims.maxX) and isFinite(dims.maxY)
      output.done()
      return

    dims.minX = Math.round(dims.minX)
    dims.minY = Math.round(dims.minY)
    dims.maxX = Math.round(dims.maxX)
    dims.maxY = Math.round(dims.maxY)
    dims.width = dims.maxX - dims.minX
    dims.height = dims.maxY - dims.minY
    dims.ratio = dims.width/dims.height

    output.sendDone
      bounds: dims
