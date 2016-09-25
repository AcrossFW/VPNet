'use strict'
/**
 * 
 * VPNet.io Web Service - Virtual Private Network Essential Toolbox
 *
 * https://github.com/acrossfw/vpnet
 * 
 */
 
class Config {
  constructor() {
    this.init()
  }
   
  init() {
    this._ip = process.env.WANIP || require('child_process')
                                      .execSync('curl -Ss ifconfig.io')
                                      .toString()
                                      .replace('\n', '')
  }
     
  ip()    { return this._ip   }

  port(service = 'web') {
    let portVar = 'PORT_' + service.toUpperCase()
    const port = process.env[portVar]
    if (!port) {
      throw new Error(`port for ${service} not found on env var ${portVar}!`)
    }
    return port
  }

  hostname() {
    return process.env.HOSTNAME
  }
 }
 
 module.exports = Config.default = Config.Config = Config