#!/bin/bash

# 1. 彻底删除所有旧版 mwan3 和 luci-app-mwan3
find . -type d \( -name "mwan3" -o -name "luci-app-mwan3" -o -name "luci-app-syncdial" \) -exec rm -rf {} \; 2>/dev/null || true

# 2. 克隆新版 mwan3 核心到 package/
git clone --depth=1 https://github.com/dl12345/mwan3.git package/mwan3
sed -i 's/libnetfilter_conntrack/libnetfilter-conntrack/g' package/mwan3/Makefile

# 3. 克隆新版 luci-app-mwan3 到 package/
git clone --depth=1 https://github.com/dl12345/luci-app-mwan3.git package/luci-app-mwan3

# 4. lucky 仍可放在 package/lucky
find . -type d -name "lucky" -exec rm -rf {} \; 2>/dev/null || true
git clone --depth=1 https://github.com/gdy666/luci-app-lucky package/lucky


# 修改默认 IP 和主机名
sed -i 's/192.168.1.1/10.10.21.1/g' package/base-files/files/bin/config_generate
