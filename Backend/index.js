const express = require('express');
const { Server } = require('ws');

const PORT = process.env.PORT || 3000; //port for https

const clients = new Set();

const server = express()
    .use((req, res) => res.send("Hi there"))
    .listen(PORT, () => console.log(`Listening on ${PORT}`));

const wss = new Server({ server });

wss.on('connection', function(ws, req) {

    clients.add(ws);
    console.log('Client Connected');
    
    
    
    ws.on('message', message => {
        const res_Data = JSON.parse(message);

        console.log('Name:',res_Data.sender);
        console.log('latitude:',res_Data.latitude);
        console.log('longitude:',res_Data.longitude);

        // var dataString = message.toString();
        // console.log(message);
        // console.log(dataString);
        wss.clients.forEach((client) => {
                // console.log(client);
                if(res_Data.sender == "H1_DRIVER"){
                client.send(message.toString());
                }
            
        })
    })
})
