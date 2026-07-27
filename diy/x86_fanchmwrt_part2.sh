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

echo "===== 开始  修改软件源====="

# 获取源码版本号（例如 24.10.6、25.12.4）
VERSION=$(grep -oP '^VERSION_NUMBER:=\K.*' include/version.mk | tr -d ' ')
echo "检测到源码版本: $VERSION"

# 定义每个系列在 ImmortalWrt 中的最高已知版本
MAX_24_10="24.10.6"
MAX_25_12="25.12.1"

case "$VERSION" in
  24.10.*)
    # 比较小版本号，如果源码版本高于已知最高，则回退
    SRC_VER=$(echo "$VERSION" | sed 's/24.10\.//')
    MAX_VER=$(echo "$MAX_24_10" | sed 's/24.10\.//')
    if [ "$SRC_VER" -gt "$MAX_VER" ]; then
      IM_VERSION="$MAX_24_10"
      echo "注意: 源码版本 $VERSION 超过已知最高 $MAX_24_10，已回退"
    else
      IM_VERSION="$VERSION"
    fi
    ;;
  25.12.*)
    SRC_VER=$(echo "$VERSION" | sed 's/25.12\.//')
    MAX_VER=$(echo "$MAX_25_12" | sed 's/25.12\.//')
    if [ "$SRC_VER" -gt "$MAX_VER" ]; then
      IM_VERSION="$MAX_25_12"
      echo "注意: 源码版本 $VERSION 超过已知最高 $MAX_25_12，已回退"
    else
      IM_VERSION="$VERSION"
    fi
    ;;
  *)
    echo "错误: 未匹配到 24.10 或 25.12 系列，请手动指定版本"
    exit 1
    ;;
esac

# 构建源地址
BASE_URL="https://downloads.immortalwrt.org/releases/${IM_VERSION}"
CORE_URL="${BASE_URL}/targets/x86/64/packages"
ARCH_URL="${BASE_URL}/packages/x86_64"

mkdir -p files/etc/opkg
cat > files/etc/opkg/distfeeds.conf <<EOF
src/gz immortalwrt_core ${CORE_URL}
src/gz immortalwrt_base ${ARCH_URL}/base
src/gz immortalwrt_luci ${ARCH_URL}/luci
src/gz immortalwrt_packages ${ARCH_URL}/packages
src/gz immortalwrt_routing ${ARCH_URL}/routing
src/gz immortalwrt_telephony ${ARCH_URL}/telephony
EOF

# 禁用签名检查（后续可替换为添加公钥）
echo "option check_signature 0" >> files/etc/opkg.conf

echo "已生成 ImmortalWrt 源 (版本 ${IM_VERSION})："
cat files/etc/opkg/distfeeds.conf

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
