// library

let qi = (id) => document.getElementById(id)

String.prototype.hashCode = function() {
  if (this.length === 0) return 0
  for (var i = 0, hash = 0; i < this.length; i++) {
    hash = ((hash << 5) - hash) + this.charCodeAt(i)
    hash |= 0
  }
  return hash
}

let uuid = () => Array.from(window.crypto.getRandomValues(new Uint8Array(16))).reduce((acc, byte, idx) => {
    switch(idx) {
        case 6: acc += "-4"; break
        case 8: acc += "-" + ((byte & 0xF) & 0x3 | 0x8).toString(16); break
        case 10: case 4: acc += "-"
        default: acc += (byte & 0xF).toString(16)
    }
    return acc + (byte >>> 4).toString(16) }, '' )

const copyToClipboard = (str) => {
	const el = document.createElement('textarea')
	el.value = str
	el.setAttribute('readonly', '')
	el.style.position = 'absolute'
	el.style.left = '-9999px'
	document.body.appendChild(el)
	const selected = document.getSelection().rangeCount > 0 ? document.getSelection().getRangeAt(0) : false
	el.select()
	document.execCommand('copy')
	document.body.removeChild(el)
	if (selected) {
		document.getSelection().removeAllRanges()
		document.getSelection().addRange(selected)
	}
};

// global vars

let chan;


// functions

let init_index = () => {
	qi('name').value = localStorage.getItem('name')
	qi('room').value = localStorage.getItem('room')
	qi('join').addEventListener('click', (e) => {
		let name = qi('name').value
		localStorage.setItem('name', name)
		document.location = `${document.location.origin}/room/${qi('room').value}`
	})
}

let init_room = () => {
	
	let ur = document.location.pathname.match(/room\/(.+)\/?/)
	
	if(!ur) { document.location = `${document.location.origin}/room/public`; return }
	
	localStorage.setItem('room', ur[1])
	if (!localStorage.getItem('name')) { localStorage.setItem('name',`anon-${uuid()}`) }
	
	qi('room_title').innerText = localStorage.getItem('room')
	qi('send').innerText += ` as ${localStorage.getItem('name')}`
	qi('send').addEventListener('click', (e) => chat(qi('message').value))
	qi('logout').addEventListener('click', (e) => {
		chan.close()
		document.location = document.location.origin
	})
	
	qi('share').addEventListener('click', (e) => {
		copyToClipboard(document.location.toString())
		qi('share-info').style.display = ''
		setTimeout(() => { qi('share-info').style.display = 'none' }, 5000)
	})
	
	chan = connect({
		url: `${document.location.protocol === 'https:' ? 'wss' : 'ws'}://${window.location.host}/ws/room/${localStorage.getItem('room').hashCode()}`,
		heartbeat_timeout: 8000,
		onopen: () => console.log('WS CONNECTED'),
		onmessage: (msg) => { console.log(`WS RECEIVE MESSAGE: ${msg.data}`), receive(msg.data) },
		onclose: () => console.log('WS CLOSED'),
		onerror: (err) => console.log('WS ERROR: ', err)
	})
}

let chat = (msg) => {
	chan.send(`${localStorage.getItem('name')}: ${msg}`)
	qi('message').value = ''
	qi('message').focus()
}

let receive = (msg) => {
	let m = document.createElement("div");
	m.innerText = msg;
	qi('history').appendChild(m)
}
