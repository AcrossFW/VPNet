'use strict'
/**
 * 
 * VPNet.io Web Service - Virtual Private Network Essential Toolbox
 *
 * https://github.com/acrossfw/vpnet
 * 
 */
import { GfRelay }      from './src/gf-relay'
import { GfWrt }        from './src/gf-wrt'
import { SetupScript }  from './src/setup-script'

import { config }       from './src/config'

import * as log from 'npmlog'
// log.level = 'silly'

export {
  GfRelay
  , GfWrt
  , SetupScript
  
  , config
  , log
}