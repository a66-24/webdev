# Next.js 项目开发环境配置指南

一个集成了完整开发环境配置、代码质量控制、性能优化和生产环境部署方案的 Next.js 项目模板。

## 目录
- [环境要求](#环境要求)
- [快速开始](#快速开始)
- [开发指南](#开发指南)
- [生产环境部署](#生产环境部署)
- [性能优化](#性能优化)
- [安全措施](#安全措施)
- [常见问题](#常见问题)
- [贡献指南](#贡献指南)

## 环境要求

- macOS (支持 Intel 和 M1 芯片)
- Node.js 18+
- npm 9.x
- Homebrew
- Docker (用于生产环境部署)

## 快速开始

### 1. 环境初始化

<details>
<summary>Windows PowerShell</summary>

```powershell
# 下载并执行（单行命令）
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/a66-24/webdev.git/main/setup.ps1" -OutFile "setup.ps1"; Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force; .\setup.ps1
```
</details>

<details>
<summary>macOS/Linux</summary>

```bash
curl -o setup.sh https://raw.githubusercontent.com/a66-24/webdev/main/setup.sh && chmod +x setup.sh && ./setup.sh
```
</details>

### 2. 常用命令

<details>
<summary>开发环境命令</summary>

```bash
npm run dev      # 启动开发服务器
npm run build    # 构建项目
npm run start    # 启动本地预览
```
</details>

<details>
<summary>代码检查命令</summary>

```bash
npm run lint             # ESLint 检查
npm run lint:security    # 安全规则检查
npm run audit:deps       # 依赖安全审计
```
</details>

<details>
<summary>生产环境命令</summary>

```bash
npm run build:prod    # 生产环境构建（包含 Docker 构建）
npm run start:prod    # 启动生产服务（Docker）
npm run stop:prod     # 停止生产服务（Docker）
```
</details>

<details>
<summary>性能分析命令</summary>

```bash
npm run analyze          # 分析打包大小
npm run build:analyze    # 构建并分析
npm run build:profile    # 性能分析构建
npm run lighthouse       # 运行 Lighthouse 测试
npm run analyze:bundle   # Webpack 包分析
```
</details>

### 3. 项目结构

```
.
├── components/          # React 组件
├── pages/              # 页面文件
├── public/             # 静态资源
├── styles/             # 样式文件
├── lib/                # 工具函数
├── types/              # TypeScript 类型定义
├── nginx/              # NGINX 配置
│   ├── certs/          # SSL 证书
│   ├── Dockerfile      # NGINX Docker 配置
│   └── nginx.conf      # NGINX 配置文件
└── [配置文件...]       # 项目配置文件
```

### 4. 技术栈版本

<details>
<summary>核心依赖</summary>

- next: 13.5.6
- react: 18.2.0
- react-dom: 18.2.0
- typescript: 5.3.3
</details>

<details>
<summary>样式支持</summary>

- Tailwind CSS 3.4.1
- Sass 1.70.0
- PostCSS 8.4.33
- Autoprefixer 10.4.17
</details>

<details>
<summary>国际化支持</summary>

- next-i18next 15.2.0
- i18next 23.7.16
- react-i18next 14.0.1
</details>

<details>
<summary>SEO 优化</summary>

- next-seo 6.4.0
- next-sitemap 4.2.3
- schema-dts 1.1.2
- next-pwa 5.6.0
</details>

## 开发指南

### 1. 代码规范

- 使用 TypeScript 编写代码
- 遵循 ESLint 规则
- 使用 Prettier 格式化代码
- 遵循 Git 提交消息规范

### 2. 环境变量

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `NODE_ENV` | 环境标识 | development/production |
| `ANALYZE` | 是否开启打包分析 | true/false |
| `NEXT_PUBLIC_SITE_URL` | 网站 URL | https://example.com |
| `SITE_URL` | 站点地图 URL | https://example.com |

### 3. 基础组件开发

<details>
<summary>TypeScript React 组件示例</summary>

```tsx
interface Props {
  title: string;
  children: React.ReactNode;
}

const Component: React.FC<Props> = ({ title, children }) => {
  return (
    <div>
      <h1>{title}</h1>
      {children}
    </div>
  );
};
```
</details>

### 4. 国际化使用

<details>
<summary>基本用法示例</summary>

```tsx
import { useTranslation } from 'next-i18next';

export const Component: React.FC = () => {
  const { t } = useTranslation('common');
  return <h1>{t('title')}</h1>;
};
```
</details>

## 生产环境部署

### 1. SSL 证书配置

1. 将证书文件放入 `nginx/certs` 目录：
   - website.com_cert.pem
   - website.com_key.pem

### 2. 部署步骤

```bash
# 1. 构建生产环境
npm run build:prod

# 2. 启动服务
npm run start:prod

# 3. 停止服务
npm run stop:prod
```

### 3. NGINX 配置特性

- ✅ HTTP/2 支持
- ✅ 自动 HTTPS 重定向
- ✅ 静态资源缓存策略
- ✅ Gzip 压缩
- ✅ 安全头部配置

## 性能优化

### 1. 图片优化

```tsx
import Image from 'next/image';

// 自动优化示例
<Image
  src="/image.jpg"
  alt="Description"
  width={800}
  height={600}
  priority
/>
```

### 2. 代码分割

```tsx
// 动态导入示例
const Component = dynamic(() => import('../components/Component'), {
  loading: () => <Loading />
});
```

## 安全措施

### 主要特性

- ✅ 依赖安全审计
- ✅ 代码安全检查
- ✅ CSRF 保护
- ✅ XSS 防护
- ✅ 提交检查

## 常见问题

<details>
<summary>Node.js 版本不匹配？</summary>

使用 nvm 安装正确版本：
```bash
nvm install 18
```
</details>

<details>
<summary>构建失败？</summary>

1. 检查依赖版本
2. 验证配置文件
3. 清理缓存：`npm cache clean --force`
</details>

<details>
<summary>NGINX 配置不生效？</summary>

1. 检查证书路径
2. 验证文件权限
3. 检查日志：`docker logs nginx`
</details>

## 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 许可证

[MIT License](LICENSE)
