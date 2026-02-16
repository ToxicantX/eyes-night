#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "用法: ./scripts/new-post.sh \"文章标题\" [tag1,tag2]"
  exit 1
fi

TITLE="$1"
TAGS_RAW="${2:-博客搭建}"
DATE_HUMAN="$(date '+%b %d %Y')"
DATE_PREFIX="$(date '+%Y-%m-%d')"

slugify() {
  local s="$1"
  s="$(echo "$s" | tr '[:upper:]' '[:lower:]')"
  s="$(echo "$s" | sed -E 's/[^a-z0-9\u4e00-\u9fa5]+/-/g; s/^-+|-+$//g; s/-+/-/g')"
  echo "$s"
}

SLUG="$(slugify "$TITLE")"
[[ -z "$SLUG" ]] && SLUG="post-${DATE_PREFIX}"

FILE="src/content/blog/${DATE_PREFIX}-${SLUG}.md"
if [[ -f "$FILE" ]]; then
  echo "文件已存在: $FILE"
  exit 1
fi

IFS=',' read -r -a TAGS <<< "$TAGS_RAW"
TAGS_FMT=""
for t in "${TAGS[@]}"; do
  t_trim="$(echo "$t" | sed 's/^ *//;s/ *$//')"
  [[ -n "$t_trim" ]] && TAGS_FMT+="'${t_trim}', "
done
TAGS_FMT="[${TAGS_FMT%, }]"

cat > "$FILE" <<EOF
---
title: '${TITLE}'
description: '请补充一句话摘要。'
pubDate: '${DATE_HUMAN}'
heroImage: '../../assets/blog-placeholder-1.jpg'
tags: ${TAGS_FMT}
---

## 背景

## 过程

## 结果

## 总结
EOF

echo "已创建: $FILE"
