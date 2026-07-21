#!/bin/bash
#

./scripts/feeds update -a
./scripts/feeds install -a
# Modify default IP
sed -i 's/192.168.1.1/10.10.10.2/g' package/base-files/files/bin/config_generate
sed -i "s/ImmortalWrt/OpenWrt/g" package/base-files/files/bin/config_generate
