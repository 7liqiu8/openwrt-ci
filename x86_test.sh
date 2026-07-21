#!/bin/bash

./scripts/feeds update -a
./scripts/feeds install -a

#  删除冲突的 firewall4 旧补丁
rm -f package/network/config/firewall4/patches/001-firewall4-add-support-for-fullcone-nat.patch

#  运行 SONiC 补丁脚本
curl -sSL -o add_sonic_fullcone.sh \
  https://raw.githubusercontent.com/mufeng05/openwrt-sonic-fullcone/master/add_sonic_fullcone.sh
chmod +x add_sonic_fullcone.sh
./add_sonic_fullcone.sh

#  清理 firewall4 的编译残留
make package/network/config/firewall4/clean V=s

