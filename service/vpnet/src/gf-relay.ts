'use strict'
/**
 * 
 * VPNet.io Web Service - Virtual Private Network Essential Toolbox
 *
 * https://github.com/acrossfw/vpnet
 * 
 */
import { Router } from 'express'
import * as log from 'npmlog'
import * as HttpProxyMiddleware from 'http-proxy-middleware'

class GfRelay {
  _prefix:  string
  _host:    string
  _router:  Router

  relayMap: {}

  constructor({
    prefix = null
    , host = null
  } = {}) {
    if (!prefix || !host) {
      throw new Error('must provide prefix and host')
    }
    
    this._prefix = prefix
    this._host = host
    
    this._router = Router({ strict: true })
    this.init()
  }

  init() {
    this.initRelayMap()

    this.initRouterRoot()
    this.initRouterDist()
  }

  prefix() { return this._prefix }
  router() { return this._router }
  
  initRelayMap() {
    this.relayMap = {
      shadowsocks: 'http://openwrt-dist.sourceforge.net'
      , openwrt: 'https://downloads.openwrt.org'
    }
  }  

  initRouterRoot() {
    (this._router as any).get('/', this.fixTrailingSlashes, (req, res, next) => {

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
      const pathRegex = '^' + this._prefix + dist +'/'
      pathRewrite[pathRegex] = '/'

console.log('########################')
console.log(dist)
console.log(target)
console.log(pathRewrite)
console.log(HttpProxyMiddleware)
console.log('########################')

      let proxy = HttpProxyMiddleware({
        target
        , pathRewrite
        , changeOrigin: true // for vhosted sites, changes host header to match to target's host
        , logLevel: 'debug'
      })
    
      log.verbose('Proxy', 'mapping [%s] to [%s]', dist, target)
      console.log(dist + ' : ' + target)
      (this._router as any).use('/' + dist + '/'
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
    return 'http://' + this._host + this._prefix + dist + '/'
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

export { GfRelay }
