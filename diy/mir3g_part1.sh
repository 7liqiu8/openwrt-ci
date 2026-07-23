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
