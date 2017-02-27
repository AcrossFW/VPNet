/**
 *
 * VPNet.io Web Service
 * Virtual Private Network Essential Toolbox
 * https://github.com/acrossfw/vpnet
 *
 */
const log = require('npmlog')

import * as fs from 'fs'

import config from './config'
import db     from './db'

type GfWrtSetting = {
  _id:          string  // UUID
  , ip:         string  // VPNet IP
  , key:        string  // VPNet ssh private key
  , linklocal:  string  // GfWrt internal IP
  , name:       string  // VPNet name
  , port:       number  // VPNet ssh port
  , user:       string  // VPNet user
}

class GfWrt {
  setting: GfWrtSetting
  _db = db.gfwrt()

  constructor(userOrUuid: string) {
    log.verbose('GfWrt', 'constructor(%s)', userOrUuid)

    if (/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(userOrUuid)) {
      // http://stackoverflow.com/a/13653180/1123955
      this.setting._id = userOrUuid
    } else if (userOrUuid) {
      this.setting.user = userOrUuid
    } else {
      const e = new Error('userOrUuid not found')
      log.error('GfWrt', 'constructor() exception: %s', e)
      throw e
    }
  }

  async ready(): Promise<GfWrt> {
    log.verbose('GfWrt', 'ready()')

    if (this.valid()) {
      log.silly('GfWrt', 'ready() HIT')
      return this
    }

    log.silly('GfWrt', 'ready() MISS')

    if (this.setting._id) {
      return this.loadUuid(this.setting._id)
    } else if (this.setting.user) {
      return this.createUuid(this.setting.user)
    }

    const e = new Error('neither uuid nor user?')
    log.error('GfWrt', 'ready() exception: %s', e)
    throw e
  }

  async createUuid(user): Promise<GfWrt> {
    log.verbose('GfWrt', 'createUuid(%s)', user)

    try {
      this.setting.key = this.sshKey(user)
    } catch (e) {
      log.error('GfWrt', 'createUuid() not a valid user to creat: ' + user)
      throw e
    }

    this.setting._id        = config.guid()

    this.setting.ip         = config.ip()
    this.setting.linklocal  = config.guip()
    this.setting.name       = config.hostname()
    this.setting.port       = config.port('ssh')
    this.setting.user       = user

    return this.save()
  }

  async save(): Promise<GfWrt> {
    log.verbose('GfWrt', 'save()')

    if (!this.valid()) {
      return Promise.reject(new Error('not valid for save'))
    }

    const query   = { _id: this.setting._id }
    const update  = this.setting
    const options = { upsert: true }

    return new Promise((resolve, reject) => {
      this._db.update(query, update, options, (err, numReplaced) => {
        if (err) {
          return reject(err)
        } else if (numReplaced < 1) {
          const e = new Error('numReplaced < 1')
          log.error('GfWrt', 'save() %s', e)
          return reject(e)
        }
        return resolve(this)
      })
    })
  }

  async remove(): Promise<number> {
    log.verbose('GfWrt', 'remove() with id %s', this.setting._id)

    const query = { _id: this.setting._id }

    return new Promise((resolve, reject) => {
      this._db.remove(query, {}, (err, numRemoved) => {
        if (err) {
          log.error('GfWrt', 'remove() error: %s', err)
          return reject(err)
        }
        console.log('numRemoved:' + numRemoved)
        this.setting._id = null
        return resolve(numRemoved)
      })
    })
  }

  async loadUuid(uuid): Promise<GfWrt> {
    log.verbose('GfWrt', 'loadUuid(%s)', uuid)

    const query = { _id: uuid }

    return new Promise((resolve, reject) => {
      this._db.findOne(query, (err, doc: GfWrtSetting) => {
        if (err) {
          return reject(err)
        } else if (!doc) {
          return reject(new Error('uuid not found: ' + uuid))
        }

        this.setting = doc

console.log('#############')
console.log(doc)

        return resolve(this)
      })
    })
  }

  ip()        { return this.setting.ip }
  key()       { return this.setting.key }
  linklocal() { return this.setting.linklocal }
  name()      { return this.setting.name }
  port()      { return this.setting.port }
  user()      { return this.setting.user }
  uuid()      { return this.setting._id }

  static async list(user: string = null): Promise<GfWrt[]> {
    log.verbose('GfWrt', 'list(%s)', user)

    const query: any = {}
    if (user) {
      query.user = user
    }

    return new Promise((resolve, reject) => {
      db.gfwrt().find(query, (err, docs: GfWrtSetting[]) => {
        if (err) {
          return reject(err)
        }
        const gfWrtList = docs.map(c => new GfWrt(c._id))
        resolve(gfWrtList)
      })
    })
  }

  valid(): boolean {
    return !!(this.setting._id && this.setting.user)
  }

  sshKey(user): string {
    const sshKeyFile = '/home/' + user + '/.ssh/id_rsa'
    try {
      fs.accessSync(sshKeyFile, (fs as any).F_OK)
    } catch (e) {
      log.error('GfWrt', 'sshKey() exception: %s', e)
      throw e
    }
    return fs.readFileSync(sshKeyFile).toString()
  }

}

export default GfWrt
