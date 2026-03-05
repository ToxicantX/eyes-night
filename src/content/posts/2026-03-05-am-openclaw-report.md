---
title: "OpenClaw 实战早报 2026-03-05"
published: 2026-03-05
description: "以 Skills 与实操流程为主的 OpenClaw 实战早报。"
tags:
  - "OpenClaw"
draft: false
lang: zh
---

# OpenClaw 实战早报 2026-03-05

> 口径：以 Skills/工作流实操为主，社区案例其次，官方更新不单列（今日 0 条）。  
> 新颖性说明：已对比昨天早报与晚间复盘（2026-03-04 AM/PM）。本期 6 条中，至少 5 条为新主题，1 条为“同主题新增可执行细节（含 delta）”。

## 1) Skill 触发词“防串台”实践：先收窄 description，再放宽
**为什么今天值得做**：Skill 增多后最常见问题不是“不会触发”，而是“误触发”。

**可复现做法**
1. 在 `SKILL.md` 的 `description` 写“明确边界 + 反例”（何时不要触发）。
2. 首轮只覆盖 1-2 个高频意图，别一上来写成“万能技能”。
3. 用 10 条真实提问做回归，记录误触发率，再逐步放宽描述。

**验收标准**
- 误触发率先压下来，再追求召回率。

**来源**
- https://docs.openclaw.ai/tools/creating-skills
- https://github.com/openclaw/openclaw/blob/main/docs/tools/creating-skills.md

---

## 2) Skills 环境变量分层：Host 生效 ≠ Sandbox 生效
**为什么今天值得做**：很多“本地可用、沙箱报错”的根因是 env 注入层级搞混。

**可复现做法**
1. 若你跑 Host：用 `skills.entries.<skill>.env` 或 `apiKey`。
2. 若你跑 Sandbox：改 `agents.defaults.sandbox.docker.env`（或自定义镜像内置）。
3. 同一 skill 在 host/sandbox 各跑一次最小 smoke test。

**验收标准**
- 两个运行面（host/sandbox）都能稳定取到关键密钥。

**来源**
- https://docs.openclaw.ai/tools/skills-config
- https://github.com/openclaw/openclaw/blob/main/docs/tools/skills-config.md

---

## 3) Exec 长任务稳态模板：`yieldMs` + `process poll(timeout)`
**为什么今天值得做**：长命令最容易出现“卡住误判”或“高频轮询刷 token”。

**可复现做法**
1. 首次执行给足 `yieldMs`（如 20000-60000），避免过早切后台。
2. 进入后台后，用 `process(action="poll", timeout=30000)`，不要紧密循环。
3. 仅在需要时拉 `process log`，结束后再做一次结果归档。

**验收标准**
- 同等任务下，状态查询次数明显下降，且无漏报完成状态。

**来源**
- https://docs.openclaw.ai/tools/exec
- https://github.com/openclaw/openclaw/blob/main/docs/tools/exec.md

---

## 4) 记忆检索两段式：`memory_search` 先召回，`memory_get` 再精读
**为什么今天值得做**：可以减少“全文件扫读”，同时提高可追溯性。

**可复现做法**
1. 先用 `memory_search` 找片段（关注 path + line range + score）。
2. 对命中片段再 `memory_get(path, from, lines)` 做定点读取。
3. 输出时附 `Source: <path#line>`，方便复核。

**验收标准**
- 回答“历史决策/偏好/待办”类问题时可直接定位到文件行号。

**来源**
- https://docs.openclaw.ai/concepts/memory
- https://github.com/openclaw/openclaw/blob/main/docs/concepts/memory.md

---

## 5) Sub-agent 从“能跑”到“可控”：加上 `runTimeoutSeconds` 与 `cleanup`
**New since yesterday**
昨天复盘讲了“复杂任务拆子会话”的方向；今天补上可直接落地的两个控制阀：
- `runTimeoutSeconds`：避免子任务无限拖住
- `cleanup=delete|keep`：明确产物留存策略

**可复现做法**
1. 研究类任务：`sessions_spawn(..., runTimeoutSeconds=900, cleanup="keep")`。
2. 一次性流水线：完成即归档场景可用 `cleanup="delete"`。
3. 固定在“里程碑点”查状态，避免轮询式盯跑。

**验收标准**
- 子任务超时行为可预测，且会话留存策略一致。

**来源**
- https://docs.openclaw.ai/tools/subagents
- https://docs.openclaw.ai/concepts/session-tool

---

## 6) 社区案例（可复刻）：CSV 驱动本地 Skill（酒窖管理）
**案例价值**：不是 demo，而是“结构化数据 + 本地 skill + 立即可用”的闭环。

**可复刻路径（30-60 分钟）**
1. 准备你自己的 CSV（如库存/设备/清单）。
2. 让 OpenClaw 基于该 CSV 生成本地 skill（先最小查询能力）。
3. 用 5 个真实问法回归（排序、过滤、异常值）。
4. 稳定后再加写操作（先 dry-run，再真写入）。

**来源**
- https://openclaw.ai/showcase
- https://x.com/i/status/2010916352454791216
- https://docs.openclaw.ai/start/showcase

---

> 分布校验：6 条中，Skills/工作流 5 条（83.3%）；社区案例 1 条（16.7%）；官方更新 0 条。满足约束。
