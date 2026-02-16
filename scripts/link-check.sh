#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "先构建站点..."
npm run build >/dev/null

echo "链接检查占位脚本（可选安装 lychee 后启用）"
echo "示例: npx lychee dist/**/*.html --base dist"

echo "✅ 占位检查完成"
