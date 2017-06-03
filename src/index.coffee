{EventEmitter}       = require 'events'
debug                = require('debug')('meshblu-connector-motion-rpi:index')
five                 = require 'johnny-five'
Raspi                = require 'raspi-io'
moment               = require 'moment'
MeshbluSocketIO      = require('meshblu')
MeshbluHttp          = require ('meshblu-http')
_ = require 'lodash'

class Connector extends EventEmitter
  constructor: ->
    @limitMinutes = 2
    @validUtil = moment().utc().add(@limitMinutes, 'minute')
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
    console.log 'watchForMeeting'
    @meshblu.on 'config', (event) => @checkMeeting event

  checkMeeting:(event) =>
    currentMeeting = _.get event, 'genisys.currentMeeting'
    if currentMeeting?
      console.log "====================================="
      console.log "curentMeeting found : ", currentMeeting
      meetingStartTime = _.get event, 'genisys.currentMeeting.startTime'
      noShowLimit = moment(meetingStartTime).utc().add(@limitMinutes, 'minute')
      if (moment().isBefore(noShowLimit) && moment(@validUntil).isBefore(moment()))
        @validUntil = noShowLimit
        console.log "Initializing valid until to no show limit as : #{@validUntil.toISOString()}"

      if (moment(@validUntil).isBefore(moment().utc()) && moment().utc().isAfter(noShowLimit))
        meetingId = _.get currentMeeting, 'meetingId'
        console.log "====================================="
        console.log "Ending meeting, validUntil: ", moment(@validUntil).toISOString()
        console.log "Ending meeting, current time: ", moment().toISOString()
        console.log "meetingStartTime: #{meetingStartTime} and No show limit :#{noShowLimit.toISOString()}" if moment().utc().isAfter(noShowLimit)
        @endMeeting meetingId

  endMeeting: (meetingId) =>
    console.log 'Ending meeting with meetingId:', meetingId
    @userMeshblu = new MeshbluHttp {
      resolveSrv: true,
      uuid: 'a11d2398-267d-4a80-99ed-70ca9771363e',
      token: '706bfc2e00e9734714c13e87845fa4d54ff53b15'
    }
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
    @userMeshblu.message message, (error) =>
      console.log 'Error ending meeting: ', error if error?
      return

  handleReady: () =>
    @motion = new five.Motion 'P1-13'
    @motion.on 'calibrated', () => console.log 'Motion Sensor Calibrated'
    @motion.on 'change', @updateValidUntil

  updateValidUntil: () =>
    @validUtil = moment().add(@limitMinutes, 'minutes').utc()
    console.log 'updateValidUntil Valid Until : ', @validUtil.toISOString()

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
