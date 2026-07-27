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

echo "===== 开始  修改软件源====="

# ===== 固定版本选择（根据你的分支手动修改这一行）=====

IM_VERSION="25.12.1"   # 改成你需要的版本
# =====================================================

BASE_URL="https://downloads.immortalwrt.org/releases/${IM_VERSION}"
CORE_URL="${BASE_URL}/targets/x86/64/packages"
ARCH_URL="${BASE_URL}/packages/x86_64"

# 判断主版本号，决定使用 OPKG 还是 APK 配置
MAJOR_VER=$(echo "$IM_VERSION" | cut -d. -f1)
if [ "$MAJOR_VER" -ge 25 ]; then
    # ===== APK 方式（OpenWrt 25.xx 及更高）=====
    mkdir -p files/etc/apk
    cat > files/etc/apk/repositories <<EOF
${CORE_URL}
${ARCH_URL}/base
${ARCH_URL}/luci
${ARCH_URL}/packages
${ARCH_URL}/routing
${ARCH_URL}/telephony
EOF
    # APK 默认强制验证签名，这里创建空文件并告知用户如何跳过
    echo "APK 签名默认开启，刷机后请执行: apk update --allow-untrusted"
    # 如果你想直接禁用签名，可以创建一个 keys 目录但不放入任何公钥，
    # 然后用户必须加参数，无法完全静默，建议将提醒写入 /etc/rc.local 或 /etc/motd
    echo "已写入 APK 源，版本：${IM_VERSION}"
    cat files/etc/apk/repositories

else
    # ===== OPKG 方式（OpenWrt 24.10 及更低）=====
    mkdir -p files/etc/opkg
    cat > files/etc/opkg/distfeeds.conf <<EOF
src/gz immortalwrt_core ${CORE_URL}
src/gz immortalwrt_base ${ARCH_URL}/base
src/gz immortalwrt_luci ${ARCH_URL}/luci
src/gz immortalwrt_packages ${ARCH_URL}/packages
src/gz immortalwrt_routing ${ARCH_URL}/routing
src/gz immortalwrt_telephony ${ARCH_URL}/telephony
EOF
    echo "option check_signature 0" >> files/etc/opkg.conf
    echo "已写入 OPKG 源，版本：${IM_VERSION}"
    cat files/etc/opkg/distfeeds.conf
fi

echo "===== 结束  修改软件源====="

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

#  修改 IP 和主机名
sed -i 's/192.168.1.1/10.10.10.1/g' package/base-files/files/bin/config_generate
#sed -i "s/ImmortalWrt/OpenWrt/g" package/base-files/files/bin/config_generate
