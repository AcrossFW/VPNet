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
  , db

  , GfRelay
  , GfWrt
  , SetupScript
} from '../'

const app = express()
app.use((req, res, next) => {
  console.log('LOG: ' + req.url)
  next()
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
    const gfWrt = new GfWrt('vpnet')
    gfWrtList.push(await gfWrt.ready())
  }

  for (let gfWrt of gfWrtList) {
    res.write('<span>')
    res.write(`curl -sL http://${config.ip()}:${config.port()}/setup.sh/${gfWrt.uuid()} | bash -`)
    res.write('</span>')
  }
  res.end()
})

app.get('/debug', (req, res) => {
  db.gfwrt().find((err, docs) => {
    if (err) {
      res.send('error: ' + err)
      return
    }

    res.send('docs: ' + JSON.stringify(docs))
    return
  })
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