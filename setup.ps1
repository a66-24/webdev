# 在脚本开始时清理屏幕
Clear-Host

# 获取控制台窗口大小
$windowHeight = $host.UI.RawUI.WindowSize.Height
$windowWidth = $host.UI.RawUI.WindowSize.Width

# 创建一个消息队列来存储最近的消息
$messageQueue = New-Object System.Collections.ArrayList
$maxMessages = $windowHeight - 3  # 保留顶部进度条和一行空行

# 修改进度条函数，添加分数显示
function Show-Progress {
    param (
        [int]$Current,
        [int]$Total,
        [string]$Status
    )
    $percentComplete = ($Current / $Total) * 100
    
    # 移动到顶部显示进度条
    $host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0, 0
    
    # 创建自定义进度条
    $progressBarWidth = 50
    $completed = [math]::Round(($Current / $Total) * $progressBarWidth)
    $remaining = $progressBarWidth - $completed
    
    $progressBar = "($Current/$Total) [" + 
                  "#" * $completed + 
                  "-" * $remaining + 
                  "]" +
                  " {0:N1}%" -f $percentComplete
    
    Write-Host $progressBar -NoNewline
    Write-Host " $Status" -ForegroundColor Cyan
}

# 修改颜色输出函数，实现消息滚动并避免叠加
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    
    # 添加新消息到队列
    $messageQueue.Insert(0, @{Message = $Message; Color = $Color})
    
    # 保持队列大小不超过最大显示行数
    while ($messageQueue.Count -gt $maxMessages) {
        $messageQueue.RemoveAt($messageQueue.Count - 1)
    }
    
    # 清除消息显示区域（从第2行到倒数第1行）
    $host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0, 2
    for ($i = 2; $i -lt $windowHeight; $i++) {
        Write-Host (" " * $windowWidth)
    }
    
    # 重置光标位置到第2行
    $host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0, 2
    
    # 从上往下显示消息
    for ($i = $messageQueue.Count - 1; $i -ge 0; $i--) {
        $msg = $messageQueue[$i]
        Write-Host $msg.Message -ForegroundColor $msg.Color
    }
}

Write-ColorOutput "Starting environment setup..." "Blue"

# Check if Chocolatey is installed
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-ColorOutput "Installing Chocolatey..." "Green"
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
} else {
    Write-ColorOutput "Chocolatey is already installed" "Green"
}

# Check if Node.js is installed
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    Write-ColorOutput "Installing Node.js..." "Green"
    choco install nodejs-lts -y
    refreshenv
} else {
    Write-ColorOutput "Node.js is already installed, version: $(node -v)" "Green"
}

# Check Node.js version
$nodeVersion = node -v
Write-ColorOutput "Current Node.js version: $nodeVersion" "Green"

Write-ColorOutput "Starting dependency installation..." "Blue"

# Create package.json if it doesn't exist
if (!(Test-Path package.json)) {
    Write-ColorOutput "Initializing package.json..." "Green"
    npm init -y
}

# 添加版本检查函数
function Test-PackageVersion {
    param (
        [string]$PackageName,
        [string]$Version
    )
    
    try {
        $installedVersion = npm list $PackageName --depth=0 2>$null
        if ($installedVersion -match "$PackageName@$Version") {
            return $true
        }
    } catch {
        return $false
    }
    return $false
}

# 修改安装函数，添加序号显示
function Install-NpmPackage {
    param(
        [string]$PackageName,
        [string]$Type = "",
        [switch]$IgnoreErrors,
        [int]$Current,
        [int]$Total
    )
    
    # 解析包名和版本
    if ($PackageName -match "^(.+)@(.+)$") {
        $name = $matches[1]
        $version = $matches[2]
        
        # 检查是否已安装指定版本
        if (Test-PackageVersion $name $version) {
            Write-ColorOutput "($Current/$Total) $name@$version already installed, skipping..." "Yellow"
            return
        }
    }
    
    $npmArgs = @(
        "--silent",
        "--no-fund",
        "--no-audit",
        "--no-progress",
        "--prefer-offline",
        "--legacy-peer-deps",
        "--no-package-lock",
        "--quiet",
        "--no-update-notifier"
    )
    
    try {
        if ($Type -eq "dev") {
            $null = npm install -D $PackageName @npmArgs 2>&1
        } else {
            $null = npm install $PackageName @npmArgs 2>&1
        }
    } catch {
        Write-ColorOutput "($Current/$Total) Failed to install $PackageName" "Red"
        if (!$IgnoreErrors) {
            Write-ColorOutput $_.Exception.Message "Red"
        }
    }
}

