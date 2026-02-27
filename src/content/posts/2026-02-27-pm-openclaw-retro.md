---
title: "OpenClaw 晚间复盘 2026-02-27"
published: 2026-02-27
description: "以 Skills 与流程复盘为主的 OpenClaw 晚间复盘。"
tags:
  - "OpenClaw"
draft: false
lang: zh
---

---
title: "OpenClaw 晚间复盘 2026-02-27"
date: "2026-02-27"
category: "OpenClaw"
tags:
  - "OpenClaw"
excerpt: "以 Skills 与流程复盘为主的 OpenClaw 晚间复盘。"
---

# OpenClaw 晚间复盘（2026-02-27 PM）

> 目标：聚焦可复用的 Skills/流程实战，而不是官方信息搬运。

## 1) Browser Relay：把“连不上标签页”变成可执行 SOP（技能/流程）

**变化/学习**
- `profile="chrome"` 是接管现有 Chrome 标签页的唯一正确入口；是否可控取决于扩展徽章是否 `ON`。
- 远程网关场景下，浏览器机器上必须有 node host 承接代理；否则会出现 relay 可用但 tab 未连接的假在线状态。

**具体步骤**
1. `openclaw browser extension install` + 在 `chrome://extensions` 里 Load unpacked。
2. 扩展 Options 配置 `Port=18792` 与正确 Gateway token。
3. 目标标签页点击扩展按钮，确认 badge `ON`。
4. 自动化时统一用 `browser(profile="chrome")`，并在多节点时固定 node。

**可量化影响**
- Browser Relay 首次接入排障步骤可从“靠经验试错”降为 4 步清单，预计把单次定位时间从 **20-40 分钟降到 5-10 分钟**。

**坑点**
- 默认只控制“已手动 attach 的标签页”，不是当前可见页。
- 沙箱会默认偏向 sandbox browser，导致“明明连上了却控不到 host Chrome”。

**建议**：**Act now**（立刻固化为团队 SOP）

**来源**
- 主链接：<https://docs.openclaw.ai/tools/chrome-extension>
- 备份：<https://github.com/openclaw/openclaw/blob/main/docs/tools/chrome-extension.md>

---

## 2) Cron + Heartbeat 分层：时间精度与上下文感知分离（技能/流程）

**变化/学习**
- Heartbeat 负责“批处理感知”（邮件/日历/提醒合并）；Cron 负责“精确定时与隔离执行”。
- Top-of-hour 的定时任务有默认错峰机制，可减少整点拥塞。

**具体步骤**
1. 把高频检查写进 `HEARTBEAT.md`（控制在短清单）。
2. 把精确任务（日报、周报、一次性提醒）放到 `cron` isolated job。
3. 对真正要准点的任务用 `--exact`；其余允许 stagger。
4. 回执分发统一用 `delivery.mode`（announce/webhook/none）。

**可量化影响**
- 对比“多个碎 cron 轮询”，可将周期性巡检的调用次数压缩 **30-60%**（视检查项数量而定）。

**坑点**
- 用 main-session cron 跑重任务会污染主会话历史。
- HEARTBEAT 清单过长会造成 token 持续开销。

**建议**：**Act now**

**来源**
- 主链接：<https://docs.openclaw.ai/automation/cron-vs-heartbeat>
- 备份：<https://docs.openclaw.ai/automation/cron-jobs>

---

## 3) Sub-agent 编排：把“并行”变成可控生产力（技能/流程）

**变化/学习**
- `sessions_spawn` 是标准入口；`mode=run` 适合一次性任务，`thread=true + mode=session` 适合持续上下文。
- 深度 2（orchestrator→worker）可做分工流水线，但需要并发和子任务上限约束。

**具体步骤**
1. 长任务默认拆成子任务，主会话只做收敛与决策。
2. 设定 `maxConcurrent`、`maxChildrenPerAgent`、`runTimeoutSeconds`。
3. 对 ACP 意图（Codex/Claude/Gemini）明确走 `runtime="acp"`，不要混用 native subagent 路径。

**可量化影响**
- 在多任务场景中，可把“串行总耗时”压到接近“最长子任务耗时 + 汇总耗时”，常见可缩短 **25-45%**。

**坑点**
- 不限制子任务并发会造成资源争抢。
- 忽略 announce 语义会导致“任务完成但主线程无感知”。

**建议**：**Act now**

**来源**
- 主链接：<https://docs.openclaw.ai/tools/subagents>
- 备份：<https://github.com/openclaw/openclaw/blob/main/docs/tools/subagents.md>

---

## 4) ACP 会话治理：把“用 Codex/Claude 跑这件事”标准化（技能/流程）

**变化/学习**
- 用户说“用 Codex/Claude/Gemini 做”时，应该直接进入 ACP runtime，而不是本地 exec 假装。
- thread-bound persistent session 在支持线程绑定的平台（当前重点是 Discord）最实用。

**具体步骤**
1. `sessions_spawn` 指定 `runtime="acp"` + `agentId`。
2. 需连续协作时设置 `thread=true`、`mode=session`。
3. 运维上定期用 `/acp doctor`、`/acp status` 做健康检查。

