# 项目开发环境配置指南

本项目使用 Next.js 框架，集成了完整的开发环境配置、代码质量控制、性能优化和生产环境部署方案。

## 环境要求

- macOS (支持 Intel 和 M1 芯片)
- Node.js 18+
- npm 9.x
- Homebrew
- Docker (用于生产环境部署)

### 1. 环境初始化

windows powershell 环境：

```powershell
# 下载并执行（单行命令）
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/a66-24/webdev.git/main/setup.ps1" -OutFile "setup.ps1"; Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force; .\setup.ps1
```

macOS/Linux 环境:
```bash
curl -o setup.sh https://raw.githubusercontent.com/a66-24/webdev.git/main/setup.sh && chmod +x setup.sh && ./setup.sh
```


此脚本会自动：
- 安装/检查 前置
- 安装/检查 Node.js
- 配置项目依赖和工具
- 创建必要的配置文件
- 设置开发环境

### 2. 开发命令

开发环境
```bash
npm run dev # 启动开发服务器
npm run build # 构建项目
npm run start # 启动本地预览
```
代码检查
```bash
npm run lint # ESLint 检查
npm run lint:security # 安全规则检查
npm run audit:deps # 依赖安全审计
```
生产环境
```bash
npm run build:prod # 生产环境构建（包含 Docker 构建）
npm run start:prod # 启动生产服务（Docker）
npm run stop:prod # 停止生产服务（Docker）
```
性能分析
```bash
npm run analyze # 分析打包大小
npm run build:analyze # 构建并分析
npm run build:profile # 性能分析构建
npm run lighthouse # 运行 Lighthouse 测试
npm run analyze:bundle # Webpack 包分析
```

### 自动生成的配置文件

setup.sh 脚本会自动生成以下配置文件：

1. **代码格式和质量**
   - `.prettierrc` - Prettier 配置
   - `.eslintrc.js` - ESLint 基础配置
   - `.eslintrc.security.js` - 安全规则配置
   - `.lintstagedrc` - Git 提交前检查配置
   - `.commitlintrc.json` - 提交消息规范配置

2. **TypeScript 配置**
   - `tsconfig.json` - TypeScript 编译配置
   - `next-env.d.ts` - Next.js 类型声明

3. **构建和优化**
   - `next.config.js` - Next.js 配置（包含优化设置）
   - `postcss.config.js` - PostCSS 配置
   - `tailwind.config.js` - Tailwind CSS 配置
   - `.browserslistrc` - 浏览器兼容性配置

4. **SEO 和站点地图**
   - `next-sitemap.config.js` - 站点地图配置
   - `components/SEO.tsx` - SEO 组件

5. **包管理和安全**
   - `.npmrc` - npm 配置
   - `.npmignore` - npm 发布忽略文件

6. **Docker 和 NGINX**
   - `nginx/nginx.conf` - NGINX 配置
   - `nginx/Dockerfile` - NGINX Docker 配置
   - `docker-compose.yml` - Docker 编排配置

### 依赖版本说明

#### 核心依赖
- next: 13.5.6
- react: 18.2.0
- react-dom: 18.2.0
- typescript: 5.3.3

### 2. 样式支持
- Tailwind CSS 3.4.1
- Sass 1.70.0
- PostCSS 8.4.33
- Autoprefixer 10.4.17

### 3. 国际化支持
- next-i18next 15.2.0
- i18next 23.7.16
- react-i18next 14.0.1

### 4. SEO 优化
- next-seo 6.4.0
- next-sitemap 4.2.3
- schema-dts 1.1.2
- PWA 支持 (next-pwa 5.6.0)

### 5. 代码质量
- ESLint 8.56.0
- Prettier 3.2.4
- TypeScript 严格模式
- Husky 提交钩子
- Commitlint 提交消息规范

### 6. 安全特性
- ESLint 安全规则
- SonarJS 代码质量检查
- 依赖安全审计
- CSRF 保护
- XSS 防护

### 7. 性能优化
- 图片优化 (sharp)
- 代码压缩 (terser)
- CSS 优化 (cssnano)
- 打包分析
- 关键 CSS 提取

