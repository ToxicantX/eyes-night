# 皮皮虾的博客（eyes-night）

一个部署在 **GitHub Pages** 的个人博客，基于 Astro + Tailwind，主要记录：

- AI 实践与自动化
- 技术开发与部署复盘
- 游戏体验与工具笔记

## 在线地址

- 站点首页：<https://toxicantx.github.io/eyes-night/>
- 仓库地址：<https://github.com/ToxicantX/eyes-night>

## 技术栈

- Astro 5
- Tailwind CSS
- Markdown / MDX
- GitHub Actions（构建 + 部署）

## 本地开发

```bash
# 安装依赖
npm ci

# 启动开发服务
npm run dev
```

默认访问：

- <http://127.0.0.1:4321/eyes-night/>

## 常用命令

```bash
# 构建
npm run build

# 本地预览构建产物
npm run preview

# 代码检查（Astro + ESLint + Prettier）
npm run check

# 自动修复（ESLint + Prettier）
npm run fix

# 新建文章脚本
npm run new-post
```

## 目录结构（核心）

```text
src/
  data/post/           # 博客文章（.md / .mdx）
  pages/               # 页面与路由
  components/          # 组件
  config.yaml          # 站点配置（标题、域名、base、SEO 等）
.github/workflows/
  actions.yaml         # CI 检查（build/check）
  deploy.yml           # 部署到 GitHub Pages
```

## 内容发布流程

1. 在 `src/data/post/` 新增或修改文章
2. 本地检查：`npm run check`
3. 提交并推送到 `main`
4. GitHub Actions 自动构建并部署到 Pages

## GitHub Pages 关键配置

本项目为仓库子路径部署，已设置：

- `src/config.yaml`
  - `site: https://toxicantx.github.io`
  - `base: /eyes-night/`
  - `trailingSlash: true`

如果仓库名或域名变更，请同步修改上述配置。

## 已知约定

- 分类与标签链接统一通过 `getPermalink(...)` 生成，避免硬编码路径。
- 分页链接直接使用 Astro `page.url.prev/next`，避免重复拼接 base。

## License

MIT（继承上游模板许可）。
