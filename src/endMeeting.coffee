MeshbluSocketIO      = require('meshblu-http')
meetingId = '7415a052-bcde-4161-a250-fd80450a2f0e'
console.log "====================================="
console.log 'Ending meeting with meetingId:', meetingId
customerMeshblu = new MeshbluSocketIO({
  resolveSrv: true,
  domain: 'octoblu.com',
  uuid: 'a11d2398-267d-4a80-99ed-70ca9771363e',
  token: '706bfc2e00e9734714c13e87845fa4d54ff53b15'
})
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
customerMeshblu.message  message , (error) =>
  console.log 'Error ending meeting: ', error if error?