**可量化影响**
- 降低“选错执行后端”导致的返工，预计减少 **1-2 次/日**的切换成本（在高频 coding harness 团队中更明显）。

**坑点**
- 漏填 `agentId` 且未配置 `defaultAgent` 时会直接失败。
- 把 ACP 请求错误路由到 subagent，常见表现是能力与预期不一致。

**建议**：**Act now**

**来源**
- 主链接：<https://docs.openclaw.ai/tools/acp-agents>
- 备份：<https://github.com/openclaw/openclaw/blob/main/docs/tools/acp-agents.md>

---

## 5) Nodes 自动化可靠性：先判断“配对/权限/前台”再动手（技能/流程）

**变化/学习**
- 节点可见 ≠ 节点可执行；至少要通过三关：pairing、capability、approval。
- 移动端 camera/screen/canvas 强依赖前台态，是最容易忽略的“假故障”来源。

**具体步骤**
1. 固定诊断序列：`openclaw nodes status` → `describe` → `approvals get`。
2. 遇到 `NODE_BACKGROUND_UNAVAILABLE` 先切前台再重试。
3. `system.run` 失败优先核对 allowlist/approval，而不是盲目重试命令。

**可量化影响**
- 节点类故障首轮定位成功率可明显提升，预计减少 **50%+** 的重复问诊回合。

**坑点**
- 把权限问题误判成网络问题。
- 只看 `status connected` 就开始执行高风险动作。

**建议**：**Act now**

**来源**
- 主链接：<https://docs.openclaw.ai/nodes/troubleshooting>
- 备份：<https://github.com/openclaw/openclaw/blob/main/docs/nodes/troubleshooting.md>

---

## 6) Skills 工程化：用 gating + 分层目录防止“能跑但不稳”（技能/流程）

**变化/学习**
- skills 加载是分层优先级：workspace > `~/.openclaw/skills` > bundled。
- `metadata.openclaw.requires.*`（bins/env/config）是避免误加载和误调用的关键。

**具体步骤**
1. 自研 skill 必带 frontmatter + 精准 description。
2. 配置 `requires.bins/env/config`，并在 `skills.entries` 注入必要环境变量。
3. 对第三方 skills 默认按“不可信输入”处理，配合 sandbox 策略。

**可量化影响**
- 可将“技能可见但不可用”的运行时错误前移到加载期，预计减少 **30%+** 的无效调用。

**坑点**
- 忽略 session snapshot：改完 skill 立刻在同会话测试，容易误判“修改未生效”。
- 过多 skills 会增加 prompt token 成本。

**建议**：**Watch**（先治理高频技能，再全面扩展）

**来源**
- 主链接：<https://docs.openclaw.ai/tools/skills>
- 备份：<https://docs.openclaw.ai/tools/creating-skills>

---

## 7) 社区案例：ACP 标准化与错误可读性在快速迭代（社区）

**变化/学习**
- 社区近期活跃在 ACP 标准化插件与错误信息国际化上，说明“可观测性 + 可操作错误”正在成为优先级。

**具体步骤**
1. 跟踪 ACP 相关 PR 的合并与回归问题。
2. 复用社区在 error message 上的 pattern：报错要给“下一步动作”。
3. 将自家 runbook 对齐社区常见问题（路由、权限、线程绑定）。

**可量化影响**
- 更清晰的错误链路可减少一线排障往返；保守估计可节省 **10-20%** 的协作沟通成本。

**坑点**
- 只看 changelog 不看讨论线程，容易错过限制条件与边界。

**建议**：**Watch**

**来源**
- 主链接：<https://github.com/openclaw/openclaw/pull/28662>
- 备份：<https://github.com/openclaw/openclaw/pull/28735>

---

## 8) 官方更新一条看完：版本节奏快，适合“小步快跑 + 回滚预案”（官方汇总）

**变化/学习**
- 最近版本节奏密集（含 beta 与稳定发布并行），说明新能力与修复会持续快速落地。

**具体步骤**
1. 升级采用“预生产先跑 + 关键链路回归”策略。
2. 建立最小回滚手册（配置备份、插件版本锁定、健康检查命令）。
3. 只在窗口期升级，不在核心业务高峰切换。

**可量化影响**
- 规范化升级可显著降低“线上热修”的风险，预计将升级事故率压到 **低个位数百分比**。

**坑点**
- 跨版本直接跳跃升级而不跑 smoke test。

**建议**：**Act now**（先把升级/回滚流程文档化）

**来源**
- 主链接：<https://github.com/openclaw/openclaw/releases>
- 备份：<https://github.com/openclaw/openclaw/releases/tag/v2026.2.26>

---

## 明日优先事项

1. 把 Browser Relay 接入步骤固化为 1 页 SOP（含 `ON/!/…` 徽章分诊表）。
2. 重构定时体系：Heartbeat 只保留批处理巡检，精确定时全部迁移到 isolated cron。
3. 对 ACP 与 sub-agent 路由做“意图到执行后端”的显式规则检查。
4. 为 nodes 建立三段式排障模板（pairing/permission/foreground）。
5. 清理高频 skills，补齐 `requires.*` gating，减少无效暴露与 token 开销。
