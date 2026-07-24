<img width="768" src="https://github.com/openwrt/openwrt/blob/main/include/logo.png"/>

自用固件，主要插件有：zerotier、lucky、mwan3、sqm、frpc、pass wall、opencalsh、openwrt-sonic-fullcone

## 特别提示 [![](https://img.shields.io/badge/-个人免责声明-FFFFFF.svg)](#特别提示-)

- **本人不对任何人因使用本固件所遭受的任何理论或实际的损失承担责任！**

- **本固件禁止用于任何商业用途，请务必严格遵守国家互联网使用相关法律规定！**
  
部分插件开启方式
一、验证并开启bbr
第一步：确认BBR模块已加载

首先，通过SSH登录到你的OpenWrt设备，运行以下命令检查BBR内核模块是否已加载：
bash

lsmod | grep bbr

    如果看到 tcp_bbr：说明模块已加载，可以跳过第二步。

    如果没有输出：说明模块未加载，需要手动加载。

⚙️ 第二步：加载BBR模块（如需要）

如果上一步未发现BBR模块，使用以下命令手动加载：
bash

modprobe tcp_bbr

🚀 第三步：临时启用BBR

执行以下命令，将系统的TCP拥塞控制算法立即切换为BBR：
bash

sysctl -w net.ipv4.tcp_congestion_control=bbr

💾 第四步：永久生效（配置持久化）

为了让BBR在路由器重启后依然生效，需要修改配置文件。

方法一：修改 /etc/sysctl.conf （推荐）

这是最通用的方法。使用文本编辑器（如vi）打开 /etc/sysctl.conf 文件，在文件末尾添加以下两行：
text

net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr

net.core.default_qdisc=fq 这行用于设置默认的队列规则，是BBR发挥最佳性能的常用搭配。

保存文件后，运行以下命令使配置生效：
bash

sysctl -p

方法二：利用 kmod-tcp-bbr 包自带配置文件（备选）

安装 kmod-tcp-bbr 包后，系统可能会自动生成一个配置文件（如 /etc/sysctl.d/12-tcp-bbr.conf）。但已知该文件可能缺少 net.core.default_qdisc=fq 这行配置，导致性能不佳。如果你选择这个方法，请务必检查并补全这行配置。
✅ 第五步：验证BBR是否生效

执行以下命令，确认当前正在使用的TCP拥塞控制算法：
bash

sysctl net.ipv4.tcp_congestion_control

如果输出 net.ipv4.tcp_congestion_control = bbr，则表示BBR已成功启用。

二、开启openwrt-sonic-fullcone请查看https://github.com/mufeng05/openwrt-sonic-fullcone

<a href="#readme">
<img src="https://img.shields.io/badge/-返回顶部-FFFFFF.svg" title="返回顶部" align="right"/>
</a>
