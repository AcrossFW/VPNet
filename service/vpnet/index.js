'use strict'
/**
 * 
 * VPNet.io Web Service - Virtual Private Network Essential Toolbox
 *
 * https://github.com/acrossfw/vpnet
 * 
 */
const Config      = require('./src/config.js')
const GfRelay     = require('./src/gf-relay.js')
const SetupScript = require('./src/setup-script.js')

const log = require('npmlog')
log.level = 'silly'

module.exports = {
  Config
  , GfRelay
  , SetupScript
  
  , log
}