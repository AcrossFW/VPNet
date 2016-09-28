#!/usr/bin/env ts-node
/**
 * 
 * VPNet.io Web Service - Virtual Private Network Essential Toolbox
 *
 * https://github.com/acrossfw/vpnet
 * 
 */
const { test } = require('tap')

import { config } from '../'

test('Config IP/Port should be set', t => {
  t.ok(/^\d+\.\d+\.\d+\.\d+$/ .test(config.ip())        , 'should has ip')
  t.ok(/^\d+$/                .test(config.port())      , 'should has default port')
  t.ok(/^\d+$/                .test(config.port('web')) , 'should has web port')
  t.end()
})