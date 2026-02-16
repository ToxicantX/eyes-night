#!/usr/bin/env bash
cat <<'EOF'
发布检查清单

[ ] npm run build 通过
[ ] npx astro check 通过
[ ] 新文章 frontmatter 字段完整（title/description/pubDate/tags）
[ ] 关键页面可访问（/ /blog /about /tags）
[ ] 评论区显示正常
[ ] git status 干净，无遗漏文件
[ ] 已 push 到 main，Actions 部署成功
EOF
