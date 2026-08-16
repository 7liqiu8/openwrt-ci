#!/bin/bash

set -e

echo "===== 开始 拉取额外插件 ====="

# 添加 lucky
git clone --depth=1 https://github.com/gdy666/luci-app-lucky.git package/lucky || exit 1

echo "===== 结束 拉取lucky ====="

git clone --depth=1 https://github.com/EasyTier/luci-app-easytier.git package/luci-app-easytier || exit 1

echo "===== 结束 拉取easytier ====="

# 运行 turboacc 集成脚本（它会复制所有补丁，包括我们不需要的 952/953/613）
curl -sSL https://raw.githubusercontent.com/mufeng05/turboacc/main/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh

#  修改 IP 和主机名
sed -i 's/192.168.1.1/10.10.60.1/g' package/base-files/files/bin/config_generate
sed -i "s/ImmortalWrt/OpenWrt/g" package/base-files/files/bin/config_generate
