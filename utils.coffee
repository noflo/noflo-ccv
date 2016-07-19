temporary = require 'temporary'
fs = require 'fs'
exec = require('child_process').exec

# Safe guard exec command to a max of 1min
execTimeout = 60000

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

runCmd = (cmd, tmpFile, callback) ->
  options =
    timeout: execTimeout
  exec cmd, options, (err, stdout, stderr) ->
    if err
      if err.signal is 'SIGTERM'
        callback new Error "Command #{cmd} timed out"
      else
        callback err
      tmpFile.unlink()
      return
    else
      out = JSON.parse stdout
      if out.length > 1
        out.sort (a,b) ->
          if b.confidence? and
          a.confidence? and
          typeof b.confidence is 'number' and
          typeof a.confidence is 'number'
            return b.confidence-a.confidence
          return 0
      callback null, out
      tmpFile.unlink()

exports.writeCanvasTempFile = writeCanvasTempFile
exports.runCmd = runCmd
