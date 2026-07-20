#!/bin/bash

# 1. 彻底清理旧版 mwan3（包括 feeds 中的）
find . -type d -name "mwan3" -exec rm -rf {} \; 2>/dev/null || true
find . -type d -name "luci-app-mwan3" -exec rm -rf {} \; 2>/dev/null || true
find . -type d -name "luci-app-syncdial" -exec rm -rf {} \; 2>/dev/null || true

# 2. 克隆新版 mwan3 核心到标准网络包目录
git clone --depth=1 https://github.com/dl12345/mwan3.git package/network/mwan3 || exit 1

# 3. 修正依赖名
sed -i 's/libnetfilter_conntrack/libnetfilter-conntrack/g' package/network/mwan3/Makefile

# 4. 克隆配套的 LuCI 界面到正确的 feeds 位置（这样才能找到 luci.mk）
rm -rf feeds/luci/applications/luci-app-mwan3
git clone --depth=1 https://github.com/dl12345/luci-app-mwan3.git feeds/luci/applications/luci-app-mwan3 || exit 1

# 确保 libnetfilter-conntrack 已被 feeds 安装（否则编译 mwan3 会失败）
./scripts/feeds install libnetfilter-conntrack || {
    echo "错误：无法安装 libnetfilter-conntrack"
    exit 1
}

# 5. 清理旧版 lucky 并克隆
find . -type d -name "lucky" -exec rm -rf {} \; 2>/dev/null || true
git clone --depth=1 https://github.com/gdy666/luci-app-lucky package/lucky || exit 1

rm -rf package/emortal/luci-app-athena-led
git clone --depth=1 https://github.com/NONGFAH/luci-app-athena-led package/luci-app-athena-led
chmod +x package/luci-app-athena-led/root/etc/init.d/athena_led package/luci-app-athena-led/root/usr/sbin/athena-led

# 应用 Sonic Fullcone NAT 补丁（跳过与 25.12 不兼容的 firewall4 补丁）
echo "正在应用 Fullcone NAT 补丁..."
curl -sSL https://raw.githubusercontent.com/mufeng05/openwrt-sonic-fullcone/master/add_sonic_fullcone.sh | \
  sed '/^# --- firewall4/,/^echo "\[fw4\]/d' | \
  bash || {
    echo "错误：Fullcone 补丁应用失败！"
    exit 1
}
echo "Fullcone 补丁应用完成。"

sed -i 's/192.168.1.1/10.10.21.1/g' package/base-files/files/bin/config_generate
sed -i "s/ImmortalWrt/OpenWrt/g" package/base-files/files/bin/config_generate
