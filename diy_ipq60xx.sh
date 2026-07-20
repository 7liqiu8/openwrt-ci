#!/bin/bash
set -e   # 遇到任何错误立即退出，可代替部分 || exit 1

#  应用 Fullcone NAT 补丁
echo "正在应用 Fullcone NAT 补丁..."
curl -sSL https://raw.githubusercontent.com/mufeng05/openwrt-sonic-fullcone/master/add_sonic_fullcone.sh | \
  sed '/^# --- firewall4/,/^echo "\[fw4\]/d' | \
  bash || { echo "错误：Fullcone 补丁应用失败！"; exit 1; }
echo "Fullcone 补丁应用完成。"

# 8. 修改默认 IP 和主机名
sed -i 's/192.168.1.1/10.10.21.1/g' package/base-files/files/bin/config_generate
