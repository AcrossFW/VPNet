#!/usr/bin/env ts-node
/**
 *
 * VPNet.io Web Service - Virtual Private Network Essential Toolbox
 *
 * https://github.com/acrossfw/vpnet
 *
 */
const { test } = require('tap')

// import sinon from 'sinon'

import { db } from '../'

test('Database smoking test', function(t) {
  t.ok(db.gfwrt(), 'should has gfwrt collection set')
  t.end()
})
