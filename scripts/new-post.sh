#!/usr/bin/env bash
set -euo pipefail

# 用法：
# ./scripts/new-post.sh "文章标题" [tag1,tag2] [一句话摘要] [hero序号1-5]

if [[ $# -lt 1 ]]; then
  echo "用法: ./scripts/new-post.sh \"文章标题\" [tag1,tag2] [一句话摘要] [hero序号1-5]"
  exit 1
fi

TITLE="$1"
TAGS_RAW="${2:-博客搭建}"
DESCRIPTION="${3:-请补充一句话摘要。}"
HERO_INDEX="${4:-1}"

# hero 占位图范围 1-5
if ! [[ "$HERO_INDEX" =~ ^[1-5]$ ]]; then
  echo "hero序号仅支持 1-5，已回退为 1"
  HERO_INDEX="1"
fi

DATE_HUMAN="$(date '+%b %d %Y')"
DATE_PREFIX="$(date '+%Y-%m-%d')"

slugify() {
  local s="$1"
  s="$(echo "$s" | tr '[:upper:]' '[:lower:]')"
  # 保留英文、数字、中文，其余替换为 -
  s="$(echo "$s" | sed -E 's/[^a-z0-9一-龥]+/-/g; s/^-+|-+$//g; s/-+/-/g')"
  echo "$s"
}

SLUG="$(slugify "$TITLE")"
[[ -z "$SLUG" ]] && SLUG="post-${DATE_PREFIX}"

BASE="src/content/blog/${DATE_PREFIX}-${SLUG}"
FILE="${BASE}.md"
N=2
while [[ -f "$FILE" ]]; do
  FILE="${BASE}-${N}.md"
  ((N++))
done

IFS=',' read -r -a TAGS <<< "$TAGS_RAW"
TAGS_FMT=""
for t in "${TAGS[@]}"; do
  t_trim="$(echo "$t" | sed 's/^ *//;s/ *$//')"
  [[ -n "$t_trim" ]] && TAGS_FMT+="'${t_trim}', "
done
[[ -z "$TAGS_FMT" ]] && TAGS_FMT="'未分类', "
TAGS_FMT="[${TAGS_FMT%, }]"

cat > "$FILE" <<EOF
---
title: '${TITLE}'
description: '${DESCRIPTION}'
pubDate: '${DATE_HUMAN}'
heroImage: '../../assets/blog-placeholder-${HERO_INDEX}.jpg'
tags: ${TAGS_FMT}
---

## 背景

## 过程

## 结果

## 总结
EOF

echo "✅ 已创建: $FILE"
echo "下一步建议："
echo "1) 编辑文章：${FILE}"
echo "2) 本地检查：npm run build-check"
echo "3) 发布检查：npm run release-checklist"
