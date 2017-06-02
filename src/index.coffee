{EventEmitter}       = require 'events'
debug                = require('debug')('meshblu-connector-motion-rpi:index')
five                 = require 'johnny-five'
Raspi                = require 'raspi-io'
MeshbluSocketIO = require('meshblu')
_ = require 'lodash'


class Connector extends EventEmitter
  constructor: ->
    @board = new five.Board {io: new Raspi(),repl: false,debug: false}
    @board.on 'ready', @handleReady
    @meshblu = new MeshbluSocketIO({
      resolveSrv: true,
      uuid: 'c15a9222-1f4e-4724-927f-a4390654fc57',
      token: '4401761cd274e79139ae4ec057ac5a2dd22dee2b'
    })
    @meshblu.subscribe({uuid: 'c15a9222-1f4e-4724-927f-a4390654fc57'})
    @meshblu.on 'config', (event) => @checkMeeting event

  checkMeeting:(event) =>
    console.log "===================="
    console.log 'Config event: ', JSON.stringify event, null, 2
    currentMeeting = _.get event, 'genisys.currentMeeting'
    if currentMeeting?
      console.log "curentMeeting found : ", currentMeeting

  handleReady: () =>
    @motion = new five.Motion 'P1-13'
    @motion.on 'calibrated', () => debug 'Motion Sensor Calibrated'
    @motion.change 'change', @occupied

  occupied: () =>
    console.log 'Occupied'

  endMeeting: () =>

  findMeeting: () =>


  # handleMotionStart: () =>
  #   #@emit 'update', { currentState: 'motion-start'}
  #   #@emit 'update', { currentState: 'moved'}
  #   debug 'motion-start'

  # handleMotionEnd: () =>
  #   #@emit 'update', { currentState: 'motion-end'}
  #   #@emit 'update', { currentState: 'moved'}
  #   debug 'motion-end'


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
