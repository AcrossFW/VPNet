/**
 * 
 * VPNet.io Web Service - Virtual Private Network Essential Toolbox
 *
 * https://github.com/acrossfw/vpnet
 * 
 */
 
class Config {
  _ip: string
  _nedb: any
  
  port_web: number
  
  constructor() {
    this.init()
  }
   
  init() {
    this._ip = process.env.WANIP || require('child_process')
                                      .execSync('curl -Ss ifconfig.io')
                                      .toString()
                                      .replace('\n', '')
    this.port_web = process.env.PORT_WEB || 10080
    this._nedb = '/tmp/vpnet.nedb'
  }
     
  hostname()  { return process.env.HOSTNAME }
  ip()        { return this._ip   }
  nedb()      { return this._nedb }

  port(service = 'web') {
    let port = this[`port_${service}`]
    if (port) {
      return port
    }
    
    let portVar = 'PORT_' + service.toUpperCase()
    port = process.env[portVar]
    if (port) {
      return port
    }
    throw new Error(`port for ${service} not found!`)
  }

}

const config = new Config

export { config }