#!/bin/bash

set -e

# 修改 Makefile
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHREPO/PKG_SOURCE_URL:=https:\/\/github.com/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload.github.com/g' {}

echo "===== 开始 ./scripts/feeds update -a ====="

./scripts/feeds update -a

echo "===== 结束 ./scripts/feeds update -a ====="

echo "===== 开始 检测并删除旧或自带插件 ====="

# 删除 mwan3 相关
find feeds -type d \( -name "mwan3" -o -name "luci-app-mwan3" -o -name "luci-app-syncdial" \) -exec rm -rf {} \; 2>/dev/null || true
find package/feeds -type l \( -name "mwan3" -o -name "luci-app-mwan3" -o -name "luci-app-syncdial" \) -delete 2>/dev/null || true

# 删除 lucky
find feeds -type d -name "lucky" -exec rm -rf {} \; 2>/dev/null || true
find package/feeds -type l -name "lucky" -delete 2>/dev/null || true

# 删除 argon
find feeds -type d \( -name "luci-theme-argon" -o -name "luci-app-argon-config" \) -exec rm -rf {} \; 2>/dev/null || true
find package/feeds -type l \( -name "luci-theme-argon" -o -name "luci-app-argon-config" \) -delete 2>/dev/null || true

echo "===== 结束 检测并删除旧或自带插件 ====="

echo "===== 开始 ./scripts/feeds update -i ====="

./scripts/feeds update -i

echo "===== 结束 ./scripts/feeds update -i ====="

echo "===== 开始 ./scripts/feeds install -a ====="

./scripts/feeds install -a

echo "===== 结束 ./scripts/feeds install -a ====="