### 8. 生产环境部署
- NGINX 配置
- Docker 支持
- SSL 配置
- HTTP/2 支持
- Gzip 压缩

## 目录结构
```bash
.
├── components/ # React 组件
├── pages/ # 页面文件
├── public/ # 静态资源
├── styles/ # 样式文件
├── lib/ # 工具函数
├── types/ # TypeScript 类型定义
├── nginx/ # NGINX 配置
│ ├── certs/ # SSL 证书
│ ├── Dockerfile # NGINX Docker 配置
│ └── nginx.conf # NGINX 配置文件
├── .eslintrc.js # ESLint 配置
├── .eslintrc.security.js # 安全规则配置
├── .prettierrc # Prettier 配置
├── next.config.js # Next.js 配置
├── tsconfig.json # TypeScript 配置
├── postcss.config.js # PostCSS 配置
├── tailwind.config.js # Tailwind 配置
├── docker-compose.yml # Docker 编排配置
└── package.json # 项目配置
```



## 开发指南

### 1. 代码规范
- 使用 TypeScript 编写代码
- 遵循 ESLint 规则
- 使用 Prettier 格式化代码
- 遵循 Git 提交消息规范

### 环境变量

项目使用以下环境变量：
- `NODE_ENV`: 环境标识（development/production）
- `ANALYZE`: 是否开启打包分析
- `NEXT_PUBLIC_SITE_URL`: 网站 URL
- `SITE_URL`: 站点地图使用的 URL

### NGINX 配置说明

1. **SSL 证书要求**
   - 证书文件: `nginx/certs/website.com_cert.pem`
   - 密钥文件: `nginx/certs/website.com_key.pem`

2. **缓存策略**
   - HTML: 30分钟
   - JS/CSS: 1天
   - 图片: 1天
   - 字体: 7天
   - 静态资源: 1年

3. **安全特性**
   - HTTP 自动跳转 HTTPS
   - TLS 1.2/1.3 支持
   - XSS 保护
   - CSRF 保护
   - HSTS 支持

### 2. **基础组件开发**
   - 如何创建 TypeScript React 组件
   - 如何定义组件 Props 接口
   - 如何使用 FC (FunctionComponent) 类型


### 3. **国际化功能**
   - 如何使用 next-i18next
   - 如何获取翻译文本
   - 基本的翻译函数使用

### 4. **SEO 优化**
   - 如何使用预配置的 SEO 组件
   - 如何设置页面元数据
   - 如何优化搜索引擎展示


## 生产环境部署

### 1. SSL 证书配置
将 SSL 证书放入 `nginx/certs` 目录：
- website.com_cert.pem
- website.com_key.pem

### 2. 构建和部署
```bash
#构建生产环境
npm run build:prod
#启动服务
npm run start:prod
#停止服务
npm run stop:prod
```

### 3. NGINX 配置说明
- 支持 HTTP/2
- 自动 HTTP 到 HTTPS 重定向
- 静态资源缓存策略
- Gzip 压缩
- 安全头部配置

## 性能优化

### 1. 打包分析
```bash
npm run analyze
```

### 2. 图片优化
- 使用 next/image 组件
- 自动 WebP 转换
- 响应式图片

### 3. 代码分割
- 自动代码分割
- 动态导入
- 预加载关键资源

## 安全措施

### 1. 依赖审计
```bash
npm run audit:deps
```

### 2. 代码安全检查
```bash
npm run lint:security
```


### 3. 提交检查
- 预提交代码检查
- 提交消息验证
- 类型检查

## 常见问题

### 1. 环境配置
Q: Node.js 版本不匹配？
A: 使用 nvm 安装正确版本：`nvm install 18`

### 2. 构建问题
Q: 构建失败？
A: 检查依赖版本和配置文件

### 3. 部署问题
Q: NGINX 配置不生效？
A: 检查证书路径和权限

## 贡献指南

1. Fork 项目
2. 创建特性分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 许可证

[MIT License](LICENSE)