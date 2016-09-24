/**
 * 
 * VPNet.io Web Service - Virtual Private Network Essential Toolbox
 *
 * https://github.com/acrossfw/vpnet
 * 
 */
import { test } from 'ava'

// import sinon from 'sinon'

import { Config } from '../'

test('Config IP/Port should be set', function(t) {
  const config = new Config()
  
  t.true(/^\d+\.\d+\.\d+\.\d+$/ .test(config.ip()))
  t.true(/^\d+$/                .test(config.port()))
})