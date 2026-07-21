#!/bin/bash
# set -e

./scripts/feeds update -a


# 删除 lucky（建议限定 feeds）
find feeds -type d -name "lucky" -exec rm -rf {} \; 2>/dev/null
find package/feeds -type l -name "lucky" -delete 2>/dev/null

# 删除 argon
find feeds -type d \( -name "luci-theme-argon" -o -name "luci-app-argon-config" \) -exec rm -rf {} \; 2>/dev/null
find package/feeds -type l \( -name "luci-theme-argon" -o -name "luci-app-argon-config" \) -delete 2>/dev/null

./scripts/feeds update -i
./scripts/feeds install -a


# 添加 lucky
git clone --depth=1 https://github.com/gdy666/luci-app-lucky package/lucky

# 添加 argon 主题
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config


#  修改 IP 和主机名
sed -i 's/192.168.1.1/10.10.60.1/g' package/base-files/files/bin/config_generate
sed -i "s/ImmortalWrt/OpenWrt/g" package/base-files/files/bin/config_generate
