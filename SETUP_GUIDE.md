# Next.js 项目环境配置脚本说明

这是一个用于 Windows 环境下快速配置 Next.js 项目开发环境的 PowerShell 脚本。该脚本自动化了项目初始化、依赖安装和配置文件创建的过程。

## 功能特性

### 1. 环境检查与安装
- 自动检测并安装 Node.js LTS 版本
- 自动更新 npm 到 9.8.1 版本
- 自动刷新环境变量

### 2. 核心依赖安装
- **Next.js 框架**: v13.5.6
- **React**: v18.2.0
- **性能优化工具**:
  - sharp: v0.32.6 (图片优化)
  - compression: v1.7.4 (压缩)
  - cross-env: v7.0.3 (跨平台环境变量)

### 3. 开发工具集成
- **TypeScript 支持**: v5.0.4
- **代码质量工具**:
  - ESLint: v8.45.0
  - Prettier: v2.8.8
- **样式工具**:
  - TailwindCSS: v3.3.3
  - PostCSS: v8.4.27
  - Sass: v1.64.1

### 4. 功能扩展
- **国际化支持**:
  - next-i18next: v13.3.0
  - react-i18next: v13.2.2
  - i18next: v23.4.4
- **SEO 优化**:
  - next-seo: v6.1.0
  - next-sitemap: v4.1.8
  - next-pwa: v5.6.0

### 5. 自动配置文件生成
- `.prettierrc`: 代码格式化配置
- `.eslintrc.js`: 代码质量检查配置
- `next.config.js`: Next.js 项目配置
- `tsconfig.json`: TypeScript 配置
- `tailwind.config.js`: TailwindCSS 配置

## 使用方法

1. **前置条件**
   - Windows 10/11 操作系统
   - PowerShell 5.0 或更高版本
   - 已安装 winget 包管理器

2. **运行脚本**
   ```powershell
   # 以管理员权限运行 PowerShell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ./setup.ps1
   ```

3. **验证安装**
   ```powershell
   # 检查 Node.js 版本
   node -v
   
   # 检查 npm 版本
   npm -v
   
   # 启动开发服务器
   npm run dev
   ```

## 项目脚本命令

脚本自动配置了以下 npm 命令：

### 开发相关命令
```json
{
  "dev": "next dev",                    // 启动开发服务器
  "build": "next build",                // 构建项目
  "start": "next start",                // 启动生产服务器
  "lint": "next lint"                   // 运行 ESLint 检查
}
```

### 生产环境命令
```json
{
  "build:prod": "cross-env NODE_ENV=production next build",  // 生产环境构建
  "start:prod": "cross-env NODE_ENV=production next start",  // 生产环境启动
  "postbuild": "next-sitemap"                               // 构建后生成站点地图
}
```

### 代码质量和安全
```json
{
  "lint:security": "eslint . --config .eslintrc.security.js",  // 安全规则检查
  "audit:deps": "npm audit --audit-level=moderate",            // 依赖安全审计
  "prepare": "husky install"                                   // Git hooks 安装
}
```

### 性能分析命令
```json
{
  "analyze": "cross-env ANALYZE=true next build"  // 分析打包大小
}
```

## 命令使用说明

### 开发流程

1. **启动开发服务器**
   ```bash
   npm run dev
   ```
   - 启动本地开发服务器
   - 支持热更新
   - 默认端口 3000

2. **代码检查**
   ```bash
   npm run lint        # 常规代码检查
   npm run lint:security   # 安全规则检查
   ```
   - 检查代码质量和格式
   - 识别潜在的安全问题
   - 自动修复简单问题

3. **依赖审计**
   ```bash
   npm run audit:deps
   ```
   - 检查依赖包的安全漏洞
   - 生成安全报告
   - 提供修复建议

### 构建和部署

1. **开发环境构建**
   ```bash
   npm run build
   ```
   - 构建开发版本
   - 包含源码映射
   - 保留调试信息

2. **生产环境构建**
   ```bash
   npm run build:prod
   ```
   - 优化的生产构建
   - 代码压缩和混淆
   - 自动生成站点地图

3. **启动生产服务**
   ```bash
   npm run start:prod
   ```
   - 以生产模式启动
   - 优化的性能设置
   - 禁用开发工具

### 性能分析

1. **包大小分析**
   ```bash
   npm run analyze
   ```
   - 生成包大小报告
   - 可视化依赖关系
   - 识别大型依赖

## 最佳实践

1. **开发流程**
   - 始终在开发环境使用 `npm run dev`
   - 定期运行 `npm run lint` 和 `npm run lint:security`
   - 提交代码前确保通过所有检查

2. **构建流程**
   - 开发测试使用 `npm run build`
   - 生产部署使用 `npm run build:prod`
   - 定期运行 `npm run analyze` 检查包大小

3. **安全实践**
   - 定期运行 `npm run audit:deps`
   - 及时更新有安全隐患的依赖
   - 遵循安全规则检查建议

## 故障排除

1. **常见问题**
   - 如果 `dev` 命令报端口占用，可以使用 `next dev -p [端口号]`
   - 构建失败时，先检查 `node_modules` 是否完整
   - 类型错误优先使用 TypeScript 的错误提示

2. **性能问题**
   - 使用 `analyze` 命令识别大型依赖
   - 检查并优化图片和其他静态资源
   - 考虑启用增量静态再生成（ISR）

3. **依赖问题**
   - 运行 `npm clean-install` 重新安装依赖
   - 检查 package.json 中的版本兼容性
   - 保持依赖版本的稳定性