# 创建完整的依赖列表
$dependencies = @(
    # 核心依赖
    @{ Name = "next@14.0.3"; Type = "" },
    @{ Name = "react@18.2.0"; Type = "" },
    @{ Name = "react-dom@18.2.0"; Type = "" },
    @{ Name = "sharp@0.33.2"; Type = "" },
    @{ Name = "compression@1.7.4"; Type = "" },
    @{ Name = "cross-env@7.0.3"; Type = "" },

    # TypeScript 相关依赖
    @{ Name = "typescript@5.3.3"; Type = "dev" },
    @{ Name = "@types/react@18.2.48"; Type = "dev" },
    @{ Name = "@types/react-dom@18.2.18"; Type = "dev" },
    @{ Name = "@types/node@20.11.5"; Type = "dev" },

    # ESLint 和 Prettier
    @{ Name = "prettier@3.2.4"; Type = "dev" },
    @{ Name = "eslint@8.56.0"; Type = "dev" },
    @{ Name = "@typescript-eslint/parser@6.19.0"; Type = "dev" },
    @{ Name = "@typescript-eslint/eslint-plugin@6.19.0"; Type = "dev" },
    @{ Name = "eslint-config-next@14.1.0"; Type = "dev" },

    # 代码质量工具
    @{ Name = "eslint-plugin-security@1.7.1"; Type = "dev" },
    @{ Name = "eslint-plugin-sonarjs@0.23.0"; Type = "dev" },
    @{ Name = "eslint-plugin-promise@6.1.1"; Type = "dev" },

    # Git hooks 相关
    @{ Name = "husky@8.0.3"; Type = "dev" },
    @{ Name = "lint-staged@15.2.0"; Type = "dev" },
    @{ Name = "@commitlint/cli@18.4.4"; Type = "dev" },
    @{ Name = "@commitlint/config-conventional@18.4.4"; Type = "dev" },

    # i18n 支持
    @{ Name = "next-i18next@15.2.0"; Type = "" },
    @{ Name = "react-i18next@14.0.1"; Type = "" },
    @{ Name = "i18next@23.7.16"; Type = "" },

    # 样式相关依赖
    @{ Name = "tailwindcss@3.4.1"; Type = "" },
    @{ Name = "postcss@8.4.33"; Type = "" },
    @{ Name = "autoprefixer@10.4.17"; Type = "" },
    @{ Name = "sass@1.70.0"; Type = "dev" },

    # SEO 相关依赖
    @{ Name = "next-seo@6.4.0"; Type = "" },
    @{ Name = "next-sitemap@4.2.3"; Type = "" },
    @{ Name = "schema-dts@1.1.2"; Type = "" },

    # PWA 支持
    @{ Name = "next-pwa@5.6.0"; Type = "dev" },

    # 分析工具
    @{ Name = "@next/bundle-analyzer@14.1.0"; Type = "dev" }
)

# 计算总安装数量
$totalPackages = $dependencies.Count

# 安装依赖并显示进度
Write-ColorOutput "Starting package installation..." "Blue"
for ($i = 0; $i -lt $dependencies.Count; $i++) {
    $dep = $dependencies[$i]
    $progress = $i + 1
    $percentage = [math]::Round(($progress / $totalPackages) * 100, 2)
    Show-Progress -Current $progress -Total $totalPackages -Status "Installing $($dep.Name) ($percentage%)"
    Install-NpmPackage -PackageName $dep.Name -Type $dep.Type -IgnoreErrors -Current $progress -Total $totalPackages
}

# 完成进度条
Write-Progress -Activity "Installing Dependencies" -Completed
Write-ColorOutput "Package installation completed!" "Green"

# 直接跳到配置文件创建部分
Write-ColorOutput "Creating configuration files..." "Green"

# Create .prettierrc
@'
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5"
}
'@ | Out-File -FilePath .prettierrc -Encoding UTF8

