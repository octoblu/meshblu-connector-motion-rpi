{EventEmitter}       = require 'events'
debug                = require('debug')('meshblu-connector-motion-rpi:index')
five                 = require 'johnny-five'
Raspi                = require 'raspi-io'
moment               = require 'moment'
MeshbluSocketIO      = require('meshblu')
_ = require 'lodash'


class Connector extends EventEmitter
  constructor: ->
    @validUntil = moment().utc()
    @board = new five.Board {io: new Raspi(),repl: false,debug: false}
    @board.on 'ready', @handleReady

    @meshblu = new MeshbluSocketIO({
      resolveSrv: true,
      uuid: 'c15a9222-1f4e-4724-927f-a4390654fc57',
      token: '4401761cd274e79139ae4ec057ac5a2dd22dee2b'
    })

    @meshblu.on 'ready', () => @watchForMeeting()
    @meshblu.connect()
    @meshblu.subscribe({uuid: 'c15a9222-1f4e-4724-927f-a4390654fc57'})

  watchForMeeting: () =>
    @meshblu.on 'config', (event) => @checkMeeting event

  checkMeeting:(event) =>
    currentMeeting = _.get event, 'genisys.currentMeeting'
    if currentMeeting?
      console.log "curentMeeting found : ", currentMeeting
      if moment(@validUntil).isBefore(moment().utc())
        meetingId = _.get currentMeeting, 'meetingId'
        @endMeeting meetingId

  endMeeting: (meetingId) =>
    console.log 'Ending meeting with meetingId:', meetingId
    message = {
      devices: [ "*" ]
      metadata:
        jobType: "end-meeting"
      data:
        meetingId: meetingId
        room:
          '$ref': "meshbludevice://c15a9222-1f4e-4724-927f-a4390654fc57"
    }
    console.log 'End Meeting message: ', message
    @meshblu.message { message }, (error) =>
      console.log 'Error ending meeting: ', error if error?
      return

  handleReady: () =>
    @motion = new five.Motion 'P1-13'
    @motion.on 'calibrated', () => debug 'Motion Sensor Calibrated'
    @motion.on 'change', @updateValidUntil

  updateValidUntil: () =>
    @validUtil = moment().add(10, 'minutes').utc()
    console.log 'Valid Until : ', @validUtil

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
