<div align="center">

# 🌟 【米粒儿 Sing-box 全家桶】 🌟

[![GitHub Stars](https://img.shields.io/github/stars/milier-rice/sing-box-family?style=flat-square&logo=github&color=yellow)](https://github.com/milier-rice/sing-box-family)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![TG Group](https://img.shields.io/badge/Telegram-Join_Group-blue?style=flat-square&logo=telegram)](https://t.me/mlkjfx6)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-red?style=flat-square&logo=youtube)](https://youtube.com/@米粒儿813)

**🎯 一键部署多协议代理服务器 | 支持 11+ 协议 | 自适应客户端订阅**

**📱 作者：米粒儿**  
**💬 TG 交流群：[@https://t.me/mlkjfx6](https://t.me/mlkjfx6)**  
**🎥 油管频道：[youtube.com/@米粒儿813](https://youtube.com/@米粒儿813)**

</div>

---

## 🎯 **快速导航**

<details>
<summary>📑 点击展开完整目录</summary>

- [🔄 更新日志](#-更新日志)
- [✨ 项目特色](#-项目特色)
- [🚀 VPS 运行脚本](#-vps-运行脚本)
- [⚡ 无交互极速安装](#-无交互极速安装)
- [🌐 Token Argo Tunnel 设置](#-token-argo-tunnel-设置)
- [📡 Vmess/Vless CDN 设置](#-vmessvless-cdn-设置)
- [🐳 Docker 容器部署](#-docker-容器部署)
- [🔧 Nekobox 配置教程](#-nekobox-配置教程)
- [📂 目录结构说明](#-目录结构说明)
- [💝 赞助支持](#-赞助支持)
- [⚖️ 免责声明](#️-免责声明)

</details>


---

## 🔄 **更新日志**

<div align="center">

### 🎉 **最新版本** `v1.2.18` - 2025.08.27

> 🆕 **新增 AnyTLS URI 支持** | ✅ **支持 v2rayN v7.14.3+** | 🔄 **订阅集成优化**

</div>

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| `v1.2.18` | 2025.08.27 | 🆕 支持 v2rayN v7.14.3+ AnyTLS URI，新增订阅集成功能 |
| `v1.2.17` | 2025.04.25 | 🔄 新增在线 CDN 切换功能 `[sb -d]`，更新 GitHub 代理，代码优化 |
| `v1.2.16` | 2025.04.06 | 🔧 Alpine 系统使用 OpenRC 替代 systemctl，兼容 Python3 |
| `v1.2.15` | 2025.04.05 | 📱 支持 ShadowRocket、Clash Mihomo、Sing-box 客户端输出 |
| `v1.2.14` | 2025.03.23 | ⚡ 新增 AnyTLS 协议支持，感谢 [Betterdoitnow] 提供配置 |

<details>
    <summary>历史更新 history（点击即可展开或收起）</summary>
<br>

>2025.03.18 v1.2.13 Compatible with Sing-box 1.12.0-alpha.18+; 适配 Sing-box 1.12.0-alpha.18+
>
>2025.01.31 v1.2.12 In order to prevent sing-box from upgrading to a certain version which may cause errors, add a mandatory version file; 以防止sing-box某个版本升级导致运行报错，增加强制指定版本号文件
>
>2025.01.28 v1.2.11 1. Add server-side time synchronization configuration; 2. Replace some CDNs; 3. Fix the bug of getting the latest version error when upgrading; 1. 添加服务端时间同步配置; 2. 替换某些 CDN; 3. 修复升级时获取最新版本错误的 bu
>
>2024.12.31 v1.2.10 Adapted v1.11.0-beta.17 to add port hopping for hysteria2 in sing-box client output; 适配 v1.11.0-beta.17，在 sing-box 客户端输出中添加 hysteria2 的端口跳跃
>
>2024.12.29 v1.2.9 Refactored the chatGPT detection method based on lmc999's detection and unlocking script; 根据 lmc999 的检测解锁脚本，重构了检测 chatGPT 方法
>
>2024.12.10 v1.2.8 Thank you to the veteran player Fan Glider Fangliding for the technical guidance on Warp's routing! 感谢资深玩家 风扇滑翔翼 Fangliding 关于 Warp 的分流的技术指导
>
>2024.12.10 v1.2.7 Compatible with Sing-box 1.11.0-beta.8+. Thanks to the PR from brother Maxrxf. I've already given up myself; 适配 Sing-box 1.11.0-beta.8+，感谢 Maxrxf 兄弟的 PR，我自己已经投降的了
>
>2024.10.28 v1.2.6 1. Fixed the bug that clash subscription failed when [-n] re-fetches the subscription; 2. vmess + ws encryption changed from none to auto; 3. Replaced a CDN; 1. 修复 [-n] 重新获取订阅时，clash 订阅失效的bug; 2. vmess + ws 加密方式从none改为auto; 3. 更换了一个 CDN
>
>2024.08.06 v1.2.5 Add detection of TCP brutal. Sing-box will not use this module if not installed. 增加 TCP brutal 的检测，如果没有安装，Sing-box 将不使用该模块
>
>2024.05.09 v1.2.4 Add hysteria2 port hopping. Supported Clients: ShadowRocket / NekoBox / Clash; 添加 hysteria2 的跳跃端口，支持客户端: ShadowRocket / NekoBox / Clash
>
>2024.05.06 v1.2.3 Automatically detects native IPv4 and IPv6 for warp-installed machines to minimize interference with warp ip; 对于已安装 warp 机器，自动识别原生的 IPv4 和 IPv6，以减少受 warp ip 的干扰
>
>2024.05.03 v1.2.2 Complete 8 non-interactive installation modes, direct output results. Suitable for mass installation scenarios. You can put the commands in the favorites of the ssh software. Please refer to the README.md description for details. 完善8种无交互安装模式，直接输出结果，适合大量装机的情景，可以把命令放在 ssh 软件的收藏夹，详细请参考README.md 说明
>
>2024.04.16 v1.2.1 1. Fix the bug of dynamically adding and removing protocols; 2. CentOS 7 add EPEL to install nginx; 1. 修复动态增加和删除协议的 bug; 2. CentOS 7 增加 EPEL 软件仓库，以便安装 Nginx
>
>2024.04.12 v1.2.0 1. Add Cloudflare Argo Tunnel, so that 10 protocols, including the transport mode of ws, no longer need to bring our own domain; 2. Cloudflare Argo Tunnel supports try, Json and Token methods. Use of [sb -t] online switching; 3. Cloudflare Argo Tunnel switch is [sb -a], and the Sing-box switch is changed from [sb -o] to [sb -s]; 4. If Json or Token Argo is used, the subscription address is the domain name; 5. For details: https://github.com/fscarmen/sing-box; 1. 增加 Cloudflare Argo Tunnel，让包括传输方式为ws在内的10个协议均不再需要自带域名; 2. Cloudflare Argo Tunnel 支持临时、Json 和 Token 方式，支持使用 [sb -t] 在线切换; 3.  Cloudflare Argo Tunnel 开关为 [sb -a]，Sing-box 开关从 [sb -o] 更换为 [sb -s]; 4. 若使用 Json 或者 Token 固定域名 Argo，则订阅地址则使用该域名; 5. 详细参考: https://github.com/fscarmen/sing-box
>
>2024.04.01 sing-box + argo container version is newly launched, for details: https://github.com/fscarmen/sing-box; sing-box 全家桶 + argo 容器版本全新上线，详细参考: https://github.com/fscarmen/sing-box
>
>2024.03.27 v1.1.11 Add two non-interactive installation modes: 1. pass parameter; 2.kv file, for details: https://github.com/fscarmen/sing-box; 增加两个的无交互安装模式: 1. 传参；2.kv 文件，详细参考: https://github.com/fscarmen/sing-box
>
>2024.03.26 v1.1.10 Thanks to UUb for the official change of the compilation, dependencies jq, qrencode from apt installation to download the binary file, reduce the installation time of about 15 seconds, the implementation of the project's positioning of lightweight, as far as possible to install the least system dependencies; 感谢 UUb 兄弟的官改编译，依赖 jq, qrencode 从 apt 安装改为下载二进制文件，缩减安装时间约15秒，贯彻项目轻量化的定位，尽最大可能安装最少的系统依赖
>
>2024.03.22 v1.1.9 1. In the Sing-box client, add the brutal field in the TCP protocol to make it effective; 2. Compatible with CentOS 7,8,9; 3. Remove default Github CDN; 1. 在 Sing-box 客户端，TCP 协议协议里加上 brutal 字段以生效; 2. 适配 CentOS 7,8,9; 3. 去掉默认的 Github 加速网
>
>2024.3.18 v1.1.8 Move nginx for subscription services to the systemd daemon, following sing-box startup and shutdown; 把用于订阅服务的 nginx 移到 systemd daemon，跟随 sing-box 启停
>
>2024.3.13 v1.1.7 Subscription made optional, no nginx and qrcode installed if not needed; 在线订阅改为可选项，如不需要，不安装 nginx 和 qrcode
>
>2024.3.11 v1.1.6 1. Subscription api too many problems not working properly, instead put template-2 on Github; 2. Use native IP if it supports unlocking chatGPT, otherwise use warp chained proxy unlocking; 1. 在线转订阅 api 太多问题不能正常使用，改为把模板2放Github; 2. 如自身支持解锁 chatGPT，则使用原生 IP，否则使用 warp 链式代理解锁
>
>2024.3.10 v1.1.5 1. To protect node data security, use fake information to fetch subscribe api; 2. Adaptive the above clients. http://\<server ip\>:\<nginx port\>/\<uuid\>/<uuid>/<auto | auto2>; 1. 为保护节点数据安全，在 api 转订阅时，使用虚假信息; 2. 自适应以上的客户端，http://\<server ip\>:\<nginx port\>/\<uuid\>/<auto | auto2>
>
>2024.3.4 v1.1.4 1. Support V2rayN / Nekobox / Clash / sing-box / Shadowrocket subscribe. http://\<server ip\>:\<nginx port\>/\<uuid\>/\<qr | clash | neko | proxies | shadowrocket | sing-box-pc | sing-box-phone | v2rayn\>. Index of all subscribes: http://\<server ip\>:\<nginx port\>/\<uuid\>/  . Reinstall is required; 2. Adaptive the above clients. http://\<server ip\>:\<nginx port\>/\<uuid\>/auto ; 1. 增加 V2rayN / Nekobox / Clash / sing-box / Shadowrocket 订阅，http://\<server ip\>:\<nginx port\>/\<uuid\>/\<qr | clash | neko | proxies | shadowrocket | sing-box-pc | sing-box-phone | v2rayn\>， 所有订阅的索引: http://\<server ip\>:\<nginx port\>/\<uuid\>/，需要重新安装; 2. 自适应以上的客户端，http://\<server ip\>:\<nginx port\>/\<uuid\>/auto
>
>2024.2.16 v1.1.3 1. Support v2rayN V6.33 Tuic and Hysteria2 protocol URLs; 2. Add DNS module to adapt Sing-box V1.9.0-alpha.8; 3. Reconstruct the installation protocol, add delete protocols and protocol export module, each parameter is more refined. ( Reinstall is required ); 4. Remove obfs obfuscation from Hysteria2; 1. 支持 v2rayN V6.33 Tuic 和 Hysteria2 协议 URL; 2. 增加 DNS 模块以适配 Sing-box V1.9.0-alpha.8; 3. 重构安装协议，增加删除协议及协议输出模块，各参数更精细 (需要重新安装); 4. 去掉 Hysteria2 的 obfs 混淆
>
>2023.12.25 v1.1.2 1. support Sing-box 1.8.0 latest Rule Set and Experimental; 2. api.openai.com routes to WARP IPv4, other openai websites routes to WARP IPv6; 3. Start port changes to 100; 1. 支持 Sing-box 1.8.0 最新的 Rule Set 和 Experimental; 2. api.openai.com 分流到 WARP IPv4， 其他 openai 网站分流到 WARP IPv6; 3. 开始端口改为 100
>
>2023.11.21 v1.1.1 1. XTLS + REALITY remove flow: xtls-reality-vision to support multiplexing and TCP brutal (requires reinstallation); 2. Clash meta add multiplexing parameter. 1. XTLS + REALITY 去掉 xtls-reality-vision 流控以支持多路复用和 TCP brutal (需要重新安装); 2. Clash meta 增加多路复用参数
>
>2023.11.17 v1.1.0 1. Add [ H2 + Reality ] and [ gRPC + Reality ]. Reinstall is required; 2. Use beta verion instead of alpha; 3. Support TCP brutal and add the official install script; 1. 增加 [ H2 + Reality ] 和 [ gRPC + Reality ]，需要重新安装; 2. 由于 Sing-box 更新极快，将使用 beta 版本替代 alpha 3. 支持 TCP brutal，并提供官方安装脚本
>
>2023.11.15 v1.0.1 1. Support TCP brutal. Reinstall is required; 2. Use alpha verion instead of latest; 3. Change the default CDN to [ cn.azhz.eu.org ]; 1. 支持 TCP brutal，需要重新安装; 2. 由于 Sing-box 更新极快，将使用 alpha 版本替代 latest; 3. 默认优选改为 [ cn.azhz.eu.org ]
>
>2023.10.29 v1.0 正式版 1. Sing-box Family bucket v1.0; 2. After installing, add [sb] shortcut; 3. Output the configuration for Sing-box Client; 1. Sing-box 全家桶 v1.0; 2. 安装后，增加 [sb] 的快捷运行方式; 3. 输出 Sing-box Client 配置
>
>2023.10.18 beta7 1. You can add and remove protocols at any time, need to reinstall script; 2. Adjusted the order of some protocols; 1. 可以随时添加和删除协议，需要重新安装脚本; 2. 调整了部分协议的先后顺序
>
>2023.10.16 beta6 1. Support Alpine; 2. Add Sing-box PID, runtime, and memory usage to the menu; 3. Remove the option of using warp on returning to China; 支持 Alpine; 2. 菜单中增加 sing-box 内存占用显示; 3. 去掉使用 warp 回国的选项
>
>2023.10.10 beta5 1. Add the option of blocking on returning to China; 2. Add a number of quality cdn's that are collected online; 1. 增加禁止归国选项; 2. 增加线上收录的若干优质 cdn
>
>2023.10.9 beta4 1. Add v2rayN client, ShadowTLS and Tuic based on sing-box kernel configuration file output; 2. Shadowsocks encryption from aes-256-gcm to aes-128-gcm; 3. Optimize the routing and dns of sing-box on the server side; 1. 补充 v2rayN 客户端中，ShadowTLS 和 Tuic 基于 sing-box 内核的配置文件输出; 2. Shadowsocks 加密从 aes-256-gcm 改为 aes-128-gcm; 3. 优化服务端 sing-box 的 路由和 dns
>
>2023.10.6 beta3 1. Add vmess + ws / vless + ws + tls protocols; 2. Hysteria2 add obfuscated verification of obfs; 1. 增加 vmess + ws / vless + ws + tls 协议; 2. Hysteria2 增加 obfs 混淆验证
>
>2023.10.3 beta2 1. Single-select, multi-select or select all the required protocols; 2. Support according to the order of selection, the definition of the corresponding protocol listen port number; 1. 可以单选、多选或全选需要的协议; 2. 支持根据选择的先后次序，定义相应协议监听端口号
>
>2023.9.30 beta1 Sing-box 全家桶一键脚本 for vps
</details>


---

## ✨ **项目特色**

<div align="center">

### 🎨 **米粒儿精心打造 · 功能丰富 · 界面美观**

</div>

### 🚀 **协议支持**
<table>
<tr>
<td width="50%">

#### 🛡️ **安全协议**
- ✅ `ShadowTLS v3` - 最新加密
- ✅ `XTLS Reality` - 终极伪装
- ✅ `Hysteria2` - 高速传输
- ✅ `Tuic V5` - 低延迟优化
- ✅ `AnyTLS` - 通用加密

</td>
<td width="50%">

#### 🌐 **传统协议**
- ✅ `ShadowSocks` - 经典稳定
- ✅ `Trojan` - 简单高效
- ✅ `Vmess + WS` - 兼容性强
- ✅ `Vless + WS + TLS` - 安全可靠
- ✅ `H2 Reality` - HTTP/2 伪装
- ✅ `gRPC Reality` - 先进传输

</td>
</tr>
</table>

### 🎯 **核心特性**

| 特性 | 描述 | 优势 |
|------|------|------|
| 🔥 **一键部署** | 单选/多选/全选 11+ 协议 | 简单易用，总有适合你的 |
| 🌍 **无需域名** | 可选 Cloudflare Argo Tunnel | 内网穿透，零门槛使用 |
| 📱 **全客户端支持** | V2rayN / Clash / 小火箭 / Nekobox / Sing-box | 一个订阅走天下 |
| 🔧 **自定义端口** | 灵活端口配置 | 适配 NAT 小鸡 |
| 🤖 **ChatGPT 解锁** | 内置 WARP 链式代理 | 智能分流解锁 |
| 💻 **系统兼容** | Ubuntu / Debian / CentOS / Alpine / Arch | 全平台支持 |
| 🖥️ **硬件支持** | AMD64 / ARM64 / IPv4 / IPv6 | 全架构适配 |
| ⚡ **极速安装** | 无交互模式 | 一键完成所有配置 |


---

## 🚀 **VPS 运行脚本**

<div align="center">

### 💫 **米粒儿一键脚本 · 简单快捷 · 功能强大**

</div>

### 📥 **安装部署**

<table>
<tr>
<td width="50%">

#### 🎯 **首次运行**
```bash
bash <(wget -qO- https://raw.githubusercontent.com/milier-rice/sing-box-family/main/sing-box.sh)
```

</td>
<td width="50%">

#### 🔄 **再次运行**
```bash
sb
```

</td>
</tr>
</table>

### ⚙️ **参数说明**

<div align="center">

| 🎛️ **参数** | 📝 **功能描述** | ✨ **使用说明** |
|-------------|-----------------|-----------------|
| `-c` | 🇨🇳 **中文界面** | 使用中文显示界面 |
| `-e` | 🇺🇸 **英文界面** | 使用英文显示界面 |
| `-u` | 🗑️ **卸载程序** | 完全卸载所有组件 |
| `-n` | 📊 **节点信息** | 显示所有节点配置 |
| `-p` | 🔌 **端口设置** | 更改节点起始端口 |
| `-d` | 🌐 **CDN 切换** | 在线更换 CDN 服务 |
| `-s` | 🔄 **服务控制** | 启停 Sing-box 服务 |
| `-a` | 🌈 **Argo 控制** | 启停 Argo Tunnel |
| `-v` | ⬆️ **版本更新** | 同步到最新版本 |
| `-b` | 🚀 **系统优化** | 升级内核安装 BBR |
| `-r` | 🔧 **协议管理** | 动态添加删除协议 |

</div>


---

## ⚡ **无交互极速安装**

<div align="center">

### ⚡ **米粒儿极速部署 · 一键到位 · 省时省力**

</div>

### 🎯 **安装方式**

<table>
<tr>
<td width="50%">

#### 📄 **方式1：配置文件**
> 使用 KV 配置文件，参照本库 `config.conf`
```bash
bash <(wget -qO- https://raw.githubusercontent.com/milier-rice/sing-box-family/main/sing-box.sh) -f config.conf
```

</td>
<td width="50%">

#### 🔧 **方式2：命令传参**
> 直接在命令行传递参数
```bash
bash <(wget -qO- https://raw.githubusercontent.com/milier-rice/sing-box-family/main/sing-box.sh) --LANGUAGE c --CHOOSE_PROTOCOLS a
```

</td>
</tr>
</table>

### 📚 **配置示例**

<details>
    <summary> 使用 Origin Rule + 订阅（点击即可展开或收起）</summary>
<br>

```
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/sing-box/main/sing-box.sh) \
  --LANGUAGE c \
  --CHOOSE_PROTOCOLS a \
  --START_PORT 8881 \
  --PORT_NGINX 60000 \
  --SERVER_IP 123.123.123.123 \
  --CDN skk.moe \
  --VMESS_HOST_DOMAIN vmess.test.com \
  --VLESS_HOST_DOMAIN vless.test.com \
  --UUID_CONFIRM 20f7fca4-86e5-4ddf-9eed-24142073d197 \
  --SUBSCRIBE=true \
  --PORT_HOPPING_RANGE 50000:51000 \
  --NODE_NAME_CONFIRM bucket
```

</details>

<details>
    <summary> 使用 Origin Rule ，不要订阅（点击即可展开或收起）</summary>
<br>

```
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/sing-box/main/sing-box.sh) \
  --LANGUAGE c \
  --CHOOSE_PROTOCOLS a \
  --START_PORT 8881 \
  --SERVER_IP 123.123.123.123 \
  --CDN skk.moe \
  --VMESS_HOST_DOMAIN vmess.test.com \
  --VLESS_HOST_DOMAIN vless.test.com \
  --UUID_CONFIRM 20f7fca4-86e5-4ddf-9eed-24142073d197 \
  --PORT_HOPPING_RANGE 50000:51000 \
  --NODE_NAME_CONFIRM bucket
```
</details>

<details>
    <summary> 使用 Argo 临时隧道 + 订阅（点击即可展开或收起）</summary>
<br>

```
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/sing-box/main/sing-box.sh) \
  --LANGUAGE c \
  --CHOOSE_PROTOCOLS a \
  --START_PORT 8881 \
  --PORT_NGINX 60000 \
  --SERVER_IP 123.123.123.123 \
  --CDN skk.moe \
  --UUID_CONFIRM 20f7fca4-86e5-4ddf-9eed-24142073d197 \
  --SUBSCRIBE=true \
  --ARGO=true \
  --PORT_HOPPING_RANGE 50000:51000 \
  --NODE_NAME_CONFIRM bucket
```
</details>

<details>
    <summary> 使用 Argo 临时隧道，不要订阅（点击即可展开或收起）</summary>
<br>

```
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/sing-box/main/sing-box.sh) \
  --LANGUAGE c \
  --CHOOSE_PROTOCOLS a \
  --START_PORT 8881 \
  --PORT_NGINX 60000 \
  --SERVER_IP 123.123.123.123 \
  --CDN skk.moe \
  --UUID_CONFIRM 20f7fca4-86e5-4ddf-9eed-24142073d197 \
  --ARGO=true \
  --PORT_HOPPING_RANGE 50000:51000 \
  --NODE_NAME_CONFIRM bucket
```
</details>

<details>
    <summary> 使用 Argo Json 隧道 + 订阅（点击即可展开或收起）</summary>
<br>

```
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/sing-box/main/sing-box.sh) \
  --LANGUAGE c \
  --CHOOSE_PROTOCOLS a \
  --START_PORT 8881 \
  --PORT_NGINX 60000 \
  --SERVER_IP 123.123.123.123 \
  --CDN skk.moe \
  --UUID_CONFIRM 20f7fca4-86e5-4ddf-9eed-24142073d197 \
  --SUBSCRIBE=true \
  --ARGO=true \
  --ARGO_DOMAIN=sb.argo.com \
  --ARGO_AUTH='{"AccountTag":"9cc9e3e4d8f29d2a02e297f14f20513a","TunnelSecret":"6AYfKBOoNlPiTAuWg64ZwujsNuERpWLm6pPJ2qpN8PM=","TunnelID":"1ac55430-f4dc-47d5-a850-bdce824c4101"}' \
  --PORT_HOPPING_RANGE 50000:51000 \
  --NODE_NAME_CONFIRM bucket
```
</details>

<details>
    <summary> 使用 Argo Json 隧道，不要订阅（点击即可展开或收起）</summary>
<br>

```
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/sing-box/main/sing-box.sh) \
  --LANGUAGE c \
  --CHOOSE_PROTOCOLS a \
  --START_PORT 8881 \
  --PORT_NGINX 60000 \
  --SERVER_IP 123.123.123.123 \
  --CDN skk.moe \
  --UUID_CONFIRM 20f7fca4-86e5-4ddf-9eed-24142073d197 \
  --ARGO=true \
  --ARGO_DOMAIN=sb.argo.com \
  --ARGO_AUTH='{"AccountTag":"9cc9e3e4d8f29d2a02e297f14f20513a","TunnelSecret":"6AYfKBOoNlPiTAuWg64ZwujsNuERpWLm6pPJ2qpN8PM=","TunnelID":"1ac55430-f4dc-47d5-a850-bdce824c4101"}' \
  --PORT_HOPPING_RANGE 50000:51000 \
  --NODE_NAME_CONFIRM bucket
```
</details>

<details>
    <summary> 使用 Argo Token 隧道 + 订阅（点击即可展开或收起）</summary>
<br>

```
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/sing-box/main/sing-box.sh) \
  --LANGUAGE c \
  --CHOOSE_PROTOCOLS a \
  --START_PORT 8881 \
  --PORT_NGINX 60000 \
  --SERVER_IP 123.123.123.123 \
  --CDN skk.moe \
  --UUID_CONFIRM 20f7fca4-86e5-4ddf-9eed-24142073d197 \
  --SUBSCRIBE=true \
  --ARGO=true \
  --ARGO_DOMAIN=sb.argo.com \
  --ARGO_AUTH='sudo cloudflared service install eyJhIjoiOWNjOWUzZTRkOGYyOWQyYTAyZTI5N2YxNGYyMDUxM2EiLCJ0IjoiOGNiZDA4ZjItNGM0MC00OGY1LTlmZDYtZjlmMWQ0YTcxMjUyIiwicyI6IllXWTFORGN4TW1ZdE5HTXdZUzAwT0RaakxUbGxNMkl0Wm1VMk5URTFOR0l4TkdKayJ9' \
  --PORT_HOPPING_RANGE 50000:51000 \
  --NODE_NAME_CONFIRM bucket
```
</details>

<details>
    <summary> 使用 Argo Token 隧道，不要订阅（点击即可展开或收起）</summary>
<br>

```
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/sing-box/main/sing-box.sh) \
  --LANGUAGE c \
  --CHOOSE_PROTOCOLS a \
  --START_PORT 8881 \
  --PORT_NGINX 60000 \
  --SERVER_IP 123.123.123.123 \
  --CDN skk.moe \
  --UUID_CONFIRM 20f7fca4-86e5-4ddf-9eed-24142073d197 \
  --ARGO=true \
  --ARGO_DOMAIN=sb.argo.com \
  --ARGO_AUTH='sudo cloudflared service install eyJhIjoiOWNjOWUzZTRkOGYyOWQyYTAyZTI5N2YxNGYyMDUxM2EiLCJ0IjoiOGNiZDA4ZjItNGM0MC00OGY1LTlmZDYtZjlmMWQ0YTcxMjUyIiwicyI6IllXWTFORGN4TW1ZdE5HTXdZUzAwT0RaakxUbGxNMkl0Wm1VMk5URTFOR0l4TkdKayJ9' \
  --PORT_HOPPING_RANGE 50000:51000 \
  --NODE_NAME_CONFIRM bucket
```
</details>


### 📋 **参数详解**

<div align="center">

> 🔧 **参数大小写不敏感** | 📝 **支持灵活配置** | ✨ **一次设置永久使用**

</div>

| 🎯 **参数名** | 📖 **取值说明** | 💡 **使用示例** |
|---------------|-----------------|-----------------|
| `--LANGUAGE` | 🇨🇳 `c` 中文 / 🇺🇸 `e` 英文 | `--LANGUAGE c` |
| `--CHOOSE_PROTOCOLS` | 🛡️ **协议选择**<br/>• `a` 全部协议<br/>• `b` XTLS+Reality<br/>• `c` Hysteria2<br/>• `d` Tuic<br/>• `e` ShadowTLS<br/>• `f` ShadowSocks<br/>• `g` Trojan<br/>• `h` VMess+WS<br/>• `i` VLess+WS+TLS<br/>• `j` H2+Reality<br/>• `k` gRPC+Reality<br/>• `l` AnyTLS | `--CHOOSE_PROTOCOLS bcf` |
| `--START_PORT` | 🔌 端口范围：`100-65520` | `--START_PORT 8800` |
| `--PORT_NGINX` | 📡 Nginx端口：`100-65520`<br/>或 `n` 不使用订阅 | `--PORT_NGINX 60000` |
| `--SERVER_IP` | 🌐 服务器 IP（IPv4/IPv6） | `--SERVER_IP 1.2.3.4` |
| `--CDN` | 🚀 优选IP/域名 | `--CDN skk.moe` |
| `--VMESS_HOST_DOMAIN` | 🌍 VMess SNI 域名 | `--VMESS_HOST_DOMAIN vm.example.com` |
| `--VLESS_HOST_DOMAIN` | 🌍 VLess SNI 域名 | `--VLESS_HOST_DOMAIN vl.example.com` |
| `--UUID_CONFIRM` | 🔑 协议 UUID/密码 | `--UUID_CONFIRM xxxxxxxx-xxxx-xxxx` |
| `--ARGO` | 🌈 Argo隧道：`true`/`false` | `--ARGO true` |
| `--ARGO_DOMAIN` | 🌐 Argo 固定域名 | `--ARGO_DOMAIN sb.argo.com` |
| `--ARGO_AUTH` | 🔐 Argo 认证信息 | Json 或 Token 内容 |
| `--PORT_HOPPING_RANGE` | 🏃 端口跳跃范围 | `--PORT_HOPPING_RANGE 50000:51000` |
| `--NODE_NAME_CONFIRM` | 📝 节点名称 | `--NODE_NAME_CONFIRM 米粒儿节点` |


---

## 🌐 **Token Argo Tunnel 设置**

<div align="center">

### 🌈 **米粒儿 Argo 隧道 · 内网穿透 · CDN 加速**

> 🔗 **详细教程**：[群晖套件：Cloudflare Tunnel 内网穿透中文教程 支持DSM6、7](https://imnks.com/5984.html)

</div>

### ⚙️ **配置步骤**

<img width="1510" alt="image" src="https://github.com/fscarmen/sba/assets/62703343/bb2d9c43-3585-4abd-a35b-9cfd7404c87c">

<img width="1638" alt="image" src="https://github.com/fscarmen/sing-box/assets/62703343/a4868388-d6ab-4dc7-929c-88bc775ca851">


---

## 📡 **Vmess/Vless CDN 设置**

<div align="center">

### 🚀 **米粒儿 CDN 优化 · 高速连接 · 智能分流**

</div>

### 📋 **配置示例**

> 🌐 **IPv6 示例**：`vmess [2a01:4f8:272:3ae6:100b:ee7a:ad2f:1]:10006`

<img width="1052" alt="image" src="https://github.com/fscarmen/sing-box/assets/62703343/bc2df37a-95c4-4ba0-9c84-5d9c745c3a7b">

### 🔧 **设置步骤**

#### 1️⃣ **解析域名**
<img width="1605" alt="image" src="https://github.com/fscarmen/sing-box/assets/62703343/8f38d555-6294-493e-b43d-ff0586c80d61">

#### 2️⃣ **配置 Origin Rule**
<img width="1556" alt="image" src="https://github.com/fscarmen/sing-box/assets/62703343/164bf255-a6be-40bc-a724-56e13da7a1e6">


---

## 🐳 **Docker 容器部署**

<div align="center">

### 🚀 **米粒儿 Docker 版 · 一键部署 · 开箱即用**

</div>

### 📝 **部署说明**

<table>
<tr>
<td width="50%">

#### 🌈 **Argo 支持**
- ⚡ **临时隧道** - 无需域名
- 🔑 **Json 隧道** - 固定域名
- 🎫 **Token 隧道** - 企业级

</td>
<td width="50%">

#### 🔌 **端口需求**
- 📊 **端口数量**：20个连续端口
- 🏁 **起始端口**：`START_PORT` 开始
- ⚙️ **自动分配**：按协议顺序递增

</td>
</tr>
</table>

<details>
    <summary> Docker 部署（点击即可展开或收起）</summary>
<br>

```bash
# 🚀 米粒儿 Docker 一键部署
docker run -dit \
    --pull always \
    --name milier-sing-box \
    -p 8800-8820:8800-8820/tcp \
    -p 8800-8820:8800-8820/udp \
    -e START_PORT=8800 \
    -e SERVER_IP=123.123.123.123 \
    -e XTLS_REALITY=true \
    -e HYSTERIA2=true \
    -e TUIC=true \
    -e SHADOWTLS=true \
    -e SHADOWSOCKS=true \
    -e TROJAN=true \
    -e VMESS_WS=true \
    -e VLESS_WS=true \
    -e H2_REALITY=true \
    -e GRPC_REALITY=true \
    -e ANYTLS=true \
    -e UUID=20f7fca4-86e5-4ddf-9eed-24142073d197 \
    -e CDN=www.csgo.com \
    -e NODE_NAME=米粒儿节点 \
    -e ARGO_DOMAIN=sb.argo.com \
    -e ARGO_AUTH='{"AccountTag":"9cc9e3e4d8f29d2a02e297f14f20513a","TunnelSecret":"6AYfKBOoNlPiTAuWg64ZwujsNuERpWLm6pPJ2qpN8PM=","TunnelID":"1ac55430-f4dc-47d5-a850-bdce824c4101"}' \
    milier/sing-box-family
```
</details>

<details>
    <summary> Docker Compose 部署（点击即可展开或收起）</summary>
<br>

```yaml
# 🎉 米粒儿 Docker Compose 配置文件
version: '3.8'

networks:
  milier-sing-box:
    name: milier-sing-box
    driver: bridge

services:
  milier-sing-box:
    image: milier/sing-box-family:latest
    pull_policy: always
    container_name: milier-sing-box
    restart: always
    networks:
      - milier-sing-box
    ports:
      - "8800-8820:8800-8820/tcp"
      - "8800-8820:8800-8820/udp"
    environment:
      # 🏁 基本配置
      - START_PORT=8800
      - SERVER_IP=123.123.123.123
      - NODE_NAME=米粒儿节点
      - UUID=20f7fca4-86e5-4ddf-9eed-24142073d197
      - CDN=www.csgo.com
      
      # 🛡️ 协议开关
      - XTLS_REALITY=true
      - HYSTERIA2=true
      - TUIC=true
      - SHADOWTLS=true
      - SHADOWSOCKS=true
      - TROJAN=true
      - VMESS_WS=true
      - VLESS_WS=true
      - H2_REALITY=true
      - GRPC_REALITY=true
      - ANYTLS=true
      
      # 🌈 Argo 配置
      - ARGO_DOMAIN=sb.argo.com
      - ARGO_AUTH=eyJhIjoiOWNjOWUzZTRkOGYyOWQyYTAyZTI5N2YxNGYyMDUxM2EiLCJ0IjoiOGNiZDA4ZjItNGM0MC00OGY1LTlmZDYtZjlmMWQ0YTcxMjUyIiwicyI6IllXWTFORGN4TW1ZdE5HTXdZUzAwT0RaakxUbGxNMkl0Wm1VMk5URTFOR0l4TkdKayJ9
    labels:
      - "com.docker.compose.project=milier-sing-box"
      - "maintainer=米粒儿"
      - "version=v1.2.18"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8800"]
      interval: 30s
      timeout: 10s
      retries: 3
```
</details>


### 🎛️ **常用指令**

<div align="center">

> 💡 **贴心提示**：所有指令都已针对米粒儿版本优化

</div>

| 🔧 **功能** | 📝 **指令** | 💬 **说明** |
|-------------|-------------|-------------|
| 📊 **查看节点** | `docker exec -it milier-sing-box cat list` | 显示所有节点配置信息 |
| 📋 **查看日志** | `docker logs -f milier-sing-box` | 实时查看容器运行日志 |
| ⬆️ **更新版本** | `docker exec -it milier-sing-box bash init.sh -v` | 更新到最新 Sing-box 版本 |
| 📈 **资源监控** | `docker stats milier-sing-box` | 查看 CPU、内存、网络使用情况 |
| ⏸️ **暂停容器** | **Docker**: `docker stop milier-sing-box`<br/>**Compose**: `docker-compose stop` | 暂停容器运行 |
| 🗑️ **删除容器** | **Docker**: `docker rm -f milier-sing-box`<br/>**Compose**: `docker-compose down` | 停止并删除容器 |
| 🧹 **清理镜像** | `docker rmi -f milier/sing-box-family:latest` | 删除镜像文件 |


### 用户可以通过 Cloudflare Json 生成网轻松获取: https://fscarmen.cloudflare.now.cc

<img width="784" alt="image" src="https://github.com/fscarmen/sba/assets/62703343/fb7c6e90-fb3e-4e77-bcd4-407e4660a33c">

如想手动，可以参考，以 Debian 为例，需要用到的命令，[Deron Cheng - CloudFlare Argo Tunnel 试用](https://zhengweidong.com/try-cloudflare-argo-tunnel)


### Argo Token 的获取

详细教程: [群晖套件：Cloudflare Tunnel 内网穿透中文教程 支持DSM6、7](https://imnks.com/5984.html)

<img width="1510" alt="image" src="https://github.com/fscarmen/sba/assets/62703343/bb2d9c43-3585-4abd-a35b-9cfd7404c87c">

<img width="1616" alt="image" src="https://github.com/fscarmen/sing-box/assets/62703343/ecb844be-1e93-4208-bb7c-6b00b9d1f00a">


### 参数说明
| 参数 | 是否必须 | 说明 |
| --- | ------- | --- |
| -p /tcp | 是 | 宿主机端口范围:容器 sing-box 及 nginx 等 tcp 监听端口 |
| -p /udp | 是 | 宿主机端口范围:容器 sing-box 及 nginx 等 udp 监听端口 |
| -e START_PORT | 是 | 起始端口 ，一定要与端口映射的起始端口一致 |
| -e SERVER_IP | 是 | 服务器公网 IP |
| -e XTLS_REALITY | 是 |    true 为启用 XTLS + reality，不需要的话删除本参数或填 false |
| -e HYSTERIA2 | 是 |       true 为启用 Hysteria v2 协议，不需要的话删除本参数或填 false |
| -e TUIC | 是 |            true 为启用 TUIC 协议，不需要的话删除本参数或填 false |
| -e SHADOWTLS | 是 |       true 为启用 ShadowTLS 协议，不需要的话删除本参数或填 false |
| -e SHADOWSOCKS | 是 |     true 为启用 ShadowSocks 协议，不需要的话删除本参数或填 false |
| -e TROJAN | 是 |          true 为启用 Trojan 协议，不需要的话删除本参数或填 false |
| -e VMESS_WS | 是 |        true 为启用 VMess over WebSocket 协议，不需要的话删除本参数或填 false |
| -e VLESS_WS | 是 |        true 为启用 VLess over WebSocket 协议，不需要的话删除本参数或填 false |
| -e H2_REALITY | 是 |      true 为启用 H2 over reality 协议，不需要的话删除本参数或填 false |
| -e GRPC_REALITY | 是 |    true 为启用 gRPC over reality 协议，不需要的话删除本参数或填 false |
| -e ANYTLS | 是 |          true 为启用 AnyTLS 协议，不需要的话删除本参数或填 false |
| -e UUID | 否 | 不指定的话 UUID 将默认随机生成 |
| -e CDN | 否 | 优选域名，不指定的话将使用 www.csgo.com |
| -e NODE_NAME | 否 | 节点名称，不指定的话将使用 sing-box |
| -e ARGO_DOMAIN | 否 | Argo 固定隧道域名 , 与 ARGO_DOMAIN 一并使用才能生效 |
| -e ARGO_AUTH | 否 | Argo 认证信息，可以是 Json 也可以是 Token，与 ARGO_DOMAIN 一并使用才能生效，不指定的话将使用临时隧道 |


---

## 🔧 **Nekobox 配置教程**

<div align="center">

### 🦄 **米粒儿 ShadowTLS 配置 · 简单易懂 · 一次设置**

</div>

### 📝 **配置步骤**

#### 1️⃣ **导入链接**
> 📋 复制脚本输出的两个 Neko links

<img width="630" alt="image" src="https://github.com/fscarmen/sing-box/assets/62703343/db5960f3-63b1-4145-90a5-b01066dd39be">

#### 2️⃣ **设置链式代理**

<table>
<tr>
<td width="50%">

**🎯 操作步骤：**
1. 右键 → 手动输入配置
2. 类型选择：`链式代理`
3. 点击 `选择配置`
4. 给节点命名

</td>
<td width="50%">

**⚠️ 重要提醒：**
- 先选：`1-tls-not-use`
- 后选：`2-ss-not-use`
- 双击使用服务器
- **顺序不能颠倒！**

</td>
</tr>
</table>

> 🔄 **代理逻辑**：ShadowTLS → ShadowSocks

<img width="408" alt="image" src="https://github.com/fscarmen/sing-box/assets/62703343/753e7159-92f9-4c88-91b5-867fdc8cca47">


---

## 📂 **目录结构说明**

<div align="center">

### 📁 **米粒儿项目架构 · 井井有条 · 一目了然**

</div>

```
/etc/sing-box/                               # 项目主体目录
|-- cert                                     # 存放证书文件目录
|   |-- cert.pem                             # SSL/TLS 安全证书文件
|   `-- private.key                          # SSL/TLS 证书的私钥信息
|-- conf                                     # sing-box server 配置文件目录
|   |-- 00_log.json                          # 日志配置文件
|   |-- 01_outbounds.json                    # 服务端出站配置文件
|   |-- 02_endpoints.json                    # 配置 endpoints，添加 warp 账户信息配置文件
|   |-- 03_route.json                        # 路由配置文件，chatGPT 使用 warp ipv6 链式代理出站
|   |-- 04_experimental.json                 # 缓存配置文件
|   |-- 05_dns.json                          # DNS 规则文件
|   |-- 06_ntp.json                          # 服务端时间同步配置文件
|   |-- 11_xtls-reality_inbounds.json        # Reality vision 协议配置文件
|   |-- 12_hysteria2_inbounds.json           # Hysteria2 协议配置文件
|   |-- 13_tuic_inbounds.json                # Tuic V5 协议配置文件 # Hysteria2 协议配置文件
|   |-- 14_ShadowTLS_inbounds.json           # ShadowTLS 协议配置文件     # Tuic V5 协议配置文件
|   |-- 15_shadowsocks_inbounds.json         # Shadowsocks 协议配置文件
|   |-- 16_trojan_inbounds.json              # Trojan 协议配置文件
|   |-- 17_vmess-ws_inbounds.json            # vmess + ws 协议配置文件
|   |-- 18_vless-ws-tls_inbounds.json        # vless + ws + tls 协议配置文件
|   |-- 19_h2-reality_inbounds.json          # Reality http2 协议配置文件
|   |-- 20_grpc-reality_inbounds.json        # Reality gRPC 协议配置文件
|   `-- 21_anytls_inbounds.json              # AnyTLS 协议配置文件
|-- logs
|   `-- box.log                              # sing-box 运行日志文件
|-- subscribe                                # sing-box server 配置文件目录
|   |-- qr                                   # Nekoray / V2rayN / Shadowrock 订阅二维码
|   |-- shadowrocket                         # Shadowrock 订阅文件
|   |-- proxies                              # Clash proxy provider 订阅文件
|   |-- clash                                # Clash 订阅文件1
|   |-- clash2                               # Clash 订阅文件2
|   |-- sing-box-pc                          # SFM 订阅文件1
|   |-- sing-box-phone                       # SFI / SFA 订阅文件1
|   |-- sing-box2                            # SFI / SFA / SFM 订阅文件2
|   |-- v2rayn                               # V2rayN 订阅文件
|   `-- neko                                 # Nekoray 订阅文件
|-- cache.db                                 # sing-box 缓存文件
|-- nginx.conf                               # 用于订阅服务的 nginx 配置文件
|-- language                                 # 存放脚本语言文件，E 为英文，C 为中文
|-- list                                     # 节点信息列表
|-- sing-box                                 # sing-box 主程序
|-- cloudflared                              # Argo tunnel 主程序
|-- tunnel.json                              # Argo tunnel Json 信息文件
|-- tunnel.yml                               # Argo tunnel 配置文件
|-- sb.sh                                    # 快捷方式脚本文件
|-- jq                                       # 命令行 json 处理器二进制文件
`-- qrencode                                 # QR 码编码二进制文件
```


---

## 🙏 **致谢项目**

<div align="center">

### 💝 **感谢开源社区 · 共建美好网络**

</div>

| 项目 | 作者 | 贡献 |
|------|------|------|
| 🎵 **Sing-box Templates** | [千歌](https://github.com/chika0801/sing-box-examples) | 提供优秀的配置模板 |
| 🌐 **原始项目框架** | fscarmen | 项目基础架构支持 |

---

## 💝 **赞助支持**

### 🚀 Sponsored by SharonNetworks

<a href="https://sharon.io/">
  <img src="https://framerusercontent.com/assets/3bMljdaUFNDFvMzdG9S0NjYmhSY.png" width="30%" alt="sharon.io">
</a>

本项目的构建与发布环境由 SharonNetworks 提供支持 —— 专注亚太顶级回国优化线路，高带宽、低延迟直连中国大陆，内置强大高防 DDoS 清洗能力。

SharonNetworks 为您的业务起飞保驾护航！

#### ✨ 服务优势

* 亚太三网回程优化直连中国大陆，下载快到飞起
* 超大带宽 + 抗攻击清洗服务，保障业务安全稳定
* 多节点覆盖（香港、新加坡、日本、台湾、韩国）
* 高防护力、高速网络；港/日/新 CDN 即将上线

想体验同款构建环境？欢迎 [访问 Sharon 官网](https://sharon.io) 或 [加入 Telegram 群组](https://t.me/SharonNetwork) 了解更多并申请赞助。


## 12.免责声明:
* 本程序仅供学习了解, 非盈利目的，请于下载后 24 小时内删除, 不得用作任何商业用途, 文字、数据及图片均有所属版权, 如转载须注明来源。
* 使用本程序必循遵守部署免责声明。使用本程序必循遵守部署服务器所在地、所在国家和用户所在国家的法律法规, 程序作者不对使用者任何不当行为负责。
