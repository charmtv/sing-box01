#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# 🌟 Sing-box 全家桶 Docker 初始化脚本 🌟
#
# 🗓️ 最后更新：2025.09.05 (北京时间)
# 📝 版本：v1.2.20
# ═══════════════════════════════════════════════════════════════

# 设置严格模式
set -euo pipefail

WORK_DIR=/sing-box
PORT=$START_PORT
SUBSCRIBE_TEMPLATE="https://raw.githubusercontent.com/charmtv/sing-box01/main/templates"

# 自定义字体彩色，read 函数
warning() { echo -e "\033[31m\033[01m$*\033[0m"; }  # 红色
info() { echo -e "\033[32m\033[01m$*\033[0m"; }   # 绿色
hint() { echo -e "\033[33m\033[01m$*\033[0m"; }   # 黄色

# 错误处理函数
error_exit() {
    warning "错误: $1"
    exit 1
}

# IP地址自动检测函数
detect_server_ip() {
    info "🔍 正在自动检测服务器IP地址..."
    
    local detected_ipv4=""
    local detected_ipv6=""
    local final_ip=""
    
    # 方法1: 使用多个IP检测服务 - 增强版
    local ip_services=(
        "https://api.ipify.org"
        "https://ipv4.icanhazip.com"
        "https://api.ip.sb"
        "https://ipinfo.io/ip"
        "https://checkip.amazonaws.com"
        "https://ifconfig.me/ip"
        "http://api-ipv4.ip.sb"
        "https://ip.3322.net"
        "https://myip.ipip.net"
        "http://ipecho.net/plain"
        "http://ident.me"
        "http://whatismyip.akamai.com"
    )
    
    # 检测IPv4
    for service in "${ip_services[@]}"; do
        info "尝试从 $service 获取IPv4地址..."
        detected_ipv4=$(wget --no-check-certificate --tries=1 --timeout=5 -qO- "$service" 2>/dev/null | tr -d '\n\r' | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$')
        if [ -n "$detected_ipv4" ]; then
            info "✅ 检测到IPv4地址: $detected_ipv4"
            break
        fi
    done
    
    # 检测IPv6
    local ipv6_services=(
        "http://api-ipv6.ip.sb"
        "http://ipv6.icanhazip.com"
        "http://v6.ident.me"
    )
    
    for service in "${ipv6_services[@]}"; do
        info "尝试从 $service 获取IPv6地址..."
        detected_ipv6=$(wget --no-check-certificate --tries=1 --timeout=5 -qO- "$service" 2>/dev/null | tr -d '\n\r' | grep -E '^[0-9a-fA-F:]+$')
        if [ -n "$detected_ipv6" ]; then
            info "✅ 检测到IPv6地址: $detected_ipv6"
            break
        fi
    done
    
    # 方法2: 从网络接口获取
    if [ -z "$detected_ipv4" ] && [ -z "$detected_ipv6" ]; then
        info "尝试从网络接口获取IP地址..."
        
        # 获取默认网络接口
        local default_interface=$(ip route | grep default | head -1 | awk '{print $5}')
        if [ -n "$default_interface" ]; then
            info "默认网络接口: $default_interface"
            
            # 从接口获取IPv4
            detected_ipv4=$(ip -4 addr show "$default_interface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
            if [ -n "$detected_ipv4" ]; then
                info "✅ 从接口获取IPv4: $detected_ipv4"
            fi
            
            # 从接口获取IPv6
            detected_ipv6=$(ip -6 addr show "$default_interface" | grep -oP '(?<=inet6\s)[0-9a-fA-F:]+' | grep -v '^::1$' | grep -v '^fe80:' | head -1)
            if [ -n "$detected_ipv6" ]; then
                info "✅ 从接口获取IPv6: $detected_ipv6"
            fi
        fi
    fi
    
    # 方法3: 使用hostname命令
    if [ -z "$detected_ipv4" ] && [ -z "$detected_ipv6" ]; then
        info "尝试使用hostname命令获取IP地址..."
        local hostname_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
        if [ -n "$hostname_ip" ]; then
            if [[ "$hostname_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                detected_ipv4="$hostname_ip"
                info "✅ 从hostname获取IPv4: $detected_ipv4"
            elif [[ "$hostname_ip" =~ ^[0-9a-fA-F:]+$ ]]; then
                detected_ipv6="$hostname_ip"
                info "✅ 从hostname获取IPv6: $detected_ipv6"
            fi
        fi
    fi
    
    # 选择最终IP地址
    if [ -n "$detected_ipv4" ]; then
        final_ip="$detected_ipv4"
        info "🎯 选择IPv4地址: $final_ip"
    elif [ -n "$detected_ipv6" ]; then
        final_ip="$detected_ipv6"
        info "🎯 选择IPv6地址: $final_ip"
    else
        warning "❌ 无法自动检测到服务器IP地址"
        return 1
    fi
    
    # 验证IP地址格式
    if [[ "$final_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        # IPv4格式验证
        local valid_ipv4=true
        IFS='.' read -ra ADDR <<< "$final_ip"
        for i in "${ADDR[@]}"; do
            if [ "$i" -gt 255 ] || [ "$i" -lt 0 ]; then
                valid_ipv4=false
                break
            fi
        done
        if [ "$valid_ipv4" = true ]; then
            info "✅ IPv4地址格式验证通过"
        else
            warning "❌ IPv4地址格式无效"
            return 1
        fi
    elif [[ "$final_ip" =~ ^[0-9a-fA-F:]+$ ]]; then
        info "✅ IPv6地址格式验证通过"
    else
        warning "❌ IP地址格式无效"
        return 1
    fi
    
    # 设置SERVER_IP环境变量
    export SERVER_IP="$final_ip"
    info "🎉 服务器IP地址已自动设置为: $SERVER_IP"
    return 0
}

# 配置验证函数
validate_config() {
    local errors=0
    
    # 验证必需的环境变量
    if [ -z "${START_PORT:-}" ]; then
        warning "START_PORT 未设置"
        errors=$((errors + 1))
    fi
    
    # 检查SERVER_IP，如果未设置则自动检测
    if [ -z "${SERVER_IP:-}" ]; then
        warning "SERVER_IP 未设置，尝试自动检测..."
        if detect_server_ip; then
            info "✅ 服务器IP地址自动检测成功"
        else
            warning "❌ 服务器IP地址自动检测失败"
            errors=$((errors + 1))
        fi
    else
        info "✅ 使用预设的SERVER_IP: $SERVER_IP"
    fi
    
    # 验证端口范围
    if ! [[ "${START_PORT:-}" =~ ^[0-9]+$ ]] || [ "${START_PORT:-}" -lt 100 ] || [ "${START_PORT:-}" -gt 65520 ]; then
        warning "START_PORT 必须在 100-65520 范围内"
        errors=$((errors + 1))
    fi
    
    # 验证IP地址格式
    if [ -n "${SERVER_IP:-}" ] && ! [[ "${SERVER_IP}" =~ ^[0-9a-fA-F:.]*$ ]]; then
        warning "SERVER_IP 格式不正确"
        errors=$((errors + 1))
    fi
    
    if [ $errors -gt 0 ]; then
        warning "配置验证失败，发现 $errors 个错误"
        exit 1
    fi
    
    info "✅ 配置验证通过"
}

# 下载重试函数
download_with_retry() {
    local url="$1"
    local output="$2"
    local max_retries=3
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        if wget --no-check-certificate --tries=1 --timeout=30 "$url" -O- | tar xz -C "${WORK_DIR}" "$output"; then
            return 0
        fi
        retry_count=$((retry_count + 1))
        warning "下载失败，重试 $retry_count/$max_retries..."
        sleep 2
    done
    
    warning "下载失败，已达到最大重试次数"
    return 1
}

# 判断系统架构，以下载相应的应用
case "$ARCH" in
  arm64 )
    SING_BOX_ARCH=arm64; JQ_ARCH=arm64; QRENCODE_ARCH=arm64; ARGO_ARCH=arm64
    ;;
  amd64 )
    SING_BOX_ARCH=amd64
    JQ_ARCH=amd64; QRENCODE_ARCH=amd64; ARGO_ARCH=amd64
    ;;
  armv7 )
    SING_BOX_ARCH=armv7; JQ_ARCH=armhf; QRENCODE_ARCH=arm; ARGO_ARCH=arm
    ;;
esac

# 检查 sing-box 最新版本
check_latest_sing-box() {
  local FORCE_VERSION=""
  local VERSION=""
  
  # 检查是否强制指定版本
  FORCE_VERSION=$(wget --no-check-certificate --tries=2 --timeout=10 -qO- https://raw.githubusercontent.com/charmtv/sing-box01/refs/heads/main/force_version 2>/dev/null | sed 's/^[vV]//g' | tr -d '\r\n')

  # 如果没有强制指定版本，获取最新版本
  if [ -z "$FORCE_VERSION" ] || ! grep -q '^[0-9]' <<< "$FORCE_VERSION"; then
    info "未指定强制版本，获取最新版本..."
    FORCE_VERSION=$(wget --no-check-certificate --tries=2 --timeout=10 -qO- https://api.github.com/repos/SagerNet/sing-box/releases/latest 2>/dev/null | grep -o '"tag_name":"[^"]*' | cut -d'"' -f4 | sed 's/^[vV]//g')
  fi

  # 验证版本号格式
  if [[ "$FORCE_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    VERSION="$FORCE_VERSION"
  else
    warning "无法获取有效版本号，使用默认版本"
    VERSION="1.12.0-beta.15"
  fi

  echo "$VERSION"
}

# 安装 sing-box 容器
install() {
  # 验证配置
  validate_config
  
  # 下载 sing-box
  info "正在下载 sing-box ..."
  local ONLINE=$(check_latest_sing-box)
  
  # 检查版本号是否获取成功
  if [ -z "$ONLINE" ]; then
    warning "获取 sing-box 版本失败，使用默认版本 v1.12.0-beta.15"
    ONLINE="1.12.0-beta.15"
  fi
  
  info "下载 sing-box 版本: v$ONLINE"
  
  # 使用重试机制下载 sing-box
  if download_with_retry "https://github.com/SagerNet/sing-box/releases/download/v$ONLINE/sing-box-$ONLINE-linux-$SING_BOX_ARCH.tar.gz" "sing-box-$ONLINE-linux-$SING_BOX_ARCH/sing-box"; then
    mv ${WORK_DIR}/sing-box-$ONLINE-linux-$SING_BOX_ARCH/sing-box ${WORK_DIR}/sing-box && rm -rf ${WORK_DIR}/sing-box-$ONLINE-linux-$SING_BOX_ARCH
    chmod +x ${WORK_DIR}/sing-box
    info "✅ sing-box 下载成功！"
  else
    error_exit "sing-box 下载失败，请检查网络连接"
  fi

  # 下载 jq
  info "正在下载 jq ..."
  local jq_urls=(
    "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-$JQ_ARCH"
    "https://cdn.jsdelivr.net/gh/jqlang/jq@jq-1.7.1/jq-linux-$JQ_ARCH"
    "https://github.com/charmtv/sing-box01/raw/main/tools/jq-linux-$JQ_ARCH"
  )
  
  local jq_downloaded=false
  for url in "${jq_urls[@]}"; do
    info "尝试从 $url 下载 jq..."
    if wget --no-check-certificate --tries=2 --timeout=15 -O ${WORK_DIR}/jq "$url"; then
      chmod +x ${WORK_DIR}/jq
      if ${WORK_DIR}/jq --version >/dev/null 2>&1; then
        info "✅ jq 下载成功！"
        jq_downloaded=true
        break
      else
        warning "下载的文件无效，尝试下一个源..."
        rm -f ${WORK_DIR}/jq
      fi
    fi
  done
  
  if [ "$jq_downloaded" = false ]; then
    warning "⚠️ jq 下载失败，将跳过相关功能"
    # 创建一个假的jq文件，避免后续错误
    echo '#!/bin/bash
echo "jq not available"
exit 1' > ${WORK_DIR}/jq
    chmod +x ${WORK_DIR}/jq
  fi

  # 下载 qrencode
  info "正在下载 qrencode ..."
  local qrencode_urls=(
    "https://github.com/fscarmen/client_template/raw/main/qrencode-go/qrencode-go-linux-$QRENCODE_ARCH"
    "https://github.com/charmtv/sing-box01/raw/main/tools/qrencode-go-linux-$QRENCODE_ARCH"
    "https://cdn.jsdelivr.net/gh/fscarmen/client_template@main/qrencode-go/qrencode-go-linux-$QRENCODE_ARCH"
  )
  
  local qrencode_downloaded=false
  for url in "${qrencode_urls[@]}"; do
    info "尝试从 $url 下载 qrencode..."
    if wget --no-check-certificate --tries=2 --timeout=15 -O ${WORK_DIR}/qrencode "$url"; then
      chmod +x ${WORK_DIR}/qrencode
      if ${WORK_DIR}/qrencode --version >/dev/null 2>&1; then
        info "✅ qrencode 下载成功！"
        qrencode_downloaded=true
        break
      else
        warning "下载的文件无效，尝试下一个源..."
        rm -f ${WORK_DIR}/qrencode
      fi
    fi
  done
  
  if [ "$qrencode_downloaded" = false ]; then
    warning "⚠️ qrencode 下载失败，将跳过二维码生成功能"
    # 创建一个假的qrencode文件，避免后续错误
    echo '#!/bin/bash
echo "qrencode not available"
exit 1' > ${WORK_DIR}/qrencode
    chmod +x ${WORK_DIR}/qrencode
  fi

  # 下载 cloudflared
  info "正在下载 cloudflared ..."
  local cloudflared_urls=(
    "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$ARGO_ARCH"
    "https://cdn.jsdelivr.net/gh/cloudflare/cloudflared@latest/cloudflared-linux-$ARGO_ARCH"
    "https://github.com/charmtv/sing-box01/raw/main/tools/cloudflared-linux-$ARGO_ARCH"
  )
  
  local cloudflared_downloaded=false
  for url in "${cloudflared_urls[@]}"; do
    info "尝试从 $url 下载 cloudflared..."
    if wget --no-check-certificate --tries=2 --timeout=15 -O ${WORK_DIR}/cloudflared "$url"; then
      chmod +x ${WORK_DIR}/cloudflared
      if ${WORK_DIR}/cloudflared version >/dev/null 2>&1; then
        info "✅ cloudflared 下载成功！"
        cloudflared_downloaded=true
        break
      else
        warning "下载的文件无效，尝试下一个源..."
        rm -f ${WORK_DIR}/cloudflared
      fi
    fi
  done
  
  if [ "$cloudflared_downloaded" = false ]; then
    warning "⚠️ cloudflared 下载失败，Argo 隧道功能将不可用"
    # 创建一个假的cloudflared文件，避免后续错误
    echo '#!/bin/bash
echo "cloudflared not available"
exit 1' > ${WORK_DIR}/cloudflared
    chmod +x ${WORK_DIR}/cloudflared
  fi

  # 检查系统是否已经安装 tcp-brutal
  IS_BRUTAL=false && [ -x "$(type -p lsmod)" ] && lsmod | grep -q brutal && IS_BRUTAL=true
  [ "$IS_BRUTAL" = 'false' ] && [ -x "$(type -p modprobe)" ] && modprobe brutal 2>/dev/null && IS_BRUTAL=true

  # 生成 sing-box 配置文件
  for i in {1..3}; do
    ping -c 1 -W 1 "151.101.1.91" &>/dev/null && local IS_IPV4=is_ipv4 && break
  done

  for i in {1..3}; do
    ping -c 1 -W 1 "2a04:4e42:200::347" &>/dev/null && local IS_IPV6=is_ipv6 && break
  done

  case "${IS_IPV4}@${IS_IPV6}" in
    is_ipv4@is_ipv6)
      local STRATEGY=prefer_ipv4
      ;;
    @is_ipv6)
      local STRATEGY=ipv6_only
      ;;
    *)
      local STRATEGY=ipv4_only
      ;;
  esac

  local REALITY_KEYPAIR=$(${WORK_DIR}/sing-box generate reality-keypair) && REALITY_PRIVATE=$(awk '/PrivateKey/{print $NF}' <<< "$REALITY_KEYPAIR") && REALITY_PUBLIC=$(awk '/PublicKey/{print $NF}' <<< "$REALITY_KEYPAIR")
  local SHADOWTLS_PASSWORD=$(${WORK_DIR}/sing-box generate rand --base64 16)
  local UUID=${UUID:-"$(${WORK_DIR}/sing-box generate uuid)"}
  local NODE_NAME=${NODE_NAME:-"sing-box"}
  local CDN=${CDN:-"skk.moe"}

  # 检测是否解锁 chatGPT，首先检查API访问
  local CHECK_RESULT1=$(wget --timeout=2 --tries=2 --retry-connrefused --waitretry=5 -qO- --content-on-error --header='authority: api.openai.com' --header='accept: */*' --header='accept-language: en-US,en;q=0.9' --header='authorization: Bearer null' --header='content-type: application/json' --header='origin: https://platform.openai.com' --header='referer: https://platform.openai.com/' --header='sec-ch-ua: "Google Chrome";v="125", "Chromium";v="125", "Not.A/Brand";v="24"' --header='sec-ch-ua-mobile: ?0' --header='sec-ch-ua-platform: "Windows"' --header='sec-fetch-dest: empty' --header='sec-fetch-mode: cors' --header='sec-fetch-site: same-site' --user-agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36' 'https://api.openai.com/compliance/cookie_requirements')

  # 如果API检测失败或者检测到unsupported_country,直接返回ban
  if [ -z "$CHECK_RESULT1" ] || grep -qi 'unsupported_country' <<< "$CHECK_RESULT1"; then
    CHATGPT_OUT=warp-ep
  fi

  # API检测通过后,继续检查网页访问
  local CHECK_RESULT2=$(wget --timeout=2 --tries=2 --retry-connrefused --waitretry=5 -qO- --content-on-error --header='authority: ios.chat.openai.com' --header='accept: */*;q=0.8,application/signed-exchange;v=b3;q=0.7' --header='accept-language: en-US,en;q=0.9' --header='sec-ch-ua: "Google Chrome";v="125", "Chromium";v="125", "Not.A/Brand";v="24"' --header='sec-ch-ua-mobile: ?0' --header='sec-ch-ua-platform: "Windows"' --header='sec-fetch-dest: document' --header='sec-fetch-mode: navigate' --header='sec-fetch-site: none' --header='sec-fetch-user: ?1' --header='upgrade-insecure-requests: 1' --user-agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36' https://ios.chat.openai.com/)

  # 检查第二个结果
  if [ -z "$CHECK_RESULT2" ] || grep -qi 'VPN' <<< "$CHECK_RESULT2"; then
    CHATGPT_OUT=warp-ep
  else
    CHATGPT_OUT=direct
  fi

  # 生成 log 配置
  cat > ${WORK_DIR}/conf/00_log.json << EOF

{
    "log":{
        "disabled":false,
        "level":"error",
        "output":"${WORK_DIR}/logs/box.log",
        "timestamp":true
    }
}
EOF

  # 生成 outbound 配置
  cat > ${WORK_DIR}/conf/01_outbounds.json << EOF
{
    "outbounds":[
        {
            "type":"direct",
            "tag":"direct"
        }
    ]
}
EOF

  # 生成 endpoint 配置
  cat > ${WORK_DIR}/conf/02_endpoints.json << EOF
{
    "endpoints":[
        {
            "type":"wireguard",
            "tag":"warp-ep",
            "mtu":1280,
            "address":[
                "172.16.0.2/32",
                "2606:4700:110:8a36:df92:102a:9602:fa18/128"
            ],
            "private_key":"YFYOAdbw1bKTHlNNi+aEjBM3BO7unuFC5rOkMRAz9XY=",
            "peers": [
              {
                "address": "engage.cloudflareclient.com",
                "port":2408,
                "public_key":"bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
                "allowed_ips": [
                  "0.0.0.0/0",
                  "::/0"
                ],
                "reserved":[
                    78,
                    135,
                    76
                ]
              }
            ]
        }
    ]
}
EOF

  # 生成 route 配置
  cat > ${WORK_DIR}/conf/03_route.json << EOF
{
    "route":{
        "rule_set":[
            {
                "tag":"geosite-openai",
                "type":"remote",
                "format":"binary",
                "url":"https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-openai.srs"
            }
        ],
        "rules":[
            {
                "action": "sniff"
            },
            {
                "action": "resolve",
                "domain":[
                    "api.openai.com"
                ],
                "strategy": "prefer_ipv4"
            },
            {
                "action": "resolve",
                "rule_set":[
                    "geosite-openai"
                ],
                "strategy": "prefer_ipv6"
            },
            {
                "domain":[
                    "api.openai.com"
                ],
                "rule_set":[
                    "geosite-openai"
                ],
                "outbound":"${CHATGPT_OUT}"
            }
        ]
    }
}
EOF

  # 生成缓存文件
  cat > ${WORK_DIR}/conf/04_experimental.json << EOF
{
    "experimental": {
        "cache_file": {
            "enabled": true,
            "path": "${WORK_DIR}/cache.db",
            "cache_id": "sing-box-cache"
        },
        "clash_api": {
            "external_controller": "127.0.0.1:9090",
            "external_ui": "ui",
            "secret": ""
        },
        "v2ray_api": {
            "listen": "127.0.0.1:62789",
            "stats": {
                "enabled": true
            }
        }
    }
}
EOF

  # 生成 dns 配置文件
  cat > ${WORK_DIR}/conf/05_dns.json << EOF
{
    "dns":{
        "servers":[
            {
                "type":"local"
            }
        ],
        "strategy": "${STRATEGY}"
    }
}
EOF

  # 内建的 NTP 客户端服务配置文件，这对于无法进行时间同步的环境很有用
  cat > ${WORK_DIR}/conf/06_ntp.json << EOF
{
    "ntp": {
        "enabled": true,
        "server": "time.apple.com",
        "server_port": 123,
        "interval": "60m"
    }
}
EOF

  # 生成 XTLS + Reality 配置
  [ "${XTLS_REALITY}" = 'true' ] && ((PORT++)) && PORT_XTLS_REALITY=$PORT && cat > ${WORK_DIR}/conf/11_xtls-reality_inbounds.json << EOF
//  "public_key":"${REALITY_PUBLIC}"
{
    "inbounds":[
        {
            "type":"vless",
            "tag":"${NODE_NAME} xtls-reality",
            "listen":"::",
            "listen_port":${PORT_XTLS_REALITY},
            "users":[
                {
                    "uuid":"${UUID}",
                    "flow":""
                }
            ],
            "tls":{
                "enabled":true,
                "server_name":"addons.mozilla.org",
                "reality":{
                    "enabled":true,
                    "handshake":{
                        "server":"addons.mozilla.org",
                        "server_port":443
                    },
                    "private_key":"${REALITY_PRIVATE}",
                    "short_id":[
                        ""
                    ]
                }
            },
            "multiplex":{
                "enabled":true,
                "padding":true,
                "brutal":{
                    "enabled":${IS_BRUTAL},
                    "up_mbps":1000,
                    "down_mbps":1000
                }
            }
        }
    ]
}
EOF

  # 生成 Hysteria2 配置
  [ "${HYSTERIA2}" = 'true' ] && ((PORT++)) && PORT_HYSTERIA2=$PORT && cat > ${WORK_DIR}/conf/12_hysteria2_inbounds.json << EOF
{
    "inbounds":[
        {
            "type":"hysteria2",
            "tag":"${NODE_NAME} hysteria2",
            "listen":"::",
            "listen_port":${PORT_HYSTERIA2},
            "users":[
                {
                    "password":"${UUID}"
                }
            ],
            "ignore_client_bandwidth":false,
            "tls":{
                "enabled":true,
                "server_name":"",
                "alpn":[
                    "h3"
                ],
                "min_version":"1.3",
                "max_version":"1.3",
                "certificate_path":"${WORK_DIR}/cert/cert.pem",
                "key_path":"${WORK_DIR}/cert/private.key"
            }
        }
    ]
}
EOF

  # 生成 Tuic V5 配置
  [ "${TUIC}" = 'true' ] && ((PORT++)) && PORT_TUIC=$PORT && cat > ${WORK_DIR}/conf/13_tuic_inbounds.json << EOF
{
    "inbounds":[
        {
            "type":"tuic",
            "tag":"${NODE_NAME} tuic",
            "listen":"::",
            "listen_port":${PORT_TUIC},
            "users":[
                {
                    "uuid":"${UUID}",
                    "password":"${UUID}"
                }
            ],
            "congestion_control": "bbr",
            "zero_rtt_handshake": false,
            "tls":{
                "enabled":true,
                "alpn":[
                    "h3"
                ],
                "certificate_path":"${WORK_DIR}/cert/cert.pem",
                "key_path":"${WORK_DIR}/cert/private.key"
            }
        }
    ]
}
EOF

  # 生成 ShadowTLS V5 配置
  [ "${SHADOWTLS}" = 'true' ] && ((PORT++)) && PORT_SHADOWTLS=$PORT && cat > ${WORK_DIR}/conf/14_ShadowTLS_inbounds.json << EOF
{
    "inbounds":[
        {
            "type":"shadowtls",
            "tag":"${NODE_NAME} ShadowTLS",
            "listen":"::",
            "listen_port":${PORT_SHADOWTLS},
            "detour":"shadowtls-in",
            "version":3,
            "users":[
                {
                    "password":"${UUID}"
                }
            ],
            "handshake":{
                "server":"addons.mozilla.org",
                "server_port":443
            },
            "strict_mode":true
        },
        {
            "type":"shadowsocks",
            "tag":"shadowtls-in",
            "listen":"127.0.0.1",
            "network":"tcp",
            "method":"2022-blake3-aes-128-gcm",
            "password":"${SHADOWTLS_PASSWORD}",
            "multiplex":{
                "enabled":true,
                "padding":true,
                "brutal":{
                    "enabled":${IS_BRUTAL},
                    "up_mbps":1000,
                    "down_mbps":1000
                }
            }
        }
    ]
}
EOF

  # 生成 Shadowsocks 配置
  [ "${SHADOWSOCKS}" = 'true' ] && ((PORT++)) && PORT_SHADOWSOCKS=$PORT && cat > ${WORK_DIR}/conf/15_shadowsocks_inbounds.json << EOF
{
    "inbounds":[
        {
            "type":"shadowsocks",
            "tag":"${NODE_NAME} shadowsocks",
            "listen":"::",
            "listen_port":${PORT_SHADOWSOCKS},
            "method":"aes-128-gcm",
            "password":"${UUID}",
            "multiplex":{
                "enabled":true,
                "padding":true,
                "brutal":{
                    "enabled":${IS_BRUTAL},
                    "up_mbps":1000,
                    "down_mbps":1000
                }
            }
        }
    ]
}
EOF

  # 生成 Trojan 配置
  [ "${TROJAN}" = 'true' ] && ((PORT++)) && PORT_TROJAN=$PORT && cat > ${WORK_DIR}/conf/16_trojan_inbounds.json << EOF
{
    "inbounds":[
        {
            "type":"trojan",
            "tag":"${NODE_NAME} trojan",
            "listen":"::",
            "listen_port":${PORT_TROJAN},
            "users":[
                {
                    "password":"${UUID}"
                }
            ],
            "tls":{
                "enabled":true,
                "certificate_path":"${WORK_DIR}/cert/cert.pem",
                "key_path":"${WORK_DIR}/cert/private.key"
            },
            "multiplex":{
                "enabled":true,
                "padding":true,
                "brutal":{
                    "enabled":${IS_BRUTAL},
                    "up_mbps":1000,
                    "down_mbps":1000
                }
            }
        }
    ]
}
EOF

  # 生成 vmess + ws 配置
  [ "${VMESS_WS}" = 'true' ] && ((PORT++)) && PORT_VMESS_WS=$PORT && cat > ${WORK_DIR}/conf/17_vmess-ws_inbounds.json << EOF
//  "CDN": "${CDN}"
{
    "inbounds":[
        {
            "type":"vmess",
            "tag":"${NODE_NAME} vmess-ws",
            "listen":"127.0.0.1",
            "listen_port":${PORT_VMESS_WS},
            "tcp_fast_open":false,
            "proxy_protocol":false,
            "users":[
                {
                    "uuid":"${UUID}",
                    "alterId":0
                }
            ],
            "transport":{
                "type":"ws",
                "path":"/${UUID}-vmess",
                "max_early_data":2048,
                "early_data_header_name":"Sec-WebSocket-Protocol"
            },
            "multiplex":{
                "enabled":true,
                "padding":true,
                "brutal":{
                    "enabled":${IS_BRUTAL},
                    "up_mbps":1000,
                    "down_mbps":1000
                }
            }
        }
    ]
}
EOF

  # 生成 vless + ws + tls 配置
  [ "${VLESS_WS}" = 'true' ] && ((PORT++)) && PORT_VLESS_WS=$PORT && cat > ${WORK_DIR}/conf/18_vless-ws-tls_inbounds.json << EOF
//  "CDN": "${CDN}"
{
    "inbounds":[
        {
            "type":"vless",
            "tag":"${NODE_NAME} vless-ws-tls",
            "listen":"::",
            "listen_port":${PORT_VLESS_WS},
            "tcp_fast_open":false,
            "proxy_protocol":false,
            "users":[
                {
                    "name":"sing-box",
                    "uuid":"${UUID}"
                }
            ],
            "transport":{
                "type":"ws",
                "path":"/${UUID}-vless",
                "max_early_data":2048,
                "early_data_header_name":"Sec-WebSocket-Protocol"
            },
            "multiplex":{
                "enabled":true,
                "padding":true,
                "brutal":{
                    "enabled":${IS_BRUTAL},
                    "up_mbps":1000,
                    "down_mbps":1000
                }
            }
        }
    ]
}
EOF

  # 生成 H2 + Reality 配置
  [ "${H2_REALITY}" = 'true' ] && ((PORT++)) && PORT_H2_REALITY=$PORT && cat > ${WORK_DIR}/conf/19_h2-reality_inbounds.json << EOF
//  "public_key":"${REALITY_PUBLIC}"
{
    "inbounds":[
        {
            "type":"vless",
            "tag":"${NODE_NAME} h2-reality",
            "listen":"::",
            "listen_port":${PORT_H2_REALITY},
            "users":[
                {
                    "uuid":"${UUID}"
                }
            ],
            "tls":{
                "enabled":true,
                "server_name":"addons.mozilla.org",
                "reality":{
                    "enabled":true,
                    "handshake":{
                        "server":"addons.mozilla.org",
                        "server_port":443
                    },
                    "private_key":"${REALITY_PRIVATE}",
                    "short_id":[
                        ""
                    ]
                }
            },
            "transport": {
                "type": "http"
            },
            "multiplex":{
                "enabled":true,
                "padding":true,
                "brutal":{
                    "enabled":${IS_BRUTAL},
                    "up_mbps":1000,
                    "down_mbps":1000
                }
            }
        }
    ]
}
EOF

  # 生成 gRPC + Reality 配置
  [ "${GRPC_REALITY}" = 'true' ] && ((PORT++)) && PORT_GRPC_REALITY=$PORT && cat > ${WORK_DIR}/conf/20_grpc-reality_inbounds.json << EOF
//  "public_key":"${REALITY_PUBLIC}"
{
    "inbounds":[
        {
            "type":"vless",
            "sniff":true,
            "sniff_override_destination":true,
            "tag":"${NODE_NAME} grpc-reality",
            "listen":"::",
            "listen_port":${PORT_GRPC_REALITY},
            "users":[
                {
                    "uuid":"${UUID}"
                }
            ],
            "tls":{
                "enabled":true,
                "server_name":"addons.mozilla.org",
                "reality":{
                    "enabled":true,
                    "handshake":{
                        "server":"addons.mozilla.org",
                        "server_port":443
                    },
                    "private_key":"${REALITY_PRIVATE}",
                    "short_id":[
                        ""
                    ]
                }
            },
            "transport": {
                "type": "grpc",
                "service_name": "grpc"
            },
            "multiplex":{
                "enabled":true,
                "padding":true,
                "brutal":{
                    "enabled":${IS_BRUTAL},
                    "up_mbps":1000,
                    "down_mbps":1000
                }
            }
        }
    ]
}
EOF

  # 生成 AnyTLS 配置
  [ "${ANYTLS}" = 'true' ] && ((PORT++)) && PORT_ANYTLS=$PORT && cat > ${WORK_DIR}/conf/21_anytls_inbounds.json << EOF
{
    "inbounds":[
        {
            "type":"anytls",
            "tag":"${NODE_NAME} anytls",
            "listen":"::",
            "listen_port":$PORT_ANYTLS,
            "users":[
                {
                    "password":"${UUID}"
                }
            ],
            "padding_scheme":[],
            "tls":{
                "enabled":true,
                "certificate_path":"${WORK_DIR}/cert/cert.pem",
                "key_path":"${WORK_DIR}/cert/private.key"
            }
        }
    ]
}
EOF

  # 判断 argo 隧道类型
  if [[ -n "$ARGO_DOMAIN" && -n "$ARGO_AUTH" ]]; then
    if [[ "$ARGO_AUTH" =~ TunnelSecret ]]; then
      ARGO_JSON=${ARGO_AUTH//[ ]/}
      ARGO_RUNS="cloudflared tunnel --edge-ip-version auto --config ${WORK_DIR}/tunnel.yml run"
      echo $ARGO_JSON > ${WORK_DIR}/tunnel.json
      cat > ${WORK_DIR}/tunnel.yml << EOF
tunnel: $(cut -d\" -f12 <<< $ARGO_JSON)
credentials-file: ${WORK_DIR}/tunnel.json

ingress:
  - hostname: ${ARGO_DOMAIN}
    service: https://localhost:${START_PORT}
    originRequest:
      noTLSVerify: true
  - service: http_status:404
EOF

    elif [[ "${ARGO_AUTH}" =~ [a-z0-9A-Z=]{120,250} ]]; then
      [[ "{$ARGO_AUTH}" =~ cloudflared.*service ]] && ARGO_TOKEN=$(awk -F ' ' '{print $NF}' <<< "$ARGO_AUTH") || ARGO_TOKEN=$ARGO_AUTH
      ARGO_RUNS="cloudflared tunnel --edge-ip-version auto run --token ${ARGO_TOKEN}"
    fi
  else
    ((PORT++))
    METRICS_PORT=$PORT
    ARGO_RUNS="cloudflared tunnel --edge-ip-version auto --no-autoupdate --no-tls-verify --metrics 0.0.0.0:$METRICS_PORT --url https://localhost:$START_PORT"
  fi

  # 生成 supervisord 配置文件
  mkdir -p /etc/supervisord.d
  SUPERVISORD_CONF="[supervisord]
user=root
nodaemon=true
logfile=/var/log/supervisord.log
pidfile=/var/run/supervisord.pid
childlogdir=/var/log/supervisor

[unix_http_server]
file=/var/run/supervisor.sock

[supervisorctl]
serverurl=unix:///var/run/supervisor.sock

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[include]
files = /etc/supervisord.d/*.ini

[program:nginx]
command=/usr/sbin/nginx -g 'daemon off;'
autostart=true
autorestart=true
stderr_logfile=/var/log/supervisor/nginx_stderr.log
stdout_logfile=/var/log/supervisor/nginx_stdout.log
user=root
priority=100

[program:sing-box]
command=${WORK_DIR}/sing-box run -C ${WORK_DIR}/conf/
autostart=true
autorestart=true
stderr_logfile=/var/log/supervisor/sing-box_stderr.log
stdout_logfile=/var/log/supervisor/sing-box_stdout.log
user=root
priority=200
environment=PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\""

  # 检查 sing-box 配置文件是否存在
  if [ ! -f "${WORK_DIR}/sing-box" ]; then
    warning "sing-box 可执行文件不存在，请检查下载是否成功"
    exit 1
  fi

[ -z "$METRICS_PORT" ] && SUPERVISORD_CONF+="

[program:argo]
command=${WORK_DIR}/$ARGO_RUNS
autostart=true
autorestart=true
stderr_logfile=/var/log/supervisor/argo_stderr.log
stdout_logfile=/var/log/supervisor/argo_stdout.log
user=root
priority=300
"

  # 创建必要的目录
  mkdir -p /var/log/supervisor /var/run
  
  # 写入配置文件
  echo "$SUPERVISORD_CONF" > /etc/supervisord.conf
  info "supervisord 配置文件已生成"

  # 如使用临时隧道，先运行 cloudflared 以获取临时隧道域名
  if [ -n "$METRICS_PORT" ]; then
    ${WORK_DIR}/$ARGO_RUNS >/dev/null 2>&1 &
    sleep 15
    local ARGO_DOMAIN=$(wget -qO- http://localhost:$METRICS_PORT/quicktunnel | awk -F '"' '{print $4}')
  fi

  # 生成 nginx 配置文件
  local NGINX_CONF="user singbox;

  worker_processes auto;
  worker_cpu_affinity auto;

  error_log  /var/log/nginx/error.log warn;
  pid        /var/run/nginx.pid;

  events {
      worker_connections  4096;
      use epoll;
      multi_accept on;
  }

  http {
    map \$http_user_agent \$path {
      default                    /;                # 默认路径
      ~*v2rayN|Neko              /base64;          # 匹配 V2rayN / NekoBox 客户端
      ~*clash                    /clash;           # 匹配 Clash 客户端
      ~*ShadowRocket             /shadowrocket;    # 匹配 ShadowRocket  客户端
      ~*SFM                      /sing-box-pc;     # 匹配 Sing-box pc 客户端
      ~*SFI|SFA                  /sing-box-phone;  # 匹配 Sing-box phone 客户端
   #   ~*Chrome|Firefox|Mozilla  /;                # 添加更多的分流规则
    }

      include       /etc/nginx/mime.types;
      default_type  application/octet-stream;

      log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                        '\$status \$body_bytes_sent "\$http_referer" '
                        '"\$http_user_agent" "\$http_x_forwarded_for"';

      access_log  /var/log/nginx/access.log main;

      sendfile        on;
      tcp_nopush     on;
      tcp_nodelay    on;

      keepalive_timeout  65;
      keepalive_requests 100;

      # 启用 gzip 压缩
      gzip on;
      gzip_vary on;
      gzip_min_length 1024;
      gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

      # 启用缓存
      open_file_cache max=1000 inactive=20s;
      open_file_cache_valid 30s;
      open_file_cache_min_uses 2;
      open_file_cache_errors on;

      # 优化缓冲区
      client_body_buffer_size 128k;
      client_header_buffer_size 1k;
      large_client_header_buffers 4 4k;
      output_buffers 1 32k;
      postpone_output 1460;

      # 隐藏 nginx 版本
      server_tokens off;

      # 限制请求大小
      client_max_body_size 1M;

      # 限制连接数
      limit_conn_zone \$binary_remote_addr zone=conn_limit_per_ip:10m;
      limit_conn conn_limit_per_ip 10;

      #include /etc/nginx/conf.d/*.conf;

    server {
      listen 127.0.0.1:$START_PORT ssl ; # sing-box backend
      http2 on;
      server_name addons.mozilla.org;

      ssl_certificate            ${WORK_DIR}/cert/cert.pem;
      ssl_certificate_key        ${WORK_DIR}/cert/private.key;
      ssl_protocols              TLSv1.2 TLSv1.3;
      ssl_ciphers                ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
      ssl_prefer_server_ciphers  on;
      ssl_session_cache          shared:SSL:10m;
      ssl_session_timeout        10m;
      ssl_session_tickets        on;
      ssl_stapling               off;
      ssl_stapling_verify        off;

      # 安全头配置
      add_header X-Frame-Options \"SAMEORIGIN\" always;
      add_header X-Content-Type-Options \"nosniff\" always;
      add_header X-XSS-Protection \"1; mode=block\" always;
      add_header Referrer-Policy \"strict-origin-when-cross-origin\" always;
      add_header Content-Security-Policy \"default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';\" always;
      add_header Strict-Transport-Security \"max-age=31536000; includeSubDomains\" always;"

  [ "${VLESS_WS}" = 'true' ] && NGINX_CONF+="
      # 反代 sing-box vless websocket
      location /${UUID}-vless {
        if (\$http_upgrade != "websocket") {
           return 404;
        }
        proxy_pass                          http://127.0.0.1:${PORT_VLESS_WS};
        proxy_http_version                  1.1;
        proxy_set_header Upgrade            \$http_upgrade;
        proxy_set_header Connection         "upgrade";
        proxy_set_header X-Real-IP          \$remote_addr;
        proxy_set_header X-Forwarded-For    \$proxy_add_x_forwarded_for;
        proxy_set_header Host               \$host;
        proxy_redirect                      off;
      }"

  [ "${VMESS_WS}" = 'true' ] && NGINX_CONF+="
      # 反代 sing-box websocket
      location /${UUID}-vmess {
        if (\$http_upgrade != "websocket") {
           return 404;
        }
        proxy_pass                          http://127.0.0.1:${PORT_VMESS_WS};
        proxy_http_version                  1.1;
        proxy_set_header Upgrade            \$http_upgrade;
        proxy_set_header Connection         "upgrade";
        proxy_set_header X-Real-IP          \$remote_addr;
        proxy_set_header X-Forwarded-For    \$proxy_add_x_forwarded_for;
        proxy_set_header Host               \$host;
        proxy_redirect                      off;
      }"

  NGINX_CONF+="
      # 来自 /auto 的分流
      location ~ ^/${UUID}/auto {
        default_type 'text/plain; charset=utf-8';
        alias ${WORK_DIR}/subscribe/\$path;
      }

      location ~ ^/${UUID}/(.*) {
        autoindex on;
        proxy_set_header X-Real-IP \$proxy_protocol_addr;
        default_type 'text/plain; charset=utf-8';
        alias ${WORK_DIR}/subscribe/\$1;
      }
    }
  }"

  echo "$NGINX_CONF" > /etc/nginx/nginx.conf

  # IPv6 时的 IP 处理
  if [[ "$SERVER_IP" =~ : ]]; then
    SERVER_IP_1="[$SERVER_IP]"
    SERVER_IP_2="[[$SERVER_IP]]"
  else
    SERVER_IP_1="$SERVER_IP"
    SERVER_IP_2="$SERVER_IP"
  fi

  # 生成各订阅文件
  # 生成 Clash proxy providers 订阅文件
  local CLASH_SUBSCRIBE='proxies:'

  [ "${XTLS_REALITY}" = 'true' ] && local CLASH_XTLS_REALITY="- {name: \"${NODE_NAME} xtls-reality\", type: vless, server: ${SERVER_IP}, port: ${PORT_XTLS_REALITY}, uuid: ${UUID}, network: tcp, udp: true, tls: true, servername: addons.mozilla.org, client-fingerprint: chrome, reality-opts: {public-key: ${REALITY_PUBLIC}, short-id: \"\"}, smux: { enabled: true, protocol: 'h2mux', padding: true, max-connections: '8', min-streams: '16', statistic: true, only-tcp: false }, brutal-opts: { enabled: ${IS_BRUTAL}, up: '1000 Mbps', down: '1000 Mbps' } }" &&
  local CLASH_SUBSCRIBE+="
  $CLASH_XTLS_REALITY
"
  [ "${HYSTERIA2}" = 'true' ] && local CLASH_HYSTERIA2="- {name: \"${NODE_NAME} hysteria2\", type: hysteria2, server: ${SERVER_IP}, port: ${PORT_HYSTERIA2}, up: \"200 Mbps\", down: \"1000 Mbps\", password: ${UUID}, skip-cert-verify: true}" &&
  local CLASH_SUBSCRIBE+="
  - {name: \"${NODE_NAME} hysteria2\", type: hysteria2, server: ${SERVER_IP}, port: ${PORT_HYSTERIA2}, up: \"200 Mbps\", down: \"1000 Mbps\", password: ${UUID}, skip-cert-verify: true}
"
  [ "${TUIC}" = 'true' ] && local CLASH_TUIC="- {name: \"${NODE_NAME} tuic\", type: tuic, server: ${SERVER_IP}, port: ${PORT_TUIC}, uuid: ${UUID}, password: ${UUID}, alpn: [h3], disable-sni: true, reduce-rtt: true, request-timeout: 8000, udp-relay-mode: native, congestion-controller: bbr, skip-cert-verify: true}" &&
  local CLASH_SUBSCRIBE+="
  $CLASH_TUIC
"
  [ "${SHADOWTLS}" = 'true' ] && local CLASH_SHADOWTLS="- {name: \"${NODE_NAME} ShadowTLS\", type: ss, server: ${SERVER_IP}, port: ${PORT_SHADOWTLS}, cipher: 2022-blake3-aes-128-gcm, password: ${SHADOWTLS_PASSWORD}, plugin: shadow-tls, client-fingerprint: chrome, plugin-opts: {host: addons.mozilla.org, password: \"${UUID}\", version: 3}, smux: { enabled: true, protocol: 'h2mux', padding: true, max-connections: '8', min-streams: '16', statistic: true, only-tcp: false }, brutal-opts: { enabled: ${IS_BRUTAL}, up: '1000 Mbps', down: '1000 Mbps' } }" &&
  local CLASH_SUBSCRIBE+="
  $CLASH_SHADOWTLS
"
  [ "${SHADOWSOCKS}" = 'true' ] && local CLASH_SHADOWSOCKS="- {name: \"${NODE_NAME} shadowsocks\", type: ss, server: ${SERVER_IP}, port: $PORT_SHADOWSOCKS, cipher: aes-128-gcm, password: ${UUID}, smux: { enabled: true, protocol: 'h2mux', padding: true, max-connections: '8', min-streams: '16', statistic: true, only-tcp: false }, brutal-opts: { enabled: ${IS_BRUTAL}, up: '1000 Mbps', down: '1000 Mbps' } }" &&
  local CLASH_SUBSCRIBE+="
  $CLASH_SHADOWSOCKS
"
  [ "${TROJAN}" = 'true' ] && local CLASH_TROJAN="- {name: \"${NODE_NAME} trojan\", type: trojan, server: ${SERVER_IP}, port: $PORT_TROJAN, password: ${UUID}, client-fingerprint: random, skip-cert-verify: true, smux: { enabled: true, protocol: 'h2mux', padding: true, max-connections: '8', min-streams: '16', statistic: true, only-tcp: false }, brutal-opts: { enabled: ${IS_BRUTAL}, up: '1000 Mbps', down: '1000 Mbps' } }" &&
  local CLASH_SUBSCRIBE+="
  $CLASH_TROJAN
"
  [ "${VMESS_WS}" = 'true' ] && local CLASH_VMESS_WS="- {name: \"${NODE_NAME} vmess-ws\", type: vmess, server: ${CDN}, port: 80, uuid: ${UUID}, udp: true, tls: false, alterId: 0, cipher: auto, skip-cert-verify: true, network: ws, ws-opts: { path: \"/${UUID}-vmess\", headers: {Host: ${ARGO_DOMAIN}} }, smux: { enabled: true, protocol: 'h2mux', padding: true, max-connections: '8', min-streams: '16', statistic: true, only-tcp: false }, brutal-opts: { enabled: ${IS_BRUTAL}, up: '1000 Mbps', down: '1000 Mbps' } }" &&
  local CLASH_SUBSCRIBE+="
  $CLASH_VMESS_WS
"
  [ "${VLESS_WS}" = 'true' ] && local CLASH_VLESS_WS="- {name: \"${NODE_NAME} vless-ws-tls\", type: vless, server: ${CDN}, port: 443, uuid: ${UUID}, udp: true, tls: true, servername: ${ARGO_DOMAIN}, network: ws, skip-cert-verify: true, ws-opts: { path: \"/${UUID}-vless\", headers: {Host: ${ARGO_DOMAIN}}, max-early-data: 2048, early-data-header-name: Sec-WebSocket-Protocol }, smux: { enabled: true, protocol: 'h2mux', padding: true, max-connections: '8', min-streams: '16', statistic: true, only-tcp: false }, brutal-opts: { enabled: ${IS_BRUTAL}, up: '1000 Mbps', down: '1000 Mbps' } }" &&
  local CLASH_SUBSCRIBE+="
  $CLASH_VLESS_WS
"
  # Clash 的 H2 传输层未实现多路复用功能，在 Clash.Meta 中更建议使用 gRPC 协议，故不输出相关配置。 https://wiki.metacubex.one/config/proxies/vless/
  [ "${H2_REALITY}" = 'true' ]

  [ "${GRPC_REALITY}" = 'true' ] && local CLASH_GRPC_REALITY="- {name: \"${NODE_NAME} grpc-reality\", type: vless, server: ${SERVER_IP}, port: ${PORT_GRPC_REALITY}, uuid: ${UUID}, network: grpc, tls: true, udp: true, flow: , client-fingerprint: chrome, servername: addons.mozilla.org, grpc-opts: {  grpc-service-name: \"grpc\" }, reality-opts: { public-key: ${REALITY_PUBLIC}, short-id: \"\" }, smux: { enabled: true, protocol: 'h2mux', padding: true, max-connections: '8', min-streams: '16', statistic: true, only-tcp: false }, brutal-opts: { enabled: ${IS_BRUTAL}, up: '1000 Mbps', down: '1000 Mbps' } }" &&
  local CLASH_SUBSCRIBE+="
  $CLASH_GRPC_REALITY
"
  [ "${ANYTLS}" = 'true' ] && local CLASH_ANYTLS="- {name: \"${NODE_NAME} anytls\", type: anytls, server: ${SERVER_IP}, port: $PORT_ANYTLS, password: ${UUID}, client-fingerprint: chrome, udp: true, idle-session-check-interval: 30, idle-session-timeout: 30, skip-cert-verify: true }" &&
  local CLASH_SUBSCRIBE+="
  $CLASH_ANYTLS
"

  echo -n "${CLASH_SUBSCRIBE}" | sed -E '/^[ ]*#|^--/d' | sed '/^$/d' > ${WORK_DIR}/subscribe/proxies

  # 生成 clash 订阅配置文件
  # 模板: 使用 proxy providers
  wget -qO- --tries=3 --timeout=2 ${SUBSCRIBE_TEMPLATE}/clash | sed "s#NODE_NAME#${NODE_NAME}#g; s#PROXY_PROVIDERS_URL#https://${ARGO_DOMAIN}/${UUID}/proxies#" > ${WORK_DIR}/subscribe/clash

  # 生成 ShadowRocket 订阅配置文件
  [ "${XTLS_REALITY}" = 'true' ] && local SHADOWROCKET_SUBSCRIBE+="
vless://$(echo -n "auto:${UUID}@${SERVER_IP_2}:${PORT_XTLS_REALITY}" | base64 -w0)?remarks=${NODE_NAME} xtls-reality&obfs=none&tls=1&peer=addons.mozilla.org&mux=1&pbk=${REALITY_PUBLIC}
"
  [ "${HYSTERIA2}" = 'true' ] && local SHADOWROCKET_SUBSCRIBE+="
hysteria2://${UUID}@${SERVER_IP_1}:${PORT_HYSTERIA2}?insecure=1&obfs=none#${NODE_NAME}%20hysteria2
"
  [ "${TUIC}" = 'true' ] && local SHADOWROCKET_SUBSCRIBE+="
tuic://${UUID}:${UUID}@${SERVER_IP_2}:${PORT_TUIC}?congestion_control=bbr&udp_relay_mode=native&alpn=h3&allow_insecure=1#${NODE_NAME}%20tuic
"
  [ "${SHADOWTLS}" = 'true' ] && local SHADOWROCKET_SUBSCRIBE+="
ss://$(echo -n "2022-blake3-aes-128-gcm:${SHADOWTLS_PASSWORD}@${SERVER_IP_2}:${PORT_SHADOWTLS}" | base64 -w0)?shadow-tls=$(echo -n "{\"version\":\"3\",\"host\":\"addons.mozilla.org\",\"password\":\"${UUID}\"}" | base64 -w0)#${NODE_NAME}%20ShadowTLS
"
  [ "${SHADOWSOCKS}" = 'true' ] && local SHADOWROCKET_SUBSCRIBE+="
ss://$(echo -n "aes-128-gcm:${UUID}@${SERVER_IP_2}:$PORT_SHADOWSOCKS" | base64 -w0)#${NODE_NAME}%20shadowsocks
"
  [ "${TROJAN}" = 'true' ] && local SHADOWROCKET_SUBSCRIBE+="
trojan://${UUID}@${SERVER_IP_1}:$PORT_TROJAN?allowInsecure=1#${NODE_NAME}%20trojan
"
  [ "${VMESS_WS}" = 'true' ] && local SHADOWROCKET_SUBSCRIBE+="
----------------------------
vmess://$(echo -n "auto:${UUID}@${CDN}:80" | base64 -w0)?remarks=${NODE_NAME}%20vmess-ws&obfsParam=${ARGO_DOMAIN}&path=/${UUID}-vmess&obfs=websocket&alterId=0
"
  [ "${VLESS_WS}" = 'true' ] && local SHADOWROCKET_SUBSCRIBE+="
----------------------------
vless://$(echo -n "auto:${UUID}@${CDN}:443" | base64 -w0)?remarks=${NODE_NAME} vless-ws-tls&obfsParam=${ARGO_DOMAIN}&path=/${UUID}-vless?ed=2048&obfs=websocket&tls=1&peer=${ARGO_DOMAIN}&allowInsecure=1
"
  [ "${H2_REALITY}" = 'true' ] && local SHADOWROCKET_SUBSCRIBE+="
----------------------------
vless://$(echo -n auto:${UUID}@${SERVER_IP_2}:${PORT_H2_REALITY} | base64 -w0)?remarks=${NODE_NAME}%20h2-reality&path=/&obfs=h2&tls=1&peer=addons.mozilla.org&alpn=h2&mux=1&pbk=${REALITY_PUBLIC}
"
  [ "${GRPC_REALITY}" = 'true' ] && local SHADOWROCKET_SUBSCRIBE+="
vless://$(echo -n "auto:${UUID}@${SERVER_IP_2}:${PORT_GRPC_REALITY}" | base64 -w0)?remarks=${NODE_NAME}%20grpc-reality&path=grpc&obfs=grpc&tls=1&peer=addons.mozilla.org&pbk=${REALITY_PUBLIC}
"
  [ "${ANYTLS}" = 'true' ] && local SHADOWROCKET_SUBSCRIBE+="
anytls://${UUID}@${SERVER_IP_1}:${PORT_ANYTLS}?insecure=1&udp=1#${NODE_NAME}%20&anytls
"
  echo -n "$SHADOWROCKET_SUBSCRIBE" | sed -E '/^[ ]*#|^--/d' | sed '/^$/d' | base64 -w0 > ${WORK_DIR}/subscribe/shadowrocket

  # 生成 V2rayN 订阅文件
  [ "${XTLS_REALITY}" = 'true' ] && local V2RAYN_SUBSCRIBE+="
----------------------------
vless://${UUID}@${SERVER_IP_1}:${PORT_XTLS_REALITY}?encryption=none&security=reality&sni=addons.mozilla.org&fp=chrome&pbk=${REALITY_PUBLIC}&type=tcp&headerType=none#${NODE_NAME// /%20}%20xtls-reality"

  [ "${HYSTERIA2}" = 'true' ] && local V2RAYN_SUBSCRIBE+="
----------------------------
hysteria2://${UUID}@${SERVER_IP_1}:${PORT_HYSTERIA2}/?alpn=h3&insecure=1#${NODE_NAME// /%20}%20hysteria2"

  [ "${TUIC}" = 'true' ] && local V2RAYN_SUBSCRIBE+="
----------------------------
tuic://${UUID}:${UUID}@${SERVER_IP_1}:${PORT_TUIC}?alpn=h3&congestion_control=bbr#${NODE_NAME// /%20}%20tuic

# $(info "请把 tls 里的 inSecure 设置为 true")"

  [ "${SHADOWTLS}" = 'true' ] && local V2RAYN_SUBSCRIBE+="
----------------------------
# $(info "ShadowTLS 配置文件内容，需要更新 sing_box 内核")

{
  \"log\":{
      \"level\":\"warn\"
  },
  \"inbounds\":[
      {
          \"listen\":\"127.0.0.1\",
          \"listen_port\":${PORT_SHADOWTLS},
          \"sniff\":true,
          \"sniff_override_destination\":false,
          \"tag\": \"ShadowTLS\",
          \"type\":\"mixed\"
      }
  ],
  \"outbounds\":[
      {
          \"detour\":\"shadowtls-out\",
          \"method\":\"2022-blake3-aes-128-gcm\",
          \"password\":\"${SHADOWTLS_PASSWORD}\",
          \"type\":\"shadowsocks\",
          \"udp_over_tcp\": false,
          \"multiplex\": {
            \"enabled\": true,
            \"protocol\": \"h2mux\",
            \"max_connections\": 8,
            \"min_streams\": 16,
            \"padding\": true
          }
      },
      {
          \"password\":\"${UUID}\",
          \"server\":\"${SERVER_IP}\",
          \"server_port\":${PORT_SHADOWTLS},
          \"tag\": \"shadowtls-out\",
          \"tls\":{
              \"enabled\":true,
              \"server_name\":\"addons.mozilla.org\",
              \"utls\": {
                \"enabled\": true,
                \"fingerprint\": \"chrome\"
              }
          },
          \"type\":\"shadowtls\",
          \"version\":3
      }
  ]
}"
  [ "${SHADOWSOCKS}" = 'true' ] && local V2RAYN_SUBSCRIBE+="
----------------------------
ss://$(echo -n "aes-128-gcm:${UUID}@${SERVER_IP_1}:$PORT_SHADOWSOCKS" | base64 -w0)#${NODE_NAME// /%20}%20shadowsocks"

  [ "${TROJAN}" = 'true' ] && local V2RAYN_SUBSCRIBE+="
----------------------------
trojan://${UUID}@${SERVER_IP_1}:$PORT_TROJAN?security=tls&type=tcp&headerType=none#${NODE_NAME// /%20}%20trojan

# $(info "ShadowTLS 配置文件内容，需要更新 sing_box 内核")"

  [ "${VMESS_WS}" = 'true' ] && local V2RAYN_SUBSCRIBE+="
----------------------------
vmess://$(echo -n "{ \"v\": \"2\", \"ps\": \"${NODE_NAME} vmess-ws\", \"add\": \"${CDN}\", \"port\": \"80\", \"id\": \"${UUID}\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"${ARGO_DOMAIN}\", \"path\": \"/${UUID}-vmess\", \"tls\": \"\", \"sni\": \"\", \"alpn\": \"\" }" | base64 -w0)
"

  [ "${VLESS_WS}" = 'true' ] && local V2RAYN_SUBSCRIBE+="
----------------------------
vless://${UUID}@${CDN}:443?encryption=none&security=tls&sni=${ARGO_DOMAIN}&type=ws&host=${ARGO_DOMAIN}&path=%2F${UUID}-vless%3Fed%3D2048#${NODE_NAME// /%20}%20vless-ws-tls
"

  [ "${H2_REALITY}" = 'true' ] && local V2RAYN_SUBSCRIBE+="
----------------------------
vless://${UUID}@${SERVER_IP_1}:${PORT_H2_REALITY}?encryption=none&security=reality&sni=addons.mozilla.org&fp=chrome&pbk=${REALITY_PUBLIC}&type=http#${NODE_NAME// /%20}%20h2-reality"

  [ "${GRPC_REALITY}" = 'true' ] && local V2RAYN_SUBSCRIBE+="
----------------------------
vless://${UUID}@${SERVER_IP_1}:${PORT_GRPC_REALITY}?encryption=none&security=reality&sni=addons.mozilla.org&fp=chrome&pbk=${REALITY_PUBLIC}&type=grpc&serviceName=grpc&mode=gun#${NODE_NAME// /%20}%20grpc-reality"

  [ "${ANYTLS}" = 'true' ] && local V2RAYN_SUBSCRIBE+="
----------------------------
# $(info "AnyTLS 配置文件内容，需要更新 sing_box 内核")

{
    \"log\":{
        \"level\":\"warn\"
    },
    \"inbounds\":[
        {
            \"listen\":\"127.0.0.1\",
            \"listen_port\":${PORT_ANYTLS},
            \"sniff\":true,
            \"sniff_override_destination\":false,
            \"tag\": \"AnyTLS\",
            \"type\":\"mixed\"
        }
    ],
    \"outbounds\":[
        {
            \"type\": \"anytls\",
            \"tag\": \"${NODE_NAME} anytls\",
            \"server\": \"${SERVER_IP}\",
            \"server_port\": ${PORT_ANYTLS},
            \"password\": \"${UUID}\",
            \"idle_session_check_interval\": \"30s\",
            \"idle_session_timeout\": \"30s\",
            \"min_idle_session\": 5,
            \"tls\": {
              \"enabled\": true,
              \"insecure\": true,
              \"server_name\": \"\"
            }
        }
    ]
}"

  echo -n "$V2RAYN_SUBSCRIBE" | sed -E '/^[ ]*#|^[ ]+|^--|^\{|^\}/d' | sed '/^$/d' | base64 -w0 > ${WORK_DIR}/subscribe/v2rayn

  # 生成 NekoBox 订阅文件
  [ "${XTLS_REALITY}" = 'true' ] && local NEKOBOX_SUBSCRIBE+="
----------------------------
vless://${UUID}@${SERVER_IP_1}:${PORT_XTLS_REALITY}?security=reality&sni=addons.mozilla.org&fp=chrome&pbk=${REALITY_PUBLIC}&type=tcp&encryption=none#${NODE_NAME}%20xtls-reality"

  [ "${HYSTERIA2}" = 'true' ] && local NEKOBOX_SUBSCRIBE+="
----------------------------
hy2://${UUID}@${SERVER_IP_1}:${PORT_HYSTERIA2}?insecure=1#${NODE_NAME} hysteria2"

  [ "${TUIC}" = 'true' ] && local NEKOBOX_SUBSCRIBE+="
----------------------------
tuic://${UUID}:${UUID}@${SERVER_IP_1}:${PORT_TUIC}?congestion_control=bbr&alpn=h3&udp_relay_mode=native&allow_insecure=1&disable_sni=1#${NODE_NAME} tuic"

  [ "${SHADOWTLS}" = 'true' ] && local NEKOBOX_SUBSCRIBE+="
----------------------------
nekoray://custom#$(echo -n "{\"_v\":0,\"addr\":\"127.0.0.1\",\"cmd\":[\"\"],\"core\":\"internal\",\"cs\":\"{\n    \\\"password\\\": \\\"${UUID}\\\",\n    \\\"server\\\": \\\"${SERVER_IP_1}\\\",\n    \\\"server_port\\\": ${PORT_SHADOWTLS},\n    \\\"tag\\\": \\\"shadowtls-out\\\",\n    \\\"tls\\\": {\n        \\\"enabled\\\": true,\n        \\\"server_name\\\": \\\"addons.mozilla.org\\\"\n    },\n    \\\"type\\\": \\\"shadowtls\\\",\n    \\\"version\\\": 3\n}\n\",\"mapping_port\":0,\"name\":\"1-tls-not-use\",\"port\":1080,\"socks_port\":0}" | base64 -w0)

nekoray://shadowsocks#$(echo -n "{\"_v\":0,\"method\":\"2022-blake3-aes-128-gcm\",\"name\":\"2-ss-not-use\",\"pass\":\"${SHADOWTLS_PASSWORD}\",\"port\":0,\"stream\":{\"ed_len\":0,\"insecure\":false,\"mux_s\":0,\"net\":\"tcp\"},\"uot\":0}" | base64 -w0)"

  [ "${SHADOWSOCKS}" = 'true' ] && local NEKOBOX_SUBSCRIBE+="
----------------------------
ss://$(echo -n "aes-128-gcm:${UUID}" | base64 -w0)@${SERVER_IP_1}:$PORT_SHADOWSOCKS#${NODE_NAME} shadowsocks"

  [ "${TROJAN}" = 'true' ] && local NEKOBOX_SUBSCRIBE+="
----------------------------
trojan://${UUID}@${SERVER_IP_1}:$PORT_TROJAN?security=tls&allowInsecure=1&fp=random&type=tcp#${NODE_NAME} trojan"

  [ "${VMESS_WS}" = 'true' ] && local NEKOBOX_SUBSCRIBE+="
----------------------------
vmess://$(echo -n "{\"add\":\"${CDN}\",\"aid\":\"0\",\"host\":\"${ARGO_DOMAIN}\",\"id\":\"${UUID}\",\"net\":\"ws\",\"path\":\"/${UUID}-vmess\",\"port\":\"80\",\"ps\":\"${NODE_NAME} vmess-ws\",\"scy\":\"auto\",\"sni\":\"\",\"tls\":\"\",\"type\":\"\",\"v\":\"2\"}" | base64 -w0)
"

  [ "${VLESS_WS}" = 'true' ] && local NEKOBOX_SUBSCRIBE+="
----------------------------
vless://${UUID}@${CDN}:443?security=tls&sni=${ARGO_DOMAIN}&type=ws&path=/${UUID}-vless?ed%3D2048&host=${ARGO_DOMAIN}#${NODE_NAME}%20vless-ws-tls
"

  [ "${H2_REALITY}" = 'true' ] && local NEKOBOX_SUBSCRIBE+="
----------------------------
vless://${UUID}@${SERVER_IP_1}:${PORT_H2_REALITY}?security=reality&sni=addons.mozilla.org&alpn=h2&fp=chrome&pbk=${REALITY_PUBLIC}&type=http&encryption=none#${NODE_NAME}%20h2-reality"

  [ "${GRPC_REALITY}" = 'true' ] && local NEKOBOX_SUBSCRIBE+="
----------------------------
vless://${UUID}@${SERVER_IP_1}:${PORT_GRPC_REALITY}?security=reality&sni=addons.mozilla.org&fp=chrome&pbk=${REALITY_PUBLIC}&type=grpc&serviceName=grpc&encryption=none#${NODE_NAME}%20grpc-reality"

  echo -n "$NEKOBOX_SUBSCRIBE" | sed -E '/^[ ]*#|^--/d' | sed '/^$/d' | base64 -w0 > ${WORK_DIR}/subscribe/neko

  # 生成 Sing-box 订阅文件
  [ "${XTLS_REALITY}" = 'true' ] &&
  local INBOUND_REPLACE+=" { \"type\": \"vless\", \"tag\": \"${NODE_NAME} xtls-reality\", \"server\":\"${SERVER_IP}\", \"server_port\":${PORT_XTLS_REALITY}, \"uuid\":\"${UUID}\", \"flow\":\"\", \"tls\":{ \"enabled\":true, \"server_name\":\"addons.mozilla.org\", \"utls\":{ \"enabled\":true, \"fingerprint\":\"chrome\" }, \"reality\":{ \"enabled\":true, \"public_key\":\"${REALITY_PUBLIC}\", \"short_id\":\"\" } }, \"multiplex\": { \"enabled\": true, \"protocol\": \"h2mux\", \"max_connections\": 8, \"min_streams\": 16, \"padding\": true, \"brutal\":{ \"enabled\":true, \"up_mbps\":1000, \"down_mbps\":1000 } } }," &&
  local NODE_REPLACE+="\"${NODE_NAME} xtls-reality\","

  if [ "${HYSTERIA2}" = 'true' ]; then
    local INBOUND_REPLACE+=" { \"type\": \"hysteria2\", \"tag\": \"${NODE_NAME} hysteria2\", \"server\": \"${SERVER_IP}\", \"server_port\": ${PORT_HYSTERIA2},"
    [[ -n "${PORT_HOPPING_START}" && -n "${PORT_HOPPING_END}" ]] && local INBOUND_REPLACE+=" \"server_ports\": [ \"${PORT_HOPPING_START}:${PORT_HOPPING_END}\" ],"
    local INBOUND_REPLACE+=" \"up_mbps\": 200, \"down_mbps\": 1000, \"password\": \"${UUID}\", \"tls\": { \"enabled\": true, \"insecure\": true, \"server_name\": \"\", \"alpn\": [ \"h3\" ] } },"
    local NODE_REPLACE+="\"${NODE_NAME} hysteria2\","
  fi

  [ "${TUIC}" = 'true' ] &&
  local INBOUND_REPLACE+=" { \"type\": \"tuic\", \"tag\": \"${NODE_NAME} tuic\", \"server\": \"${SERVER_IP}\", \"server_port\": ${PORT_TUIC}, \"uuid\": \"${UUID}\", \"password\": \"${UUID}\", \"congestion_control\": \"bbr\", \"udp_relay_mode\": \"native\", \"zero_rtt_handshake\": false, \"heartbeat\": \"10s\", \"tls\": { \"enabled\": true, \"insecure\": true, \"server_name\": \"\", \"alpn\": [ \"h3\" ] } }," &&
  local NODE_REPLACE+="\"${NODE_NAME} tuic\","

  [ "${SHADOWTLS}" = 'true' ] &&
  local INBOUND_REPLACE+=" { \"type\": \"shadowsocks\", \"tag\": \"${NODE_NAME} ShadowTLS\", \"method\": \"2022-blake3-aes-128-gcm\", \"password\": \"${SHADOWTLS_PASSWORD}\", \"detour\": \"shadowtls-out\", \"udp_over_tcp\": false, \"multiplex\": { \"enabled\": true, \"protocol\": \"h2mux\", \"max_connections\": 8, \"min_streams\": 16, \"padding\": true, \"brutal\":{ \"enabled\":true, \"up_mbps\":1000, \"down_mbps\":1000 } } }, { \"type\": \"shadowtls\", \"tag\": \"shadowtls-out\", \"server\": \"${SERVER_IP}\", \"server_port\": ${PORT_SHADOWTLS}, \"version\": 3, \"password\": \"${UUID}\", \"tls\": { \"enabled\": true, \"server_name\": \"addons.mozilla.org\", \"utls\": { \"enabled\": true, \"fingerprint\": \"chrome\" } } }," &&
  local NODE_REPLACE+="\"${NODE_NAME} ShadowTLS\","

  [ "${SHADOWSOCKS}" = 'true' ] &&
  local INBOUND_REPLACE+=" { \"type\": \"shadowsocks\", \"tag\": \"${NODE_NAME} shadowsocks\", \"server\": \"${SERVER_IP}\", \"server_port\": $PORT_SHADOWSOCKS, \"method\": \"aes-128-gcm\", \"password\": \"${UUID}\", \"multiplex\": { \"enabled\": true, \"protocol\": \"h2mux\", \"max_connections\": 8, \"min_streams\": 16, \"padding\": true, \"brutal\":{ \"enabled\":true, \"up_mbps\":1000, \"down_mbps\":1000 } } }," &&
  local NODE_REPLACE+="\"${NODE_NAME} shadowsocks\","

  [ "${TROJAN}" = 'true' ] &&
  local INBOUND_REPLACE+=" { \"type\": \"trojan\", \"tag\": \"${NODE_NAME} trojan\", \"server\": \"${SERVER_IP}\", \"server_port\": $PORT_TROJAN, \"password\": \"${UUID}\", \"tls\": { \"enabled\":true, \"insecure\": true, \"server_name\":\"\", \"utls\": { \"enabled\":true, \"fingerprint\":\"chrome\" } }, \"multiplex\": { \"enabled\":true, \"protocol\":\"h2mux\", \"max_connections\": 8, \"min_streams\": 16, \"padding\": true, \"brutal\":{ \"enabled\":true, \"up_mbps\":1000, \"down_mbps\":1000 } } }," &&
  local NODE_REPLACE+="\"${NODE_NAME} trojan\","

  [ "${VMESS_WS}" = 'true' ] &&
  local INBOUND_REPLACE+=" { \"type\": \"vmess\", \"tag\": \"${NODE_NAME} vmess-ws\", \"server\":\"${CDN}\", \"server_port\":80, \"uuid\": \"${UUID}\", \"security\": \"auto\", \"transport\": { \"type\":\"ws\", \"path\":\"/${UUID}-vmess\", \"headers\": { \"Host\": \"${ARGO_DOMAIN}\" } }, \"multiplex\": { \"enabled\":true, \"protocol\":\"h2mux\", \"max_streams\":16, \"padding\": true, \"brutal\":{ \"enabled\":true, \"up_mbps\":1000, \"down_mbps\":1000 } } }," && local NODE_REPLACE+="\"${NODE_NAME} vmess-ws\","

  [ "${VLESS_WS}" = 'true' ] &&
  local INBOUND_REPLACE+=" { \"type\": \"vless\", \"tag\": \"${NODE_NAME} vless-ws-tls\", \"server\":\"${CDN}\", \"server_port\":443, \"uuid\": \"${UUID}\", \"tls\": { \"enabled\":true, \"server_name\":\"${ARGO_DOMAIN}\", \"utls\": { \"enabled\":true, \"fingerprint\":\"chrome\" } }, \"transport\": { \"type\":\"ws\", \"path\":\"/${UUID}-vless\", \"headers\": { \"Host\": \"${ARGO_DOMAIN}\" }, \"max_early_data\":2048, \"early_data_header_name\":\"Sec-WebSocket-Protocol\" }, \"multiplex\": { \"enabled\":true, \"protocol\":\"h2mux\", \"max_streams\":16, \"padding\": true, \"brutal\":{ \"enabled\":true, \"up_mbps\":1000, \"down_mbps\":1000 } } }," &&
  local NODE_REPLACE+="\"${NODE_NAME} vless-ws-tls\","

  [ "${H2_REALITY}" = 'true' ] &&
  local INBOUND_REPLACE+=" { \"type\": \"vless\", \"tag\": \"${NODE_NAME} h2-reality\", \"server\": \"${SERVER_IP}\", \"server_port\": ${PORT_H2_REALITY}, \"uuid\":\"${UUID}\", \"tls\": { \"enabled\":true, \"server_name\":\"addons.mozilla.org\", \"utls\": { \"enabled\":true, \"fingerprint\":\"chrome\" }, \"reality\":{ \"enabled\":true, \"public_key\":\"${REALITY_PUBLIC}\", \"short_id\":\"\" } }, \"transport\": { \"type\": \"http\" } }," &&
  local NODE_REPLACE+="\"${NODE_NAME} h2-reality\","

  [ "${GRPC_REALITY}" = 'true' ] &&
  local INBOUND_REPLACE+=" { \"type\": \"vless\", \"tag\": \"${NODE_NAME} grpc-reality\", \"server\": \"${SERVER_IP}\", \"server_port\": ${PORT_GRPC_REALITY}, \"uuid\":\"${UUID}\", \"tls\": { \"enabled\":true, \"server_name\":\"addons.mozilla.org\", \"utls\": { \"enabled\":true, \"fingerprint\":\"chrome\" }, \"reality\":{ \"enabled\":true, \"public_key\":\"${REALITY_PUBLIC}\", \"short_id\":\"\" } }, \"transport\": { \"type\": \"grpc\", \"service_name\": \"grpc\" } }," &&
  local NODE_REPLACE+="\"${NODE_NAME} grpc-reality\","

  [ "${ANYTLS}" = 'true' ] &&
  local INBOUND_REPLACE+=" { \"type\": \"anytls\", \"tag\": \"${NODE_NAME} anytls\", \"server\": \"${SERVER_IP}\", \"server_port\": ${PORT_ANYTLS}, \"password\": \"${UUID}\", \"idle_session_check_interval\": \"30s\", \"idle_session_timeout\": \"30s\", \"min_idle_session\": 5, \"tls\": { \"enabled\": true, \"insecure\": true, \"server_name\": \"\" } }," &&
  local NODE_REPLACE+="\"${NODE_NAME} anytls\","

  # 模板
  local SING_BOX_JSON1=$(wget -qO- --tries=3 --timeout=2 ${SUBSCRIBE_TEMPLATE}/sing-box1)

  echo $SING_BOX_JSON1 | sed 's#, {[^}]\+"tun-in"[^}]\+}##' | sed "s#\"<INBOUND_REPLACE>\",#$INBOUND_REPLACE#; s#\"<NODE_REPLACE>\"#${NODE_REPLACE%,}#g" | ${WORK_DIR}/jq > ${WORK_DIR}/subscribe/sing-box-pc

  echo $SING_BOX_JSON1 | sed 's# {[^}]\+"mixed"[^}]\+},##; s#, "auto_detect_interface": true##' | sed "s#\"<INBOUND_REPLACE>\",#$INBOUND_REPLACE#; s#\"<NODE_REPLACE>\"#${NODE_REPLACE%,}#g" | ${WORK_DIR}/jq > ${WORK_DIR}/subscribe/sing-box-phone

  # 生成二维码 url 文件
  cat > ${WORK_DIR}/subscribe/qr << EOF
自适应 Clash / V2rayN / NekoBox / ShadowRocket / SFI / SFA / SFM 客户端:
模版:
https://${ARGO_DOMAIN}/${UUID}/auto

订阅 QRcode:
模版:
https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=https://${ARGO_DOMAIN}/${UUID}/auto

模版:
$(${WORK_DIR}/qrencode "https://${ARGO_DOMAIN}/${UUID}/auto")
EOF

  # 生成配置文件
  EXPORT_LIST_FILE="*******************************************
┌────────────────┐
│                │
│     $(warning "V2rayN")     │
│                │
└────────────────┘
$(info "${V2RAYN_SUBSCRIBE}")

*******************************************
┌────────────────┐
│                │
│  $(warning "ShadowRocket")  │
│                │
└────────────────┘
----------------------------
$(hint "${SHADOWROCKET_SUBSCRIBE}")

*******************************************
┌────────────────┐
│                │
│   $(warning "Clash Verge")  │
│                │
└────────────────┘
----------------------------

$(info "$(sed '1d' <<< "${CLASH_SUBSCRIBE}")")

*******************************************
┌────────────────┐
│                │
│    $(warning "NekoBox")     │
│                │
└────────────────┘
$(hint "${NEKOBOX_SUBSCRIBE}")

*******************************************
┌────────────────┐
│                │
│    $(warning "Sing-box")    │
│                │
└────────────────┘
----------------------------

$(info "$(echo "{ \"outbounds\":[ ${INBOUND_REPLACE%,} ] }" | ${WORK_DIR}/jq)

各客户端配置文件路径: ${WORK_DIR}/subscribe/\n 完整模板可参照:\n https://github.com/chika0801/sing-box-examples/tree/main/Tun")
"

EXPORT_LIST_FILE+="

*******************************************

$(hint "Index:
https://${ARGO_DOMAIN}/${UUID}/

QR code:
https://${ARGO_DOMAIN}/${UUID}/qr

V2rayN 订阅:
https://${ARGO_DOMAIN}/${UUID}/v2rayn")

$(hint "NekoBox 订阅:
https://${ARGO_DOMAIN}/${UUID}/neko")

$(hint "Clash 订阅:
https://${ARGO_DOMAIN}/${UUID}/clash

sing-box for pc 订阅:
https://${ARGO_DOMAIN}/${UUID}/sing-box-pc

sing-box for cellphone 订阅:
https://${ARGO_DOMAIN}/${UUID}/sing-box-phone

ShadowRocket 订阅:
https://${ARGO_DOMAIN}/${UUID}/shadowrocket")

*******************************************

$(info " 自适应 Clash / V2rayN / NekoBox / ShadowRocket / SFI / SFA / SFM 客户端:
模版:
https://${ARGO_DOMAIN}/${UUID}/auto

 订阅 QRcode:
模版:
https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=https://${ARGO_DOMAIN}/${UUID}/auto")

$(hint "模版:")
$(${WORK_DIR}/qrencode https://${ARGO_DOMAIN}/${UUID}/auto)
"

  # 生成并显示节点信息
  echo "$EXPORT_LIST_FILE" > ${WORK_DIR}/list
  cat ${WORK_DIR}/list

  # 显示部署完成信息
  hint "\n🎉========================================🎉\n"
  hint "┌─────────────────────────────────────────┐"
  hint "│       🌟 Sing-box 全家桶已部署成功!      │"
  hint "└─────────────────────────────────────────┘"
  hint "\n🎊========================================🎊\n"
}

# Sing-box 的最新版本
update_sing-box() {
  local ONLINE=$(check_latest_sing-box)
  
  # 检查是否能获取到版本信息
  if [ -z "$ONLINE" ]; then
    warning "获取不了在线版本，请稍后再试！"
    return 1
  fi
  
  # 检查当前版本
  local LOCAL=""
  if [ -f "${WORK_DIR}/sing-box" ]; then
    LOCAL=$(${WORK_DIR}/sing-box version 2>/dev/null | awk '/version/{print $NF}')
  fi
  
  info "本地版本: ${LOCAL:-'未安装'}, 在线版本: v${ONLINE}"
  
  if [[ "$ONLINE" != "$LOCAL" ]]; then
    info "开始更新 sing-box 到版本 v${ONLINE}..."
    
    # 停止当前服务
    supervisorctl stop sing-box >/dev/null 2>&1 || true
    
    # 备份当前版本
    [ -f "${WORK_DIR}/sing-box" ] && cp "${WORK_DIR}/sing-box" "${WORK_DIR}/sing-box.bak"
    
    # 下载新版本
    if wget --no-check-certificate --tries=3 --timeout=30 https://github.com/SagerNet/sing-box/releases/download/v$ONLINE/sing-box-$ONLINE-linux-$SING_BOX_ARCH.tar.gz -O- | tar xz -C ${WORK_DIR} sing-box-$ONLINE-linux-$SING_BOX_ARCH/sing-box; then
      mv ${WORK_DIR}/sing-box-$ONLINE-linux-$SING_BOX_ARCH/sing-box ${WORK_DIR}/sing-box
      rm -rf ${WORK_DIR}/sing-box-$ONLINE-linux-$SING_BOX_ARCH
      chmod +x ${WORK_DIR}/sing-box
      
      # 验证新版本
      if ${WORK_DIR}/sing-box version >/dev/null 2>&1; then
        # 重启服务
        supervisorctl start sing-box
        sleep 2
        
        # 检查服务状态
        if supervisorctl status sing-box | grep -q "RUNNING"; then
          rm -f "${WORK_DIR}/sing-box.bak" 2>/dev/null || true
          info "Sing-box v${ONLINE} 更新成功！"
        else
          warning "新版本启动失败，正在恢复旧版本..."
          [ -f "${WORK_DIR}/sing-box.bak" ] && mv "${WORK_DIR}/sing-box.bak" "${WORK_DIR}/sing-box"
          supervisorctl start sing-box
        fi
      else
        warning "新版本验证失败，正在恢复旧版本..."
        [ -f "${WORK_DIR}/sing-box.bak" ] && mv "${WORK_DIR}/sing-box.bak" "${WORK_DIR}/sing-box"
        supervisorctl start sing-box
      fi
    else
      warning "下载新版本失败！"
      [ -f "${WORK_DIR}/sing-box.bak" ] && rm -f "${WORK_DIR}/sing-box.bak"
      supervisorctl start sing-box
    fi
  else
    info "Sing-box v${ONLINE} 已是最新版本！"
  fi
}

# 传参
while getopts ":Vv" OPTNAME; do
  case "${OPTNAME,,}" in
    v ) ACTION=update
  esac
done

# 主流程
case "$ACTION" in
  update )
    update_sing-box
    ;;
  * )
    install
    
    # 验证配置文件是否生成成功
    if [ ! -f "/etc/supervisord.conf" ]; then
      warning "supervisord 配置文件不存在，安装失败"
      exit 1
    fi
    
    # 验证 sing-box 配置文件
    if [ ! -d "${WORK_DIR}/conf" ] || [ -z "$(ls -A ${WORK_DIR}/conf 2>/dev/null)" ]; then
      warning "sing-box 配置文件目录为空，请检查安装过程"
      exit 1
    fi
    
    info "正在启动 supervisord..."
    
    # 运行 supervisor 进程守护
    exec supervisord -c /etc/supervisord.conf
esac
