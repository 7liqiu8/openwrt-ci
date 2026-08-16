#!/bin/bash
set -e

echo "===== 开始 ./scripts/feeds update -a ====="

./scripts/feeds update -a

echo "===== 结束 ./scripts/feeds update -a ====="

echo "===== 开始 检测并删除旧或自带插件 ====="

# 删除 feeds 中所有 zerotier 相关目录（本体 + Luci + 依赖）
# find feeds -type d \( -name "zerotier" -o -name "luci-app-zerotier" \) -exec rm -rf {} \; 2>/dev/null || true
# 如果之前编译过，也删除 package/feeds 里的符号链接
# find package/feeds -type l \( -name "zerotier" -o -name "luci-app-zerotier" \) -delete 2>/dev/null || true

# 删除 mwan3 相关
find feeds -type d \( -name "mwan3" -o -name "luci-app-mwan3" -o -name "luci-app-syncdial" \) -exec rm -rf {} \; 2>/dev/null || true
find package/feeds -type l \( -name "mwan3" -o -name "luci-app-mwan3" -o -name "luci-app-syncdial" \) -delete 2>/dev/null || true

# 删除 lucky
find feeds -type d -name "lucky" -exec rm -rf {} \; 2>/dev/null || true
find package/feeds -type l -name "lucky" -delete 2>/dev/null || true

# 删除 turboacc 相关包（避免与自定义 package/turboacc 冲突）
find feeds -type d \( -name "luci-app-turboacc" -o -name "fullconenat" -o -name "fullconenat-nft" -o -name "shortcut-fe" -o -name "turboacc" \) -exec rm -rf {} \; 2>/dev/null || true
find package/feeds -type l \( -name "luci-app-turboacc" -o -name "fullconenat" -o -name "fullconenat-nft" -o -name "shortcut-fe" -o -name "turboacc" \) -delete 2>/dev/null || true

echo "===== 结束 检测并删除旧或自带插件 ====="

echo "===== 开始 ./scripts/feeds update -i ====="

./scripts/feeds update -i

echo "===== 结束 ./scripts/feeds update -i ====="

echo "===== 开始 ./scripts/feeds install -a ====="

./scripts/feeds install -a

echo "===== 结束 ./scripts/feeds install -a ====="
