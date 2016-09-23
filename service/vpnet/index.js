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

const log                 = require('npmlog')
log.level = 'verbose'

const { GfRelay } = require('./src/gf-relay.js')

const app     = express()

const GF_RELAY_PREFIX = '/gf-relay/'
const gfRelay = new GfRelay({
  host: '104.199.158.186:3000'
  , prefix: GF_RELAY_PREFIX
})
app.use(GF_RELAY_PREFIX, gfRelay.router())

app.listen(3000)

console.log('[DEMO] Server: listening on port 3000')

console.log('ss: ' + gfRelay.url('shadowsocks'))