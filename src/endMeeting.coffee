MeshbluHttp      = require('meshblu')
meetingId = "88a77033-acfb-4b5f-8bc3-2e69bf87a79f"
console.log "====================================="
console.log 'Ending meeting with meetingId:', meetingId
userMeshblu = new MeshbluHttp {
  resolveSrv: true,
  domain: 'octoblu.com',
  uuid: '448d3a5b-4b33-44de-9bea-ee0af1dbe77a',
  token: '20896bc678999fd13e52dbd0fd40c1970d01151c'
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
userMeshblu.message  message, (error) =>
  console.log 'Error ending meeting: ', error if error?
