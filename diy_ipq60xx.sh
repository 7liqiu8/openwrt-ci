#!/bin/bash
set -e   # 遇到任何错误立即退出，可代替部分 || exit 1

# 1. 彻底清理旧版 mwan3
find . -type d -name "mwan3" -exec rm -rf {} \; 2>/dev/null || true
find . -type d -name "luci-app-mwan3" -exec rm -rf {} \; 2>/dev/null || true
find . -type d -name "luci-app-syncdial" -exec rm -rf {} \; 2>/dev/null || true
# 同时清理可能存在的旧符号链接
find package/feeds -type l -name "luci-app-mwan3" -delete 2>/dev/null || true

# 2. 克隆新版 mwan3 核心
git clone --depth=1 https://github.com/dl12345/mwan3.git package/network/mwan3 || exit 1

# 3. 修正依赖名
sed -i 's/libnetfilter_conntrack/libnetfilter-conntrack/g' package/network/mwan3/Makefile

# 4. 克隆并安装配套 LuCI 界面
rm -rf feeds/luci/applications/luci-app-mwan3
git clone --depth=1 https://github.com/dl12345/luci-app-mwan3.git feeds/luci/applications/luci-app-mwan3 || exit 1
./scripts/feeds install luci-app-mwan3 || exit 1

# 5. 确保 mwan3 核心依赖已安装（防止缺失）
./scripts/feeds install libnetfilter-conntrack || exit 1

# 6. 清理旧版 lucky 并克隆
find . -type d -name "lucky" -exec rm -rf {} \; 2>/dev/null || true
git clone --depth=1 https://github.com/gdy666/luci-app-lucky package/lucky || exit 1

# 7. 应用 Fullcone NAT 补丁
echo "正在应用 Fullcone NAT 补丁..."
curl -sSL https://raw.githubusercontent.com/mufeng05/openwrt-sonic-fullcone/master/add_sonic_fullcone.sh | \
  sed '/^# --- firewall4/,/^echo "\[fw4\]/d' | \
  bash || { echo "错误：Fullcone 补丁应用失败！"; exit 1; }
echo "Fullcone 补丁应用完成。"

# 8. 修改默认 IP 和主机名
sed -i 's/192.168.1.1/10.10.21.1/g' package/base-files/files/bin/config_generate
