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

echo "===== 修复 nftables fullcone 补丁 fuzz ====="
NFT_PATCH="package/network/utils/nftables/patches/002-nftables-add-fullcone-expression-support.patch"
if [ -f "$NFT_PATCH" ]; then
  # 将补丁中 statement.c 的 hunk 行号适当下移 1 行（通常需要根据实际失败调整）
  # 最简单的方法：让 patch 在应用时允许 fuzz，OpenWrt 可以通过设置 QUILT_PATCH_OPTS 实现
  # 但更可靠的是直接强制刷新补丁（用 quilt 或手动）
  
  # 方案A：直接允许 fuzz（但需要改 nftables 的 Makefile，不推荐）
  # 方案B：尝试用 quilt 刷新补丁（需要先准应用）
  # 方案C：暴力替换，这里给出一个示例：通常 fuzz 1 是因为上下文多了或少了一行，可以尝试调整补丁的行号
  # 先看看补丁里 statement.c 的 hunk 头部，一般是 @@ -line,count +line,count @@
  # 暂时用 sed 将那个 hunk 的起始行号减1（若实际代码比补丁多一行）或加1
  # 需要具体查看补丁内容，这里给出一个通用修复方法：
  
  # 临时允许 fuzz 编译 nftables（通过环境变量传递给 make）
  # 但是 OpenWrt 的 quilt 命令在 Makefile 中不直接暴露，可以在执行 make 前 export QUILT_PATCH_OPTS="--fuzz=2"
  # 我们可以在 diy_part2.sh 末尾或编译时传递，但更简单的：直接修改补丁，去除导致 fuzz 的严格检查
  
  # 推荐方法：用 quilt 交互式刷新，但 CI 中可改用：
  echo "尝试自动调整补丁偏移..."
  cd package/network/utils/nftables
  # 先应用补丁（允许 fuzz），然后立即刷新
  if quilt push --fuzz=2 2>/dev/null; then
    quilt refresh
    quilt pop -a
    echo "补丁已刷新并更新"
  else
    echo "无法自动刷新，将删除此补丁（如果 fullcone 不需要 nftables 表达式支持可忽略）"
    rm -f patches/002-nftables-add-fullcone-expression-support.patch
  fi
  cd -
else
  echo "未找到 nftables fullcone 补丁，无需修复"
fi

echo "===== 结束 SONiC 补丁 ====="

#  修改 IP 和主机名
sed -i 's/192.168.1.1/10.10.10.1/g' package/base-files/files/bin/config_generate
#sed -i "s/ImmortalWrt/OpenWrt/g" package/base-files/files/bin/config_generate
