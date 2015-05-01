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
    @timeout 10000
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
        it.skip 'should find the right faces', ->
          expected = [
            x: 492,
            y: 268,
            width: 57,
            height: 57,
            neighbors: 7,
            confidence: 11.28613306999998
          ,
            x: 367,
            y: 271,
            width: 56,
            height: 56,
            neighbors: 8,
            confidence: 11.188660410000004
          ,
            x: 172,
            y: 295,
            width: 57,
            height: 57,
            neighbors: 5,
            confidence: 8.33351699000001
          ,
            x: 993,
            y: 508,
            width: 62,
            height: 62,
            neighbors: 5,
            confidence: 5.652669490000009
          ,
            x: 296,
            y: 477,
            width: 65,
            height: 65,
            neighbors: 8,
            confidence: 5.49484601000000
          ,
            x: 485,
            y: 353,
            width: 55,
            height: 55,
            neighbors: 6,
            confidence: 4.98707517000000
          ,
            x: 646,
            y: 254,
            width: 58,
            height: 58,
            neighbors: 2,
            confidence: 2.481149969999999
          ,
            x: 590,
            y: 441,
            width: 69,
            height: 69,
            neighbors: 3,
            confidence: 2.256392189999995
          ,
            x: 461,
            y: 502,
            width: 61,
            height: 61,
            neighbors: 6,
            confidence: 1.986859089999997
          ,
            x: 1222,
            y: 378,
            width: 72,
            height: 72,
            neighbors: 5,
            confidence: 1.325425789999999
          ,
            x: 366,
            y: 383,
            width: 61,
            height: 61,
            neighbors: 4,
            confidence: 1.290298050000000
          ,
            x: 861,
            y: 282,
            width: 59,
            height: 59,
            neighbors: 8,
            confidence: 1.289433169999998
          ,
            x: 962,
            y: 312,
            width: 53,
            height: 53,
            neighbors: 4,
            confidence: -0.1545753700000000
          ,
            x: 1049,
            y: 394,
            width: 61,
            height: 61,
            neighbors: 1,
            confidence: -0.4406286100000015
          ,
            x: 1050,
            y: 295,
            width: 58,
            height: 58,
            neighbors: 2,
            confidence: -2.9389983699999966
          ]
          for face,i in results
            delta = 1
            chai.expect(face.x).to.be.closeTo expected[i].x, delta
            chai.expect(face.y).to.be.closeTo expected[i].y, delta
            chai.expect(face.width).to.be.closeTo expected[i].width, delta
            chai.expect(face.height).to.be.closeTo expected[i].height, delta

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

