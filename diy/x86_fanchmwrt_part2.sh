#!/bin/bash
set -e

echo "===== 开始 拉取额外插件 ====="

# 添加 mwan3 核心包
git clone --depth=1 https://github.com/dl12345/mwan3.git package/mwan3 || exit 1
sed -i 's/libnetfilter_conntrack/libnetfilter-conntrack/g' package/mwan3/Makefile || exit 1
git clone --depth=1 https://github.com/dl12345/luci-app-mwan3.git package/luci-app-mwan3 || exit 1

echo "===== 结束 拉取mwan3 ====="

# 添加 lucky
git clone --depth=1 https://github.com/gdy666/luci-app-lucky.git package/lucky || exit 1

echo "===== 结束 拉取lucky ====="


#  添加pass wall2
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall2 package/luci-app-passwall2 || exit 1

echo "===== 结束 拉取passwall2 ====="

echo "===== 结束 拉取额外插件 ====="

echo "===== 开始  SONiC 补丁并运行====="

#  删除冲突的 firewall4 旧补丁
rm -f package/network/config/firewall4/patches/001-firewall4-add-support-for-fullcone-nat.patch
rm -rf package/network/utils/fullconenat-nft

#  运行 SONiC 补丁脚本
curl -sSL -o add_sonic_fullcone.sh \
  https://raw.githubusercontent.com/mufeng05/openwrt-sonic-fullcone/master/add_sonic_fullcone.sh
chmod +x add_sonic_fullcone.sh
./add_sonic_fullcone.sh

echo "===== 修复 nft_fullcone_validate 内核 6.6 兼容性 ====="
# 查找包含该函数的 patch 文件（通常由 SONiC 脚本放入 hack-6.6 目录）
PATCH_FILE=$(find target/linux/generic/hack-6.6/ package/kernel/linux/ -name "*.patch" -exec grep -l "nft_fullcone_validate" {} + 2>/dev/null | head -n1)

if [ -n "$PATCH_FILE" ]; then
  # 将函数定义从两参数改为三参数
  # 假设原补丁形式为：
  # +static int nft_fullcone_validate(const struct nft_ctx *ctx,
  # +				 const struct nft_expr *expr)
  #
  # 用 sed 在 expr 行后插入一个新行，追加第三个参数
  sed -i '/^+static int nft_fullcone_validate/,/^+[^{]/ {
    /const struct nft_expr \*expr)/ s/)/, const struct nft_data \**data)/
  }' "$PATCH_FILE"
  echo "已修复补丁: $PATCH_FILE"
else
  echo "警告: 未找到包含 nft_fullcone_validate 的补丁，可能脚本未生成或路径变化。"
fi


echo "===== 结束 SONiC 补丁 ====="

#  修改 IP 和主机名
sed -i 's/192.168.1.1/10.10.10.1/g' package/base-files/files/bin/config_generate
#sed -i "s/ImmortalWrt/OpenWrt/g" package/base-files/files/bin/config_generate
