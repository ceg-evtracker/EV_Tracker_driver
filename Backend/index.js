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
        // console.log(message);
        var dataString = message.toString();
        // console.log(message);
        console.log(dataString);
        wss.clients.forEach((client) => {
                if(message.toString().startsWith("H1:")){
                client.send(message.toString());
                }
            
        })
    })
})
