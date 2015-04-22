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
    @timeout 5000
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

    describe 'when canvas sent', ->
      grps = []
      results = null

      before (done) ->
        grps = []
        out.on 'begingroup', (grp) ->
          grps.push grp
        out.once "data", (data) ->
          results = data
          done()
        ins.beginGroup 'foo'
        ins.send canvas

      it 'should find 15 faces', ->
        chai.expect(results).to.be.an 'array'
        chai.expect(results.length).to.equal 15
        chai.expect(grps.length).to.equal 1

      it 'should sort faces by confidence', ->
        chai.expect(results[0].confidence).to.be.at.least results[1].confidence
        chai.expect(results[1].confidence).to.be.at.least results[2].confidence
        chai.expect(results[2].confidence).to.be.at.least results[3].confidence
        chai.expect(results[3].confidence).to.be.at.least results[4].confidence


  unless noflo.isBrowser()
    describe 'when 1x1 image loaded', ->
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
          img.src = '1x1.gif'
        else
          fs.readFile __dirname+'/1x1.gif', (err, image) ->
            if err
              return done err
            img = new Image
            img.src = image
            canvas = new Canvas img.width, img.height
            canvas.getContext('2d').drawImage(img, 0, 0)
            done()

      it 'should have correct image and canvas size', ->
        chai.expect(img.width).to.equal 1
        chai.expect(img.height).to.equal 1
        chai.expect(canvas.width).to.equal 1
        chai.expect(canvas.height).to.equal 1

      describe 'when canvas sent', ->
        grps = []
        results = null

        before (done) ->
          grps = []
          out.on 'begingroup', (grp) ->
            grps.push grp
          out.once "data", (data) ->
            results = data
            done()
          ins.beginGroup 'foo'
          ins.send canvas

        it 'should find no faces', ->
          chai.expect(results).to.be.an 'array'
          chai.expect(results.length).to.equal 0
          chai.expect(grps.length).to.equal 1

