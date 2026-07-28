#!/bin/bash
set -e

echo "===== 开始 拉取额外插件 ====="

# 添加 mwan3 核心包
git clone --depth=1 https://github.com/dl12345/mwan3.git package/mwan3 || exit 1
sed -i 's/libnetfilter_conntrack/libnetfilter-conntrack/g' package/mwan3/Makefile || exit 1
git clone --depth=1 https://github.com/dl12345/luci-app-mwan3.git package/luci-app-mwan3 || exit 1

cat >> package/luci-app-mwan3/Makefile <<'EOF'

$(eval $(call BuildPackage,luci-app-mwan3))
EOF

echo "===== 结束 拉取mwan3 ====="

# 添加 lucky
git clone --depth=1 https://github.com/gdy666/luci-app-lucky.git package/lucky || exit 1

echo "===== 结束 拉取lucky ====="

echo "===== 结束 拉取额外插件 ====="

echo "===== 开始  SONiC 补丁并运行====="

#  删除冲突的 firewall4 旧补丁
rm -f package/network/config/firewall4/patches/001-firewall4-add-support-for-fullcone-nat.patch
# rm -rf package/network/utils/fullconenat-nft

#  运行 SONiC 补丁脚本
curl -sSL -o add_sonic_fullcone.sh \
  https://raw.githubusercontent.com/mufeng05/openwrt-sonic-fullcone/master/add_sonic_fullcone.sh
chmod +x add_sonic_fullcone.sh
./add_sonic_fullcone.sh

echo "===== 结束 SONiC 补丁 ====="

echo "===== 开始 固化内核 BBR 选项 ====="
# 获取内核版本号
KERNEL_VER=$(ls target/linux/generic/ | grep -E '^config-[0-9.]+$' | sort -V | tail -1 | sed 's/^config-//')
if [ -z "$KERNEL_VER" ]; then
    KERNEL_VER=$(grep LINUX_KERNEL_VERSION include/kernel-version.mk 2>/dev/null | sed 's/.*=\s*//')
fi

# 可能的内核配置文件位置（generic 和 x86）
CONFIG_FILES=(
    "target/linux/generic/config-${KERNEL_VER}"
    "target/linux/x86/config-${KERNEL_VER}"
)
FOUND=0
for CFG in "${CONFIG_FILES[@]}"; do
    if [ -f "$CFG" ]; then
        echo "正在向 $CFG 添加内核 BBR 选项"
        # 避免重复添加，先检查是否已存在
        if grep -q "CONFIG_TCP_CONG_BBR=y" "$CFG"; then
            echo "BBR 选项已存在于 $CFG，跳过"
        else
            cat >> "$CFG" <<'EOF'
CONFIG_NET_SCHED=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BBR=y
CONFIG_DEFAULT_TCP_CONG="bbr"
CONFIG_NET_SCH_FQ=y
EOF
        fi
        FOUND=1
    fi
done

if [ $FOUND -eq 0 ]; then
    echo "❌ 错误：未找到任何内核配置文件，无法固化 BBR"
    exit 1
fi
echo "===== 结束 固化内核 BBR 选项 ====="

#  修改 IP 和主机名
sed -i 's/192.168.1.1/10.10.10.1/g' package/base-files/files/bin/config_generate
#sed -i "s/ImmortalWrt/OpenWrt/g" package/base-files/files/bin/config_generate
