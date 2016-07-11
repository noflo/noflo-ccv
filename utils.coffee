temporary = require 'temporary'
fs = require 'fs'
exec = require('child_process').exec

writeCanvasTempFile = (canvas, callback) ->
  tmpFile = new temporary.File

  rs = canvas.pngStream()
  ws = fs.createWriteStream tmpFile.path
  rs.once 'error', (error) ->
    callback error
    tmpFile.unlink()
    return
  ws.once 'error', (error) ->
    callback error
    tmpFile.unlink()
    return
  ws.once 'open', (fd) ->
    if fd < 0
      callback new Error 'Bad file descriptor'
      tmpFile.unlink()
      return
    ws.once 'close', ->
      fs.fsync fd, ->
        try
          callback null, tmpFile
        catch error
          callback error
          tmpFile.unlink()
  rs.pipe ws

runCmd = (cmd, tmpFile, cascade, callback) ->
  exec "#{cmd} #{tmpFile.path} #{cascade}", (err, stdout, stderr) ->
    if err
      callback err
      tmpFile.unlink()
      return
    else
      out = JSON.parse stdout
      if out.length > 1
        out.sort (a,b) -> return b.confidence-a.confidence
      callback null, out
      tmpFile.unlink()

exports.writeCanvasTempFile = writeCanvasTempFile
exports.runCmd = runCmd
