'use strict'
/**
 * 
 * VPNet.io Web Service - Virtual Private Network Essential Toolbox
 *
 * https://github.com/acrossfw/vpnet
 * 
 */
const { Router } = require('express')
const httpProxyMiddleware = require('http-proxy-middleware')
const log = require('npmlog')

class GfRelay {
  constructor({
    prefix
    , host
  } = {}) {
    this.prefix = prefix
    this.host = host
    
    this._router = Router({ strict: true })
    this.init()
  }

  init() {
    this.initRelayMap()

    this.initRouterRoot()
    this.initRouterDist()
  }

  router() { return this._router }
  
  initRelayMap() {
    this.relayMap = {
      shadowsocks: 'http://openwrt-dist.sourceforge.net'
    }
  }  

  initRouterRoot() {
    this._router.get('/', (req, res, next) => {
      if (!/\/$/.test(req.originalUrl)) {
        res.redirect(req.originalUrl + '/')
        res.end()
        return
      }
      
      for (let dist of this.list()) {
        res.write(`
          <a href="${dist}/">${dist}</a>
        `)
      }
      res.write('<p>VPNet.io OK</p>')
      res.end()
    })
  }

  initRouterDist() {
    for (let dist of this.list()) {
      const target = this.target(dist)
      const pathRewrite = {}
      const pathRegex = '^' + this.prefix + dist
      pathRewrite[pathRegex] = ''

      const proxy = httpProxyMiddleware({
        target
        , pathRewrite
        , changeOrigin: true // for vhosted sites, changes host header to match to target's host
        , logLevel: 'debug'
      })
    
      // log.verbose('Proxy', 'mapping [%s] to [%s]', dist, target)
      this._router.use('/' + dist + '/', proxy)
    }
  }
  
  list() {
    if (!this.relayMap) {
      throw new Error('relayMap undefined')
    }
    
    return Object.keys(this.relayMap)
  }
  
  target(dist) {
    return this.relayMap[dist]
  }
 
  url(dist) {
    return 'http://' + this.host + this.prefix + dist + '/'
  } 
}

module.exports = GfRelay.default = GfRelay.GfRelay = GfRelay
