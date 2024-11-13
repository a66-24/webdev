#!/bin/bash

# 设置颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "${BLUE}开始环境配置...${NC}"

# 检查是否安装了 Homebrew
if ! command -v brew &> /dev/null; then
    echo "${GREEN}正在安装 Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # 为 M1 Mac 添加 Homebrew 到 PATH
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "${GREEN}Homebrew 已安装${NC}"
fi

# 检查是否安装了 Node.js
if ! command -v node &> /dev/null; then
    echo "${GREEN}正在安装 Node.js...${NC}"
    brew install node@18
    brew link node@18
else
    echo "${GREEN}Node.js 已安装，版本：$(node -v)${NC}"
fi

# 检查 Node.js 版本
NODE_VERSION=$(node -v)
echo "${GREEN}当前 Node.js 版本: ${NODE_VERSION}${NC}"

# 原有的安装脚本内容...
echo "${BLUE}开始安装项目依赖...${NC}"

# 确保使用最新的 npm
echo "${GREEN}安装 npm 9.x 版本...${NC}"
npm install -g npm@9.8.1

# 创建 package.json（如果不存在）
if [ ! -f package.json ]; then
    echo "${GREEN}初始化 package.json...${NC}"
    npm init -y
fi

# 安装核心依赖
echo "${GREEN}安装核心依赖...${NC}"
npm install react@18.2.0 react-dom@18.2.0 next@13.5.6
# 添加生产环境必需的依赖
npm install sharp@0.33.2  # 升级到最新的稳定版本，性能更好
npm install compression@1.7.4  # 这个版本稳定，无需更改
npm install cross-env@7.0.3  # 这个版本稳定，无需更改

# 安装 TypeScript 相关依赖
echo "${GREEN}安装 TypeScript 相关依赖...${NC}"
npm install -D typescript@5.3.3  # 升级到更稳定的版本
npm install -D @types/react@18.2.48  # 升级到与 React 18.2.0 完全匹配的版本
npm install -D @types/react-dom@18.2.18  # 升级到与 React DOM 匹配的版本
npm install -D @types/node@20.11.5  # 升级到更新的 LTS 版本

# 安装代码规范和格式化工具
echo "${GREEN}安装代码规范和格式化工具...${NC}"
npm install -D prettier@3.2.4  # 升级到最新稳定版
npm install -D eslint@8.56.0  # 升级到最新稳定版
npm install -D eslint-config-next@14.1.0  # 升级到与 Next.js 匹配的版本

# 安装国际化支持
echo "${GREEN}安装国际化支持...${NC}"
npm install next-i18next@15.2.0  # 升级到支持 Next.js 13+ 的版本
npm install react-i18next@14.0.1  # 升级到最新稳定版
npm install i18next@23.7.16  # 升级到最新稳定版

# 安装样式相关依赖
echo "${GREEN}安装样式相关依赖...${NC}"
npm install tailwindcss@3.4.1  # 升级到最新稳定版
npm install postcss@8.4.33  # 升级到最新稳定版
npm install autoprefixer@10.4.17  # 升级到最新稳定版
npm install -D sass@1.70.0  # 升级到最新稳定版

# 安装 SEO 相关依赖
echo "${GREEN}安装 SEO 相关依赖...${NC}"
npm install next-seo@6.4.0  # 升级到最新稳定版
npm install next-sitemap@4.2.3  # 保持当前版本，稳定性好
npm install schema-dts@1.1.2  # 保持当前版本，稳定性好
npm install next-pwa@5.6.0  # 保持当前版本，稳定性好

# 创建必要的配置文件
echo "${GREEN}创建配置文件...${NC}"

# 创建 .prettierrc
cat > .prettierrc << EOL
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5"
}
EOL

# 创建 .eslintrc.js
cat > .eslintrc.js << EOL
module.exports = {
  extends: ['next/core-web-vitals'],
  rules: {
    // 自定义规则
  }
};
EOL

