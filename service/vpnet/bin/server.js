'use strict'
/**
 * 
 * VPNet.io Web Service - Virtual Private Network Essential Toolbox
 *
 * https://github.com/acrossfw/vpnet
 * 
 */
const express             = require('express')
const httpProxyMiddleware = require('http-proxy-middleware')

const { Config, GfRelay, log } = require('../')

const app     = express()

const config = new Config()

const GF_RELAY_PREFIX = '/gf-relay/'
const LISTEN_PORT=3000
const gfRelay = new GfRelay({
  host: `${config.ip()}:${LISTEN_PORT}`
  , prefix: GF_RELAY_PREFIX
})
app.use(GF_RELAY_PREFIX, gfRelay.router())

app.get('/', (req, res) => {
  res.send(`curl -sL http://${config.ip()}/gfwrt-vpnet-setup | bash -`)
})

app.get('/gfwrt-vpnet-setup', (req, res) => {
  let script
  script = 'echo gfwrt setup fake done!'
  res.write(script)
  res.end()
})

app.listen(LISTEN_PORT)

console.log(`[VPNet] Server: listening at ${config.ip()}:${LISTEN_PORT}`)

console.log('ss: ' + gfRelay.url('shadowsocks'))