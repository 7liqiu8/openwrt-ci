#!/bin/bash
set -e

echo "===== 开始 拉取额外插件 ====="

# 添加 mwan3 核心包
git clone --depth=1 https://github.com/dl12345/mwan3.git package/mwan3 || exit 1
sed -i 's/libnetfilter_conntrack/libnetfilter-conntrack/g' package/mwan3/Makefile || exit 1
git clone --depth=1 https://github.com/dl12345/luci-app-mwan3.git package/luci-app-mwan3 || exit 1

echo "===== 结束 拉取mwan3 ====="

# 添加 lucky
git clone --depth=1 https://github.com/gdy666/luci-app-lucky.git package/lucky || exit 1

echo "===== 结束 拉取lucky ====="

#  添加pass wall2
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall2 package/luci-app-passwall2 || exit 1

echo "===== 结束 拉取passwall2 ====="

echo "===== 结束 拉取额外插件 ====="

echo "===== 开始  SONiC 补丁并运行====="

make oldconfig

#  删除冲突的 firewall4 旧补丁
rm -f package/network/config/firewall4/patches/001-firewall4-add-support-for-fullcone-nat.patch

#  运行 SONiC 补丁脚本
curl -sSL -o add_sonic_fullcone.sh \
  https://raw.githubusercontent.com/mufeng05/openwrt-sonic-fullcone/master/add_sonic_fullcone.sh
chmod +x add_sonic_fullcone.sh
./add_sonic_fullcone.sh


echo "===== 结束 SONiC 补丁 ====="

#  修改 IP 和主机名
sed -i 's/192.168.1.1/10.10.87.1/g' package/base-files/files/bin/config_generate
#sed -i "s/ImmortalWrt/OpenWrt/g" package/base-files/files/bin/config_generate
