#!/bin/bash
#
# Modify default IP
sed -i 's/192.168.1.1/10.10.10.2/g' package/base-files/files/bin/config_generate
sed -i "s/ImmortalWrt/OpenWrt/g" package/base-files/files/bin/config_generate
