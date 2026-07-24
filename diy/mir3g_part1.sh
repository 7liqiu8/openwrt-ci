#!/bin/bash
# set -e


./scripts/feeds update -a

# 删除 lucky（建议限定 feeds）
find feeds -type d -name "lucky" -exec rm -rf {} \; 2>/dev/null
find package/feeds -type l -name "lucky" -delete 2>/dev/null

./scripts/feeds install -a
