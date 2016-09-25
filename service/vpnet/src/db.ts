'use strict'
/**
 * 
 * VPNet.io Web Service
 * Virtual Private Network Essential Toolbox
 * https://github.com/acrossfw/vpnet
 * 
 */
import * as Datastore from 'nedb'
import { config } from './config'

const db = new Datastore({
  filename: config.nedb()
  , autoload: true
})

var doc = { 
  hello: 'world'
  , n: 5
  , today: new Date()
  , nedbIsAwesome: true
  , notthere: null
  , notToBeSaved: undefined  // Will not be saved
  , fruits: [ 'apple', 'orange', 'pear' ]
  , infos: { name: 'nedb' }
}

export { db }
