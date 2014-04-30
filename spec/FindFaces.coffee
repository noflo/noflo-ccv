noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  FindFaces = require '../components/FindFaces-node.coffee'
  Canvas = require 'canvas'
  Image = Canvas.Image
  fs = require 'fs'
else
  FindFaces = require 'noflo-ccv/components/FindFaces.js'

describe 'FindFaces component', ->
  c = null
  ins = null
  out = null

  beforeEach ->
    c = FindFaces.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.outPorts.faces.attach out

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.faces).to.be.an 'object'

  describe 'when image loaded', ->
    canvas = null
    img = null
    beforeEach (done) ->
      # load image, copy to canvas
      if noflo.isBrowser()
        img = document.createElement('image')
        canvas = document.createElement('canvas')
        img.onerror = (err) ->
          done(err)
        img.onload = () ->
          canvas.width = img.width
          canvas.height = img.height
          canvas.getContext('2d').drawImage(img, 0, 0)
          done()
        img.src = 'being-d4.jpg'
      else
        fs.readFile __dirname+'/being-d4.jpg', (err, image) ->
          if err
            return done err
          img = new Image
          img.src = image
          canvas = new Canvas img.width, img.height
          canvas.getContext('2d').drawImage(img, 0, 0)
          done()

    it 'should have correct image and canvas size', ->
      chai.expect(img.width).to.equal 1439
      chai.expect(img.height).to.equal 960
      chai.expect(canvas.width).to.equal 1439
      chai.expect(canvas.height).to.equal 960

    it 'should send canvas and find 15 faces', ->
      out.once "data", (data) ->
        chai.expect(data).to.be.an 'array'
        chai.expect(data.length).to.equal 15
      ins.send canvas
