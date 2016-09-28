'use strict'
/**
 *
 * VPNet.io Web Service
 * Virtual Private Network Essential Toolbox
 * https://github.com/acrossfw/vpnet
 *
 */
import * as Datastore from 'nedb'
import config from './config'

class Db {
  _gfwrt: Datastore

  constructor() {
    this.init()
  }

  init() {
    this._gfwrt = new Datastore({
      filename: config.db('gfwrt')
      , autoload: true
    })
  }

  gfwrt() {
    return this._gfwrt
  }
}

const db = new Db()

export default db
