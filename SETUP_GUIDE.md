# Next.js 项目环境配置脚本说明

这是一个用于快速配置 Next.js 项目开发环境的 Shell 脚本。该脚本自动化了项目初始化、依赖安装和配置文件创建的过程。

## 功能特性

### 1. 环境检查与安装
- 自动检测并安装 Homebrew（MacOS）
- 自动检测并安装 Node.js 18.x LTS 版本
- 自动刷新环境变量

### 2. 核心依赖安装
- **Next.js**: v14.0.3
- **React**: v18.2.0
- **React DOM**: v18.2.0
- **TypeScript**: v5.3.3
- **Ant Design**: v5.12.2
- **Zustand**: v4.4.7（状态管理）

### 3. 开发工具集成
- **代码质量工具**:
  - ESLint: v8.55.0
  - Prettier: v3.1.1
- **样式工具**:
  - TailwindCSS: v3.3.6
  - PostCSS: v8.4.32
  - Sass: v1.69.5
  - Autoprefixer: v10.4.16

### 4. 工具库
- **Lodash**: v4.17.21
- **Axios**: v1.6.2
- **Day.js**: v1.11.10

### 5. 自动配置文件生成
- `tsconfig.json`: TypeScript 配置
- `tailwind.config.js`: TailwindCSS 配置
- `postcss.config.js`: PostCSS 配置
- `.eslintrc.json`: ESLint 配置
- `.prettierrc`: Prettier 配置

## 使用方法

1. **前置条件**
   - MacOS 操作系统
   - Terminal 终端

2. **运行脚本**
   ```bash
   # 添加执行权限
   chmod +x setup.sh
   
   # 运行脚本
   ./setup.sh
   ```

3. **验证安装**
   ```bash
   # 检查 Node.js 版本
   node -v
   
   # 启动开发服务器
   npm run dev
   ```

## 项目脚本命令

### 开发相关
```json
{
  "dev": "next dev",              // 启动开发服务器
  "build": "next build",          // 构建项目
  "start": "next start",          // 启动生产服务器
  "lint": "next lint",            // 运行 ESLint 检查
  "format": "prettier --write \"**/*.{js,jsx,ts,tsx,json,md}\"",  // 格式化代码
  "type-check": "tsc --noEmit"    // 类型检查
}
```

## 项目结构

```
.
├── src/
│   ├── app/
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── globals.css
│   └── ...
├── package.json
├── tsconfig.json
├── tailwind.config.js
├── postcss.config.js
├── .eslintrc.json
└── .prettierrc
```

## 最佳实践

1. **开发流程**
   - 使用 `npm run dev` 启动开发服务器
   - 提交代码前运行 `npm run lint` 和 `npm run format`
   - 定期运行 `npm run type-check` 检查类型错误

2. **代码规范**
   - 遵循 ESLint 规则
   - 使用 Prettier 格式化代码
   - 确保 TypeScript 类型完整性

3. **样式开发**
   - 优先使用 Tailwind CSS 类
   - 需要自定义样式时使用 SCSS
   - 遵循 Ant Design 设计规范

## 故障排除

1. **常见问题**
   - 如果安装失败，检查网络连接
   - 确保有足够的磁盘空间
   - 检查 Node.js 版本兼容性

2. **依赖问题**
   ```bash
   # 清理依赖缓存
   npm cache clean --force
   
   # 重新安装依赖
   rm -rf node_modules
   npm install
   ```

3. **权限问题**
   ```bash
   # 修复权限
   sudo chown -R $USER:$GROUP ~/.npm
   sudo chown -R $USER:$GROUP .
   ```