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
      , openwrt: 'https://downloads.openwrt.org'
    }
  }  

  initRouterRoot() {
    this._router.get('/', this.fixTrailingSlashes, (req, res, next) => {

      res.writeHead(200, { 'Content-Type': 'text/html' })
      res.write('<ol>')
      for (let dist of this.list()) {
        res.write(`
          <li><a href="${dist}/">${dist}</a></li>
        `)
      }
      res.write('</ol>')
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
      this._router.use('/' + dist + '/'
                        , this.fixTrailingSlashes
                        , proxy
                      )
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
  
  fixTrailingSlashes(req, res, next) {
    // http://stackoverflow.com/a/35927027/1123955
    // console.log(`\n\n### ${req.originalUrl} ${req.baseUrl} ${req.url} \n\n\n`)
    if (req.originalUrl != req.baseUrl + req.url) {
      res.redirect(301, req.baseUrl + req.url)
    } else {
      next()
    }
  }

}

module.exports = GfRelay.default = GfRelay.GfRelay = GfRelay
