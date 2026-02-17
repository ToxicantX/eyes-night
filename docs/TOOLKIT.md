# 博客工具集说明（Toolkit）

这份文档用于避免“脚本越来越多后不知道做什么”。

## 目录约定

- 所有脚本统一放在：`scripts/`
- 所有工具说明统一放在：`docs/TOOLKIT.md`（本文件）

## 工具索引

### 1) 新建文章模板

- 脚本：`scripts/new-post.sh`
- 用途：按规范创建一篇新文章（含 frontmatter 与章节骨架）
- 用法：
  ```bash
  ./scripts/new-post.sh "文章标题" [tag1,tag2] [一句话摘要] [hero序号1-5]
  ```
- 示例：
  ```bash
  ./scripts/new-post.sh "我的第一篇 Astro 实战" "Astro,GitHub Pages" "一周博客搭建复盘" 3
  ```
- 能力增强：
  - 自动处理重名文件（会追加 `-2`、`-3`）
  - 可指定摘要与封面占位图
  - 自动输出下一步操作建议

### 2) 构建检查

- 脚本：`scripts/build-check.sh`
- 用途：执行依赖安装、`astro check`、`npm run build`
- 用法：
  ```bash
  ./scripts/build-check.sh
  ```

### 3) 链接检查（占位）

- 脚本：`scripts/link-check.sh`
- 用途：预留链接巡检入口（未来可接入 lychee）
- 用法：
  ```bash
  ./scripts/link-check.sh
  ```

### 4) 发布检查清单

- 脚本：`scripts/release-checklist.sh`
- 用途：发布前快速自检，避免漏项
- 用法：
  ```bash
  ./scripts/release-checklist.sh
  ```

### 5) 导入 AI 点子日报（7天保留）

- 脚本：`scripts/import-ai-ideas.sh`
- 用途：把 `../ai-ideas-bot/reports` 的最新日报导入博客文章，并自动清理超过 7 天的自动导入文章
- 用法：
  ```bash
  ./scripts/import-ai-ideas.sh
  ```
- 可选参数：
  ```bash
  ./scripts/import-ai-ideas.sh 7
  ```
  > `7` 是保留天数，默认就是 7 天

## NPM 快捷命令

已在 `package.json` 增加：

- `npm run new-post -- "标题" "标签1,标签2"`
- `npm run build-check`
- `npm run link-check`
- `npm run release-checklist`
- `npm run import-ai-ideas`

## 维护规则（建议）

1. 新增脚本时，必须同步更新本文件。
2. 脚本命名统一为动词短语：`xxx-check.sh` / `new-xxx.sh`。
3. 若脚本被废弃，先在本文件标记“已弃用”，下一次版本再删除。