# 更新 package.json 的 scripts
echo "${GREEN}更新 package.json 的 scripts...${NC}"
npm pkg set scripts.dev="next dev"
npm pkg set scripts.build="next build"
npm pkg set scripts.start="next start"
npm pkg set scripts.lint="next lint"
# 添加生产环境相关的脚本
npm pkg set scripts.analyze="cross-env ANALYZE=true next build"  # 分析打包大小
npm pkg set scripts."build:prod"="cross-env NODE_ENV=production next build"  # 生产环境构建
npm pkg set scripts."start:prod"="cross-env NODE_ENV=production next start"  # 生产环境启动
npm pkg set scripts.postbuild="next-sitemap"  # 构建后自动生成站点地图
npm pkg set scripts.prepare="husky install"
npm pkg set scripts."lint:security"="eslint . --config .eslintrc.security.js"
npm pkg set scripts."audit:deps"="npm audit --audit-level=moderate"

# 初始化 TypeScript 配置
echo "${GREEN}初始化 TypeScript 配置...${NC}"
npx tsc --init

# 初始化 Tailwind CSS
echo "${GREEN}初始化 Tailwind CSS...${NC}"
npx tailwindcss init -p

# 安装打包分析工具
echo "${GREEN}安装打包分析工具...${NC}"
npm install -D @next/bundle-analyzer@14.1.0  # 升级到与 Next.js 版本匹配的版本

# 创建 next.config.js 配置文件
echo "${GREEN}创建 next.config.js 配置文件...${NC}"
cat > next.config.js << EOL
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
})

const withPWA = require('next-pwa')({
  dest: 'public',
  disable: process.env.NODE_ENV === 'development',
  register: true,
})

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  compress: true,
  poweredByHeader: false,
  generateEtags: true,
  images: {
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
  },
  experimental: {
    optimizeCss: true,
  },
  // SEO 优化配置
  i18n: {
    locales: ['zh', 'en'],
    defaultLocale: 'zh',
    localeDetection: true,
  },
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-DNS-Prefetch-Control',
            value: 'on',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
          {
            key: 'X-Frame-Options',
            value: 'SAMEORIGIN',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
        ],
      },
    ]
  },
}

module.exports = withPWA(withBundleAnalyzer(nextConfig))
EOL

# 创建 next-sitemap.config.js
echo "${GREEN}创建 next-sitemap 配置文件...${NC}"
cat > next-sitemap.config.js << EOL
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
  exclude: ['/server-sitemap.xml'], // 排除动态站点地图
}
EOL

