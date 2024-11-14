#!/bin/bash

# 清理屏幕
clear

# 获取终端窗口大小
WINDOW_HEIGHT=$(tput lines)
WINDOW_WIDTH=$(tput cols)

# 创建消息队列数组
declare -a MESSAGE_QUEUE
MAX_MESSAGES=$((WINDOW_HEIGHT - 3))  # 保留顶部进度条和一行空行

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 显示进度条函数
show_progress() {
    local current=$1
    local total=$2
    local status=$3
    local percent=$((current * 100 / total))
    
    # 移动到顶部显示进度条
    tput cup 0 0
    
    # 创建自定义进度条
    local progress_width=50
    local completed=$((current * progress_width / total))
    local remaining=$((progress_width - completed))
    
    printf "(%d/%d) [" "$current" "$total"
    printf "%${completed}s" | tr ' ' '#'
    printf "%${remaining}s" | tr ' ' '-'
    printf "] %.1f%%" "$percent"
    echo -e " ${CYAN}${status}${NC}"
}

# 消息输出函数
write_message() {
    local message=$1
    local color=$2
    
    # 添加新消息到队列开头
    MESSAGE_QUEUE=("$color$message$NC" "${MESSAGE_QUEUE[@]}")
    
    # 保持队列大小不超过最大显示行数
    while [ ${#MESSAGE_QUEUE[@]} -gt $MAX_MESSAGES ]; do
        unset 'MESSAGE_QUEUE[${#MESSAGE_QUEUE[@]}-1]'
    done
    
    # 清除消息显示区域（从第2行开始）
    tput cup 2 0
    for ((i=2; i<WINDOW_HEIGHT; i++)); do
        printf "%${WINDOW_WIDTH}s" " "
        tput cup $i 0
    done
    
    # 重置光标位置到第2行
    tput cup 2 0
    
    # 从上往下显示消息
    for ((i=${#MESSAGE_QUEUE[@]}-1; i>=0; i--)); do
        echo -e "${MESSAGE_QUEUE[i]}"
    done
}

# 检查包版本函数
check_package_version() {
    local package_name=$1
    local version=$2
    
    if npm list "$package_name" 2>/dev/null | grep -q "@$version"; then
        return 0
    fi
    return 1
}

# 安装 npm 包函数
install_npm_package() {
    local package_name=$1
    local type=$2
    local current=$3
    local total=$4
    
    # 解析包名和版本
    if [[ $package_name =~ ^(.+)@(.+)$ ]]; then
        local name=${BASH_REMATCH[1]}
        local version=${BASH_REMATCH[2]}
        
        # 检查是否已安装指定版本
        if check_package_version "$name" "$version"; then
            write_message "($current/$total) $name@$version already installed, skipping..." "$YELLOW"
            return
        fi
    fi
    
    local npm_args=(
        "--silent"
        "--no-fund"
        "--no-audit"
        "--no-progress"
        "--prefer-offline"
        "--legacy-peer-deps"
        "--no-package-lock"
        "--quiet"
        "--no-update-notifier"
    )
    
    if [ "$type" = "dev" ]; then
        npm install -D "$package_name" "${npm_args[@]}" 2>/dev/null
    else
        npm install "$package_name" "${npm_args[@]}" 2>/dev/null
    fi
}

write_message "开始环境配置..." "$BLUE"

# 检查是否安装了 Homebrew
if ! command -v brew &> /dev/null; then
    write_message "正在安装 Homebrew..." "$GREEN"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # 为 M1 Mac 添加 Homebrew 到 PATH
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    write_message "Homebrew 已安装" "$GREEN"
fi

# 检查是否安装了 Node.js
if ! command -v node &> /dev/null; then
    write_message "正在安装 Node.js..." "$GREEN"
    brew install node@18
    brew link node@18
else
    write_message "Node.js 已安装，版本：$(node -v)" "$GREEN"
fi

# 检查 Node.js 版本
NODE_VERSION=$(node -v)
write_message "当前 Node.js 版本: ${NODE_VERSION}" "$GREEN"

write_message "开始安装项目依赖..." "$BLUE"

# 创建 package.json（如果不存在）
if [ ! -f package.json ]; then
    write_message "初始化 package.json..." "$GREEN"
    npm init -y
fi

# 定义依赖数组
declare -a DEPENDENCIES=(
    # 核心依赖
    "next@14.0.3;"
    "react@18.2.0;"
    "react-dom@18.2.0;"
    # ... 其他依赖项
)

# 计算总安装数量
TOTAL_PACKAGES=${#DEPENDENCIES[@]}

# 安装依赖并显示进度
write_message "开始安装软件包..." "$BLUE"
for ((i=0; i<${#DEPENDENCIES[@]}; i++)); do
    IFS=';' read -r package_name type <<< "${DEPENDENCIES[i]}"
    progress=$((i + 1))
    percentage=$(bc <<< "scale=2; $progress * 100 / $TOTAL_PACKAGES")
    show_progress "$progress" "$TOTAL_PACKAGES" "Installing $package_name ($percentage%)"
    install_npm_package "$package_name" "$type" "$progress" "$TOTAL_PACKAGES"
done

# ... 其余配置文件创建部分保持不变 ...

write_message "安装完成！" "$BLUE"
write_message "您现在可以使用 'npm run dev' 启动开发环境了" "$GREEN" 