# Create .eslintrc.js
@'
module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint'],
  extends: [
    'next/core-web-vitals',
    'plugin:@typescript-eslint/recommended',
  ],
  rules: {
    '@typescript-eslint/no-unused-vars': ['error'],
    '@typescript-eslint/no-explicit-any': 'error',
    '@typescript-eslint/explicit-function-return-type': 'warn'
  }
};
'@ | Out-File -FilePath .eslintrc.js -Encoding UTF8

# Update package.json scripts
Write-ColorOutput "Updating package.json scripts..." "Green"
npm pkg set scripts.dev="next dev"
npm pkg set scripts.build="next build"
npm pkg set scripts.start="next start"
npm pkg set scripts.lint="eslint . --ext .ts,.tsx"
npm pkg set scripts."lint:fix"="eslint . --ext .ts,.tsx --fix"
npm pkg set scripts.analyze="cross-env ANALYZE=true next build"
npm pkg set scripts."build:prod"="cross-env NODE_ENV=production next build"
npm pkg set scripts."start:prod"="cross-env NODE_ENV=production next start"
npm pkg set scripts.postbuild="next-sitemap"
npm pkg set scripts.prepare="husky install"
npm pkg set scripts."lint:security"="eslint . --config .eslintrc.security.js"
npm pkg set scripts."audit:deps"="npm audit --audit-level=moderate"

# Initialize TypeScript
Write-ColorOutput "Initializing TypeScript configuration..." "Green"
npx tsc --init

# Initialize Tailwind CSS
Write-ColorOutput "Initializing Tailwind CSS..." "Green"
npx tailwindcss init -p

# Create next-sitemap.config.js
@'
/** @type {import('next-sitemap').IConfig} */
module.exports = {
  siteUrl: process.env.SITE_URL || 'https://example.com',
  generateRobotsTxt: true,
  generateIndexSitemap: false,
  robotsTxtOptions: {
    policies: [
      {
        userAgent: '*',
        allow: '/',
      },
    ],
  },
  exclude: ['/server-sitemap.xml'],
}
'@ | Out-File -FilePath next-sitemap.config.js -Encoding UTF8

# Create SEO component
if (!(Test-Path components)) {
    New-Item -ItemType Directory -Path components
}

# Create SEO component file
@'
import { NextSeo } from 'next-seo';
import { useRouter } from 'next/router';

interface SEOProps {
  title?: string;
  description?: string;
  canonical?: string;
  openGraph?: {
    title?: string;
    description?: string;
    images?: Array<{ url: string; alt: string }>;
  };
}

export default function SEO({ 
  title = 'Website Title', 
  description = 'Website Description',
  canonical,
  openGraph 
}: SEOProps) {
  const router = useRouter();
  const defaultCanonical = `${process.env.NEXT_PUBLIC_SITE_URL}${router.asPath}`;

  return (
    <NextSeo
      title={title}
      description={description}
      canonical={canonical || defaultCanonical}
      openGraph={{
        type: 'website',
        locale: 'en_US',
        url: canonical || defaultCanonical,
        site_name: 'Website Name',
        ...openGraph,
      }}
      twitter={{
        handle: '@handle',
        site: '@site',
        cardType: 'summary_large_image',
      }}
      additionalMetaTags={[
        {
          name: 'viewport',
          content: 'width=device-width, initial-scale=1',
        },
      ]}
    />
  );
}
'@ | Out-File -FilePath "components/SEO.tsx" -Encoding UTF8

# Initialize husky
Write-ColorOutput "Setting up husky..." "Green"
git init
npm install -D husky@latest
npm pkg set scripts.prepare="husky install"
npm run prepare

# Ensure .husky directory exists before adding hooks
if (Test-Path .husky) {
    npx husky add .husky/pre-commit "npx lint-staged"
    npx husky add .husky/commit-msg "npx --no -- commitlint --edit \$1"
} else {
    Write-ColorOutput "Failed to create husky hooks. Please run 'npx husky install' manually." "Red"
}

# Create .npmrc file
@'
legacy-peer-deps=true
strict-peer-dependencies=false
loglevel=error
fund=false
audit=false
save-exact=true
prefer-offline=true
progress=false
update-notifier=false
git-tag-version=false
'@ | Out-File -FilePath .npmrc -Encoding UTF8

Write-ColorOutput "Installation complete!" "Blue"
Write-ColorOutput "You can now start the development server with 'npm run dev'" "Green" 