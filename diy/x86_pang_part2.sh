#!/bin/bash
set -e

echo "===== 开始 拉取额外插件 ====="

# 添加 mwan3 核心包
git clone --depth=1 https://github.com/dl12345/mwan3.git package/mwan3 || exit 1
sed -i 's/libnetfilter_conntrack/libnetfilter-conntrack/g' package/mwan3/Makefile || exit 1

# 克隆 luci-app-mwan3
git clone --depth=1 https://github.com/dl12345/luci-app-mwan3.git package/luci-app-mwan3 || exit 1

# 修复 include 路径（从 ../../luci.mk 改成 feeds 中的正确位置）
sed -i 's|^include ../../luci.mk|include $(TOPDIR)/feeds/luci/luci.mk|' package/luci-app-mwan3/Makefile

# 补上缺失的 PKG_NAME
sed -i '/^include $(TOPDIR)\/rules.mk$/a\PKG_NAME:=luci-app-mwan3' package/luci-app-mwan3/Makefile

echo "===== 结束 拉取mwan3 ====="

# 添加 lucky
git clone --depth=1 https://github.com/gdy666/luci-app-lucky.git package/lucky || exit 1

echo "===== 结束 拉取lucky ====="

#  添加pass wall
# git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall.git package/luci-app-passwall || exit 1

# echo "===== 结束 拉取passwall ====="

#  添加pass wall2
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall2.git package/luci-app-passwall2 || exit 1

echo "===== 结束 拉取passwall2 ====="

#  添加openclash
# git clone --depth=1 https://github.com/vernesong/OpenClash.git package/luci-app-openclash || exit 1

# echo "===== 结束 拉取openclash ====="

git clone --depth=1 https://github.com/EasyTier/luci-app-easytier.git package/luci-app-easytier || exit 1

echo "===== 结束 拉取easytier ====="

echo "===== 结束 拉取额外插件 ====="

echo "===== 开始  turbo acc 补丁并运行====="

# 运行 turboacc 集成脚本（它会复制所有补丁，包括我们不需要的 952/953/613）
curl -sSL https://raw.githubusercontent.com/mufeng05/turboacc/main/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh

# 删除所有 shortcut-fe 软件加速内核补丁（nftables 防火墙不需要）
rm -f target/linux/generic/hack-6.12/952-add-net-conntrack-events-support-multiple-registrant.patch
rm -f target/linux/generic/hack-6.12/953-net-patch-linux-kernel-to-support-shortcut-fe.patch
# rm -f target/linux/generic/pending-6.12/613-netfilter_optional_tcp_window_check.patch

# 同时删除 shortcut-fe 用户态软件包（避免编译时选择它）
rm -rf package/turboacc/shortcut-fe

echo "===== 结束 turbo acc 补丁 ====="


#  修改 IP 和主机名
sed -i 's/192.168.1.1/10.10.10.2/g' package/base-files/files/bin/config_generate
#sed -i "s/ImmortalWrt/OpenWrt/g" package/base-files/files/bin/config_generate
