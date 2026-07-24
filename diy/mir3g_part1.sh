#!/bin/bash
# set -e

echo "===== 开始修改feeds.conf.default ====="

# 如果 feeds.conf.default 中还没有 passwall_packages，则追加
if ! grep -q "passwall_packages" feeds.conf.default; then
    echo "src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git" >> feeds.conf.default
fi

echo "===== 结束修改feeds.conf.default ====="

./scripts/feeds update -a


# 删除 lucky（建议限定 feeds）
find feeds -type d -name "lucky" -exec rm -rf {} \; 2>/dev/null
find package/feeds -type l -name "lucky" -delete 2>/dev/null

./scripts/feeds update -i
./scripts/feeds install -a
