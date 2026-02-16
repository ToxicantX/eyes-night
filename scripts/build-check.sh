#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "[1/3] 安装依赖（如已安装会很快跳过）"
npm install --silent

echo "[2/3] 执行 astro 检查"
npx astro check

echo "[3/3] 构建站点"
npm run build

echo "✅ 构建检查通过"
