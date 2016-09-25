'use strict'
/**
 * 
 * VPNet.io Web Service
 * Virtual Private Network Essential Toolbox
 * https://github.com/acrossfw/vpnet
 * 
 */
 
const Config = require('./config')

class GfWrt{
  constructor(uuid) {
    if (!uuid) {
      throw new Error('no uuid defined')
    }
    this.uuid = uuid
    this.init()
  }
  
  init() {
    const config = new Config()
    
    this.name = config.hostname()
    this.ip   = config.ip()
    this.port = config.port('ssh')
    
    this.user='vpnet'
    this.linklocal='169.254.33.33'
    this.key='~vpnet/.ssh/id_rsa'
    
      // uci set gfwrt.vpnet='server'
      // uci set gfwrt.vpnet.uuid='f9688e84-4ed6-4bfb-922b-f6c281a34d7d'
      // uci set gfwrt.vpnet.name='vpnet-0303'
      // uci set gfwrt.vpnet.user=vpnet
      // uci set gfwrt.vpnet.ip=1.2.3.4
      // uci set gfwrt.vpnet.port=10022
      // uci set gfwrt.vpnet.linklocal=169.254.1.22
      // uci set gfwrt.vpnet.key='/etc/dropbear/vpnet-0303.key'
  }
  
  uuid()  { return this.uuid }
  name()  { return this.name }
  user()  { return this.user }
  ip()    { return this.ip }
  port()  { return this.port }
  linklocal() { return this.linklocal }
  key()   { return this.key }
}