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

import { GfWrt } from '../'

test('GfWrt smoking test', function(t) {
  t.throws(_ => {
    new GfWrt('')
  }, 'should throw when instanciate without param')

  t.end()
})