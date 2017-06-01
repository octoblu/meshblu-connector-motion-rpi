{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-motion-rpi:index')
five            = require 'johnny-five'
Raspi           = require 'raspi-io'

class Connector extends EventEmitter
  constructor: ->
    @board = new five.Board {io: new Raspi(),repl: false,debug: false}
    @board.on 'ready', @handleReady

  handleReady: () =>
    @motion = new five.Motion 'P1-13'
    @motion.on 'calibrated', () => debug 'Motion Sensor Calibrated'
    @motion.on 'motionstart', @handleMotionStart
    @motion.on 'motionend', @handleMotionEnd

  handleMotionStart: () =>
    @emit 'update', { currentState: 'motion-start'}

  handleMotionEnd: () =>
    @emit 'update', { currentState: 'motion-end'}

  isOnline: (callback) =>
    callback null, running: true

  close: (callback) =>
    debug 'on close'
    callback()

  onConfig: (device={}) =>
    { @options } = device
    debug 'on config', @options

  start: (device, callback) =>
    debug 'started'
    @onConfig device
    callback()

module.exports = Connector
