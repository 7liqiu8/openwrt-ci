#!/bin/bash
# set -e

./scripts/feeds update -a

# 删除 mwan3 相关（feeds 目录 + 旧符号链接）
find feeds -type d \( -name "mwan3" -o -name "luci-app-mwan3" -o -name "luci-app-syncdial" \) -exec rm -rf {} \; 2>/dev/null
find package/feeds -type l \( -name "mwan3" -o -name "luci-app-mwan3" -o -name "luci-app-syncdial" \) -delete 2>/dev/null

# 删除 lucky（建议限定 feeds）
find feeds -type d -name "lucky" -exec rm -rf {} \; 2>/dev/null
find package/feeds -type l -name "lucky" -delete 2>/dev/null

# 删除 argon
find feeds -type d \( -name "luci-theme-argon" -o -name "luci-app-argon-config" \) -exec rm -rf {} \; 2>/dev/null
find package/feeds -type l \( -name "luci-theme-argon" -o -name "luci-app-argon-config" \) -delete 2>/dev/null

./scripts/feeds update -i
./scripts/feeds install -a

# 添加 mwan3 核心包
git clone --depth=1 https://github.com/dl12345/mwan3.git package/mwan3
sed -i 's/libnetfilter_conntrack/libnetfilter-conntrack/g' package/mwan3/Makefile
git clone --depth=1 https://github.com/dl12345/luci-app-mwan3.git package/luci-app-mwan3

# 添加 lucky
git clone --depth=1 https://github.com/gdy666/luci-app-lucky package/lucky

# 添加 argon 主题
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config

#  删除冲突的 firewall4 旧补丁
rm -f package/network/utils/nftables/patches/001-drop-useless-file.patch
rm -f package/network/utils/nftables/patches/002-nftables-add-fullcone-expression-support.patch

#  运行 SONiC 补丁脚本
curl -sSL -o add_sonic_fullcone.sh \
  https://raw.githubusercontent.com/mufeng05/openwrt-sonic-fullcone/master/add_sonic_fullcone.sh
chmod +x add_sonic_fullcone.sh
./add_sonic_fullcone.sh

#  清理 firewall4 的编译残留
make package/network/config/firewall4/clean V=s

#  修改 IP 和主机名
sed -i 's/192.168.1.1/10.10.60.1/g' package/base-files/files/bin/config_generate
sed -i "s/ImmortalWrt/OpenWrt/g" package/base-files/files/bin/config_generate
