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
  _nedbMap: Object

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
    this._nedbMap = {
      gfwrt:    '/tmp/gfwrt.nedb.json'
      , vpnet:  '/tmp/vpnet.nedb.json'
    }
  }

  db(name = 'gfwrt') {
    if (!this._nedbMap[name]) {
      const e = new Error('db name not found: ' + name)
      log.error('Config', 'db() exception: %s', e)
      throw e
    }
    return this._nedbMap[name]
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
    const e = new Error(`port for ${service} not found!`)
    log.error('Config', 'port() exception: %s', e)
    throw e
  }

  guip(): string {
    return '169.254.x.y'.replace(/[xy]/g, _ => {
      return String(Math.random() * 255 | 0)
    })
  }

  guid(): string {
    // http://stackoverflow.com/a/2117523/1123955
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      const r = Math.random() * 16 | 0, v = c === 'x' ? r : (r & 0x3 | 0x8)
      return v.toString(16)
    })
  }

}

const config = new Config

export default config
