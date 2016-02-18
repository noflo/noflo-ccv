noflo = require 'noflo'
chai = require 'chai' unless chai
SCDDetect = require '../components/SCDDetect.coffee'
Canvas = require 'canvas'
Image = Canvas.Image
fs = require 'fs'

describe 'SCDDetect component', ->
  c = null
  ins = null
  cascade = null
  out = null
  error = null

  beforeEach ->
    c = SCDDetect.getComponent()
    ins = noflo.internalSocket.createSocket()
    cascade = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    error = noflo.internalSocket.createSocket()
    c.inPorts.canvas.attach ins
    c.inPorts.cascade.attach cascade
    c.outPorts.out.attach out
    c.outPorts.error.attach error

  describe 'when instantiated', ->
    it 'should have input ports', ->
      chai.expect(c.inPorts.canvas).to.be.an 'object'
      chai.expect(c.inPorts.cascade).to.be.an 'object'
    it 'should have output ports', ->
      chai.expect(c.outPorts.out).to.be.an 'object'
      chai.expect(c.outPorts.error).to.be.an 'object'

  describe 'when image loaded', ->
    @timeout 10000
    canvas = null
    img = null
    beforeEach (done) ->
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
      @timeout 15000
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

      it 'should find faces', ->
        chai.expect(results).to.be.an 'array'
        chai.expect(results.length).to.gte 0
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

  describe 'when another canvas sent', ->
    it 'should find faces', (done) ->
      @timeout 15000
      grps = []
      out.on 'begingroup', (grp) ->
        grps.push grp
      out.once "data", (data) ->
        results = data
        chai.expect(results).to.be.an 'array'
        chai.expect(results.length).to.gte 0
        chai.expect(grps.length).to.equal 1
        done()
      fs.readFile __dirname+'/hqdefault.jpg', (err, image) ->
        if err
          return done err
        img = new Image
        img.src = image
        canvas = new Canvas img.width, img.height
        canvas.getContext('2d').drawImage(img, 0, 0)

        ins.beginGroup 'foo'
        ins.send canvas
