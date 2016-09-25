'use strict'
/**
 * 
 * VPNet.io Web Service - Virtual Private Network Essential Toolbox
 *
 * https://github.com/acrossfw/vpnet
 * 
 */
const GfRelay     = require('./src/gf-relay.js')
const GfWrt       = require('./src/gf-wrt.js')
const SetupScript = require('./src/setup-script.js')

const config      = require('./src/config.js')

const log = require('npmlog')
log.level = 'silly'

module.exports = {
  GfRelay
  , GfWrt
  , SetupScript
  
  , config
  , log
}