# 创建基础 SEO 组件示例
echo "${GREEN}创建基础 SEO 组件...${NC}"
mkdir -p components
cat > components/SEO.tsx << EOL
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
  title = '网站标题', 
  description = '网站描述',
  canonical,
  openGraph 
}: SEOProps) {
  const router = useRouter();
  const defaultCanonical = \`\${process.env.NEXT_PUBLIC_SITE_URL}\${router.asPath}\`;

  return (
    <NextSeo
      title={title}
      description={description}
      canonical={canonical || defaultCanonical}
      openGraph={{
        type: 'website',
        locale: 'zh_CN',
        url: canonical || defaultCanonical,
        site_name: '网站名称',
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
EOL

# 安装代码安全审核工具
echo "${GREEN}安装代码安全审核工具...${NC}"
npm install -D @typescript-eslint/parser@6.19.0  # TypeScript 解析器
npm install -D @typescript-eslint/eslint-plugin@6.19.0  # TypeScript ESLint 插件
npm install -D eslint-plugin-security@1.7.1  # 安全规则插件
npm install -D eslint-plugin-sonarjs@0.23.0  # SonarJS 规则
npm install -D eslint-plugin-promise@6.1.1  # Promise 最佳实践
npm install -D husky@8.0.3  # Git hooks 工具
npm install -D lint-staged@15.2.0  # 暂存文件 lint 工具
npm install -D @commitlint/cli@18.4.4  # Commit 消息 lint 工具
npm install -D @commitlint/config-conventional@18.4.4  # Commit 消息规范

# 创建 .eslintrc.security.js
echo "${GREEN}创建安全审核 ESLint 配置...${NC}"
cat > .eslintrc.security.js << EOL
module.exports = {
  parser: '@typescript-eslint/parser',
  plugins: ['security', 'sonarjs', '@typescript-eslint', 'promise'],
  extends: [
    'plugin:security/recommended',
    'plugin:sonarjs/recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:promise/recommended'
  ],
  rules: {
    'security/detect-object-injection': 'error',
    'security/detect-non-literal-regexp': 'error',
    'security/detect-unsafe-regex': 'error',
    'security/detect-buffer-noassert': 'error',
    'security/detect-eval-with-expression': 'error',
    'security/detect-no-csrf-before-method-override': 'error',
    'security/detect-possible-timing-attacks': 'error',
    'security/detect-pseudoRandomBytes': 'error',
    'sonarjs/cognitive-complexity': ['error', 15],
    'sonarjs/no-duplicate-string': 'error',
    'sonarjs/no-redundant-jump': 'error',
    '@typescript-eslint/no-explicit-any': 'error',
    '@typescript-eslint/explicit-function-return-type': 'warn'
  }
};
EOL

# 创建 commitlint 配置
echo "${GREEN}创建 commitlint 配置...${NC}"
cat > .commitlintrc.json << EOL
{
  "extends": ["@commitlint/config-conventional"]
}
EOL

# 创建 lint-staged 配置
echo "${GREEN}创建 lint-staged 配置...${NC}"
cat > .lintstagedrc << EOL
{
  "*.{js,jsx,ts,tsx}": [
    "eslint --fix",
    "eslint --config .eslintrc.security.js"
  ],
  "*.{json,md}": "prettier --write"
}
EOL

# 初始化 husky
echo "${GREEN}初始化 husky...${NC}"
npm run prepare
npx husky add .husky/pre-commit "npx lint-staged"
npx husky add .husky/commit-msg "npx --no -- commitlint --edit \$1"

# 创建 .npmrc 配置文件以增加安全性
echo "${GREEN}创建 .npmrc 配置文件...${NC}"
cat > .npmrc << EOL
audit=true
fund=false
package-lock=true
save-exact=true
EOL

# 创建 .npmignore 文件
echo "${GREEN}创建 .npmignore 文件...${NC}"
cat > .npmignore << EOL
.git
.gitignore
.env*
.eslintrc*
.prettier*
.husky
tests
coverage
docs
*.log
*.test.*
EOL

# 安装代码优化工具
echo "${GREEN}安装代码优化工具...${NC}"
npm install -D terser@5.27.0  # JS 压缩工具
npm install -D cssnano@6.0.3  # CSS 压缩工具
npm install -D @swc/core@1.3.105  # 快速编译工具
npm install -D @swc/cli@0.1.65  # SWC CLI
npm install -D webpack-bundle-analyzer@4.10.1  # 包分析工具
npm install -D cross-env@7.0.3  # 跨平台环境变量
npm install -D compression-webpack-plugin@10.0.0  # Webpack 压缩插件
npm install -D critters@0.0.20  # 关键 CSS 内联工具
npm install -D image-minimizer-webpack-plugin@3.8.3  # 图片优化
npm install -D imagemin@8.0.1  # 图片压缩
npm install -D imagemin-mozjpeg@10.0.0  # JPEG 优化
npm install -D imagemin-pngquant@9.0.2  # PNG 优化
npm install -D imagemin-svgo@10.0.1  # SVG 优化

# 更新 package.json scripts
echo "${GREEN}更新性能优化相关脚本...${NC}"
npm pkg set scripts."build:analyze"="cross-env ANALYZE=true next build"
npm pkg set scripts."build:profile"="cross-env NODE_ENV=production next build --profile"
npm pkg set scripts."lighthouse"="lighthouse http://localhost:3000 --view"
npm pkg set scripts."analyze:bundle"="webpack-bundle-analyzer .next/stats.json"

# 创建 next.config.js 的优化配置
cat > next.config.js << EOL
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
})

const withPWA = require('next-pwa')({
  dest: 'public',
  disable: process.env.NODE_ENV === 'development',
  register: true,
})

const CompressionPlugin = require('compression-webpack-plugin')
const ImageMinimizerPlugin = require('image-minimizer-webpack-plugin')

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  compress: true,
  poweredByHeader: false,
  generateEtags: true,
  
  // 图片优化配置
  images: {
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    minimumCacheTTL: 60,
  },
  
  // 实验性功能
  experimental: {
    optimizeCss: true,  // 优化 CSS
    optimizeImages: true,  // 优化图片
    scrollRestoration: true,  // 滚动位置恢复
    legacyBrowsers: false,  // 禁用旧浏览器支持
    browsersListForSwc: true,  // 使用 browserslist 配置
    swcMinify: true,  // 使用 SWC 压缩
  },
  
  // Webpack 配置
  webpack: (config, { dev, isServer }) => {
    // 生产环境优化
    if (!dev && !isServer) {
      // 启用 Gzip 压缩
      config.plugins.push(
        new CompressionPlugin({
          algorithm: 'gzip',
          test: /\.(js|css|html|svg)$/,
          threshold: 10240,
          minRatio: 0.8,
        })
      )
      
      // 图片优化
      config.plugins.push(
        new ImageMinimizerPlugin({
          minimizer: {
            implementation: ImageMinimizerPlugin.imageminMinify,
            options: {
              plugins: [
                ['mozjpeg', { quality: 80 }],
                ['pngquant', { quality: [0.6, 0.8] }],
                ['svgo', {
                  plugins: [
                    { name: 'removeViewBox', active: false },
                    { name: 'removeEmptyAttrs', active: false },
                  ],
                }],
              ],
            },
          },
        })
      )
    }
    
    return config
  },
  
  // 自定义 headers
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-DNS-Prefetch-Control',
            value: 'on',
          },
          {
            key: 'Cache-Control',
            value: 'public, max-age=31536000, immutable',
          },
        ],
      },
      {
        source: '/api/:path*',
        headers: [
          { key: 'Access-Control-Allow-Credentials', value: 'true' },
          { key: 'Access-Control-Allow-Origin', value: '*' },
          { key: 'Access-Control-Allow-Methods', value: 'GET,POST,PUT,DELETE,OPTIONS' },
          { key: 'Access-Control-Allow-Headers', value: 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version' },
        ]
      }
    ]
  },
}

module.exports = withPWA(withBundleAnalyzer(nextConfig))
EOL

# 创建 postcss.config.js 优化配置
cat > postcss.config.js << EOL
module.exports = {
  plugins: {
    'tailwindcss': {},
    'autoprefixer': {},
    'cssnano': process.env.NODE_ENV === 'production' ? {
      preset: ['advanced', {
        discardComments: { removeAll: true },
        reduceIdents: false,
        zindex: false,
      }],
    } : false,
  },
}
EOL

# 创建 browserslist 配置
echo "${GREEN}创建 browserslist 配置...${NC}"
cat > .browserslistrc << EOL
# 现代浏览器
last 2 versions
> 0.5%
not dead
not IE 11
EOL

# 创建 tsconfig.json 优化配置
cat > tsconfig.json << EOL
{
  "compilerOptions": {
    "target": "es2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    },
    "plugins": [
      {
        "name": "next"
      }
    ]
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOL

# 在所有安装和配置完成后，添加 NGINX 配置生成部分
echo "${GREEN}创建 NGINX 配置文件...${NC}"
mkdir -p nginx/certs

# 创建 NGINX 配置文件
cat > nginx/nginx.conf << EOL
server {
    listen 80;
    server_name www.szusih.com szusih.com localhost;
    
    # 启用 HTTP 重定向到 HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    server_name www.szusih.com szusih.com;

    # SSL 证书路径
    ssl_certificate     /etc/nginx/certs/szusih.com_cert.pem;
    ssl_certificate_key /etc/nginx/certs/szusih.com_key.pem;
    
    # SSL 配置
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers        HIGH:!aNULL:!MD5;

    # 静态资源路径
    location /assets/ {
        alias /usr/share/nginx/html/assets/;
        expires 1d;
        add_header Cache-Control "public, no-transform";
    }

    # Next.js 静态文件路径
    location /_next/static/ {
        alias /usr/share/nginx/html/_next/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Next.js 公共文件
    location /public/ {
        alias /usr/share/nginx/html/public/;
        expires 1d;
        add_header Cache-Control "public, no-transform";
    }

    # 根路径配置
    location / {
        root /usr/share/nginx/html;
        try_files \$uri \$uri/ /index.html;
        index index.html;
        
        # HTML 文件缓存控制
        location ~* \.html$ {
            expires 30m;
            add_header Cache-Control "no-cache, must-revalidate";
        }
    }

    # 安全相关头部
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # 开启 gzip 压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1k;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript;

    # 错误页面配置
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
    
    # 图片缓存
    location ~* \.(jpg|jpeg|png|gif|ico)$ {
        root /usr/share/nginx/html;
        expires 1d;
        add_header Cache-Control "public, no-transform";
    }

    # JS/CSS 文件缓存
    location ~* \.(js|css)$ {
        expires 1d;
        add_header Cache-Control "public, no-transform";
    }

    # 字体文件缓存
    location ~* \.(woff|woff2|ttf|eot)$ {
        expires 7d;
        add_header Cache-Control "public, no-transform";
    }
}
EOL

# 创建 Dockerfile for NGINX
echo "${GREEN}创建 NGINX Dockerfile...${NC}"
cat > nginx/Dockerfile << EOL
FROM nginx:alpine

# 删除默认配置
RUN rm -rf /etc/nginx/conf.d/*

# 复制配置文件
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 创建证书目录
RUN mkdir -p /etc/nginx/certs

# 创建静态文件目录
RUN mkdir -p /usr/share/nginx/html

# 复制构建后的文件
COPY ../.next/static /usr/share/nginx/html/_next/static
COPY ../public /usr/share/nginx/html/public
COPY ../out /usr/share/nginx/html

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
EOL

# 创建 docker-compose 文件
echo "${GREEN}创建 docker-compose.yml...${NC}"
cat > docker-compose.yml << EOL
version: '3.8'

services:
  nginx:
    build:
      context: .
      dockerfile: nginx/Dockerfile
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/certs:/etc/nginx/certs:ro
    restart: always
EOL

# 更新 package.json scripts 添加 NGINX 相关命令
npm pkg set scripts."build:prod"="next build && next export && docker-compose build"
npm pkg set scripts."start:prod"="docker-compose up -d"
npm pkg set scripts."stop:prod"="docker-compose down"

echo "${BLUE}NGINX 配置文件生成完成！${NC}"
echo "${GREEN}您可以使用以下命令来构建和运行生产环境：${NC}"
echo "${GREEN}1. npm run build:prod  # 构建项目并创建 Docker 镜像${NC}"
echo "${GREEN}2. npm run start:prod  # 启动 NGINX 服务${NC}"
echo "${GREEN}3. npm run stop:prod   # 停止 NGINX 服务${NC}"
echo "${RED}注意：请确保将 SSL 证书文件放置在 nginx/certs 目录下：${NC}"
echo "${RED}- szusih.com_cert.pem${NC}"
echo "${RED}- szusih.com_key.pem${NC}"

echo "${BLUE}全部安装完成！${NC}"
echo "${GREEN}您现在可以使用 'npm run dev' 启动开发环境了${NC}" 