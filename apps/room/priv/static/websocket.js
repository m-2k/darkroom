// Raw Websocket Transport (ES6)

'use strict';

function init_handlers(ws, c) {
    ws.onopen = (...arg) => {
		c.onopen(ws, ...arg)
		c.connected = true
		setTimeout(heartbeat, c.heartbeat_timeout, c)
	}
    ws.onmessage = (...args) => c.onmessage(...args)
    ws.onerror = (...args) => c.onerror(...args)
    ws.onclose = (evt) => {
		c.connected = false
        console.log(`Websocket connection closed, clean: ${evt.wasClean}, code: ${evt.code}, reason: ${evt.reason}, url: ${c.url}`) 
        c.onclose(evt)
        c.channel = false
    }
}

function connect({ url, onopen, onmessage, onclose, onerror, heartbeat_timeout = 4000}) {
	let c = {}
	c.url = url
	c.heartbeat_timeout = heartbeat_timeout,
	c.onopen    = onopen    || (() => false),
	c.onmessage = onmessage || (() => false),
	c.onclose   = onclose   || (() => false),
	c.onerror   = onerror   || (() => false),
    c.channel = window.WebSocket ? new window.WebSocket(c.url) : undefined;
	c.send = (msg) => { c.channel && c.channel.send(msg) }
	c.close = () => { c.channel && c.channel.close() },
    init_handlers(c.channel, c)
	return c
}

function heartbeat(c) {
	if(c.connected) {
		c.send([])
		// console.log('ping')
		setTimeout(heartbeat, c.heartbeat_timeout, c)
	}
}
