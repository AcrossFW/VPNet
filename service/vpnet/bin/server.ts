'use strict'
/**
 * 
 * VPNet.io Web Service
 * Virtual Private Network Essential Toolbox
 * https://github.com/acrossfw/vpnet
 * 
 */
import * as express from 'express'

import {
  config
  , log 
  
  , GfRelay
  , GfWrt
  , SetupScript
} from '../'

const app = express()
app.use((req,res) => {
  console.log('LOG: ' + req.url)
})

const gfRelay = new GfRelay({
  host: `${config.ip()}:${config.port()}`
  , prefix: '/gf-relay/'
})
app.use(gfRelay.prefix(), gfRelay.router())

app.get('/', async (req, res) => {
  const gfWrtList = await GfWrt.list('vpnet') || []
  
  if (gfWrtList.length === 0) {
    res.write('gfWrtList empty for user vpnet, created one for you')
    gfWrtList.push(new GfWrt('vpnet'))
  }

  for (let gfWrt of gfWrtList) {
    res.write('<p>')
    res.write(`curl -sL http://${config.ip()}:${config.port()}/setup.sh/${gfWrt.uuid()} | bash -\n\n`)
    res.write('</p>')
  }

})

app.get('/setup.sh/:uuid', (req, res) => {
  
  const gfwrt = new GfWrt(req.params.uuid)
  gfwrt.ready()
      .then(_ => {
        const script = new SetupScript(gfwrt)
        // res.writeHead(200, { 'Content-Type': 'application/x-sh' })
        res.writeHead(200, { 'Content-Type': 'text/plain' })
        res.write(script.generate())
        res.end()
      })
})

const port = config.port('web')
app.listen(port)

console.log(`[VPNet] Server: listening at ${config.ip()}:${config.port()}`)

console.log('ss: ' + gfRelay.url('shadowsocks'))