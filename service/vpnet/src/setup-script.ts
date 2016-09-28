/**
 *
 * VPNet.io Web Service
 * Virtual Private Network Essential Toolbox
 * https://github.com/acrossfw/vpnet
 *
 */
import * as fs from 'fs'
import { execSync } from 'child_process'

class SetupScript {
  constructor(gfwrt) {
    if (!gfwrt) {
      throw new Error('gfwrt not defined')
    }
  }

  /*
3. setup ppp over ssh vpn form openwrt, with
4. connect vpn
5. trigger vpnet setup to start
  */
  generate() {
    const header      = this.scriptHeader()
    const setupUci    = this.scriptSetupUci()
    const saveKey     = this.scriptSaveKey('/tmp/test')
    const connectVpn  = this.scriptConnectVpn()
    const notifyVpnet = this.scriptNotifyVpnet()

    return `
      ${header}
      ${setupUci}
      ${saveKey}
      ${connectVpn}
      ${notifyVpnet}
    `.replace(/^\s+/gm, '')
  }

  scriptHeader() {
    return `
      #!/usr/bin/env sh
      #
      # VPNet <-> gfWRT Connector Script
      # https://github.com/AcrossFW
      #
      # VPNet (Virtual Private Network Essential Toolbox)
      # All in ONE, ZERO Configuration Solution for Tunnel Servers' setup
      # https://github.com/AcrossFW/VPNet
      #
      # gfWRT (Wireless RouTer for your Girl Friend)
      # Set it Once and Forget it Forever.
      # https://github.com/AcrossFW/gfWRT
      #

    `
  }

  scriptSetupUci() {
    return `
      ######################
      # scriptSetupUci
      ######################
      touch /etc/config/gfwrt

      uci set gfwrt.vpnet='server'
      uci set gfwrt.vpnet.uuid='f9688e84-4ed6-4bfb-922b-f6c281a34d7d'
      # uci set gfwrt.vpnet.name='vpnet-0303'
      uci set gfwrt.vpnet.user=vpnet
      uci set gfwrt.vpnet.ip=1.2.3.4
      uci set gfwrt.vpnet.port=10022
      uci set gfwrt.vpnet.linklocal=169.254.1.22
      uci set gfwrt.vpnet.key='/etc/dropbear/vpnet-0303.key'
      uci commit
    `
  }

  scriptSaveKey(sshKeyFile) {
    const base64Str = this.base64DropbearKey(sshKeyFile)
    const luaDecoder = this.scriptLuaDecoder(base64Str)
    return `
      ######################
      # scriptSaveKey
      ######################
      ${luaDecoder} > /etc/dropbear/vpnet-0303.key
    `
  }

  base64DropbearKey(sshKeyFile) {
    // this will throw if not exist
    fs.accessSync(sshKeyFile, (fs as any).F_OK)

    const bashScript = `
      set -euo pipefail;
      KEY_FILE="/tmp/keyfile.$$";
      /usr/lib/dropbear/dropbearconvert openssh dropbear ${sshKeyFile} "$KEY_FILE" 2>/dev/null;
      base64 --wrap=0 "$KEY_FILE";
      rm "$KEY_FILE";
    `.replace(/[\n ]+/g, ' ')

    // console.log(bashScript)

    const base64Str = execSync(`bash -c '${bashScript}'`)
                        .toString()
    if (!base64Str) {
      throw new Error('base64 fail: ' + sshKeyFile)
    }
    return base64Str
  }

  scriptLuaDecoder(base64Str) {
    if (!base64Str) {
      throw new Error('no base64 string found')
    }

    // http://lua-users.org/wiki/BaseSixtyFour
    let luaScript = `
      local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

      function dec(data)
          data = string.gsub(data, '[^'..b..'=]', '')
          return (data:gsub('.', function(x)
              if (x == '=') then return '' end
              local r,f='',(b:find(x)-1)
              for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
              return r;
          end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
              if (#x ~= 8) then return '' end
              local c=0
              for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
              return string.char(c)
          end))
      end

      io.stdout:write(dec('${base64Str}'))
    `.replace(/[\n ]+/g, ' ')

    return `lua -e "${luaScript}"`
  }

  scriptConnectVpn() {
    return `
      ######################
      # scriptConnectVpn
      ######################
      echo "connect vpn"
    `
  }
  scriptNotifyVpnet() {
    return `
      ######################
      # scriptNotifyVpnet
      ######################
      echo "notify vpnet"
    `
  }
}

// const ss = new SetupScript(1234)
// console.log(ss.generate())

export default SetupScript
