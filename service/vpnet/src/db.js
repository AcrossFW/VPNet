'use strict'
/**
 * 
 * VPNet.io Web Service
 * Virtual Private Network Essential Toolbox
 * https://github.com/acrossfw/vpnet
 * 
 */
const Datastore = require('nedb')
const config = require('./config')

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

const db = new Db()

db.db().insert(doc, function (err, newDoc) {   // Callback is optional
  if (err) {
    console.log(err)
  }
  console.log(newDoc)
  // newDoc is the newly inserted document, including its _id
  // newDoc has no key called notToBeSaved since its value was undefined
})

module.exports = db