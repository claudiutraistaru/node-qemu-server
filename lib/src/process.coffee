proc      = require 'child_process'
parser    = require './parser'
config    = require '../config'
vmHandler = require '../vmHandler'

class Process
  constructor: () ->
    @process = undefined
  
  getPid: () ->
    return @process.pid if @process
    0
  
  start: (vmConf) ->
    try
      args     = parser.guestConfToArgs vmConf
      console.log "QEMU-Process: Start-Parameters: #{args.args.join(' ')}"
      
      # shift first array element, its qemu-system-x86_64 xor numactl
      @process = proc.spawn args.args.shift(), args.args, {stdio: 'inherit', detached: true}
      
      @process.on 'exit', (code, signal) ->
        config.removePid @pid
        if code is 0 then console.log   'QEMU-Process: exit clean.'
        else              console.error "QEMU-Process: exit with error: #{code}, signal: #{signal}"
        vmHandler.SHUTDOWN vmConf.name
    catch e
      console.error 'process:start:e'
      console.dir    e
      vmHandler.SHUTDOWN vmConf.name
      vmHandler.stopQmp  vmConf.name

module.exports.Process = Process
