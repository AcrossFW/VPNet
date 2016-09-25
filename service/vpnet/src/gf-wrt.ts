/**
 * 
 * VPNet.io Web Service
 * Virtual Private Network Essential Toolbox
 * https://github.com/acrossfw/vpnet
 * 
 */
import * as fs from 'fs'
import * as log from 'npmlog'

import { config } from './config'
import { db } from './db'

class GfWrt {
  _uuid: string
  _user: string
  _name: string
  _ip: string
  _port: number
  _key: string
  _linklocal: string
  
  constructor(userOrUuid) {
    log.verbose('GfWrt', 'constructor(%s)', userOrUuid)
    
    if (/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(userOrUuid)) {
      // http://stackoverflow.com/a/13653180/1123955
      this._uuid = userOrUuid
    } else {
      this._user = userOrUuid
    }
  }

  ready() {
    log.verbose('GfWrt', 'ready()')
    if (this.valid()) {
      log.silly('GfWrt', 'ready() valid')
      return Promise.resolve(this)
    }
    log.silly('GfWrt', 'ready() invalid')

    this._name = config.hostname()
    this._ip   = config.ip()
    this._port = config.port('ssh')
    
    if (this._uuid) {
      return this.loadUuid(this._uuid)
    } else if (this._user) {
      return this.create(this._user)
    }
  } 
  
  valid() {
    return !!(this._uuid && this._user)
  }

  create(forUser) {
    log.verbose('GfWrt', 'create(%s)', forUser)
    
    if (!/^[\w\d-_\.]+$/.test(forUser)) {
      throw new Error('not a valid user to creat: ' + forUser)
    }
    
    const sshKeyFile = '/home/' + forUser + '/.ssh/id_rsa'
    fs.accessSync(sshKeyFile, (fs as any).F_OK)
    
    this._user  = forUser
    this._key   = sshKeyFile
    
    this._linklocal = GfWrt.guip()
    this._uuid      = GfWrt.guid()
    
    return this.save()
  }
  
  save() {
    log.verbose('GfWrt', 'save()')
    
    if (!this.valid()) {
      return Promise.reject(new Error('not valid for save'))
    }
    
    return new Promise((resolve, reject) => {
      db.insert({
        _id: this.uuid()
        , ip: this.ip()
        , port: this.port()
        , name: this.name()
        , linklocal: this.linklocal()
        , key: this.key()
      }, (err, doc) => {
        if (err) {
          return reject(err)
        }
        // return resolve(doc)
        return resolve(this)
      })      
    })
  }
  
  remove() {
    log.verbose('GfWrt', 'remove()')
    return new Promise((resolve, reject) => {
      db.remove({
        _id: this.uuid()
      }
      , {}
      , (err, numRemoved) => {
        if (err) {
          reject(err)
        } else {
          console.log('numRemoved:' + numRemoved)
          this._uuid = null
          resolve(numRemoved)
        }
      })
    })
  }
  
  loadUuid(uuid) {
    log.verbose('GfWrt', 'loadUuid(%s', uuid)
    
    return new Promise((resolve, reject) => {
      db.findOne({_id: uuid}, (err, doc) => {
        if (err) {
          return reject(err)
        }
        this._uuid      = doc._id
        this._user      = doc.user
        this._linklocal = doc.linklocal
        this._key       = doc.key
        return resolve(this)
      })      
    })
  }
  
  ip()        { return this._ip }
  key()       { return this._key }
  linklocal() { return this._linklocal }
  name()      { return this._name }
  port()      { return this._port }
  user()      { return this._user }
  uuid()      { return this._uuid }

  static list(forUser) : Promise<GfWrt[]>{
    log.verbose('GfWrt', 'list(%s)', forUser)
    
    const query: any = {}
    if (forUser) {
      query.user = forUser
    }
    return new Promise((resolve, reject) => {
      db.find(query, (err, docs) => {
        if (err) {
          return reject(err)
        }
        const gfWrtList = docs.map(c => new GfWrt(c._id))
        resolve(gfWrtList)
      })
    })
  }

  static guip() {
    return '169.254.x.y'.replace(/[xy]/g, _ => {
      return String(Math.random()*255|0)
    })
  }
  
  static guid() {
    // http://stackoverflow.com/a/2117523/1123955
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8)
      return v.toString(16)
    })
  }

}

export { GfWrt }
