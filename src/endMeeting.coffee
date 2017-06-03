MeshbluHttp      = require('meshblu-http')
meetingId = "5db6d3c0-0b7b-4d7e-ad2a-d17f2f4b9fa3"
console.log "====================================="
console.log 'Ending meeting with meetingId:', meetingId
userMeshblu = new MeshbluHttp {
  resolveSrv: true,
  domain: 'octoblu.com',
  uuid: 'a11d2398-267d-4a80-99ed-70ca9771363e',
  token: 'a6f0b7ea3005dfb110a6ae8827a74f95c9ce104c'
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
