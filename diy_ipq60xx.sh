#!/bin/bash

# 下载脚本到当前目录
curl -sSL -o add_sonic_fullcone.sh \
  https://raw.githubusercontent.com/mufeng05/openwrt-sonic-fullcone/master/add_sonic_fullcone.sh

# 赋予可执行权限
chmod +x add_sonic_fullcone.sh

# 运行脚本
./add_sonic_fullcone.sh

# 修改默认 IP 和主机名
sed -i 's/192.168.1.1/10.10.21.1/g' package/base-files/files/bin/config_generate
