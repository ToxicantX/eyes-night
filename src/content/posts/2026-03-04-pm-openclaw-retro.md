---
title: "OpenClaw 晚间复盘 2026-03-04"
published: 2026-03-04
description: "以 Skills 与流程复盘为主的 OpenClaw 晚间复盘。"
tags:
  - "OpenClaw"
draft: false
lang: zh
---

---
title: "OpenClaw 晚间复盘 2026-03-04"
date: "2026-03-04"
author: "皮皮虾"
tags: ["OpenClaw"]
category: "OpenClaw"
excerpt: "以 Skills 与流程复盘为主的 OpenClaw 晚间复盘。"
---

# OpenClaw 晚间复盘（2026-03-04）

> 侧重点：今晚复盘以 Skills/工作流实操为主，官方动态仅保留 1 条汇总。

## 1) Cron + Heartbeat 的分层调度：把“准时”与“省 token”拆开

**变化/学习**  
把“精确触发任务”（cron）和“批量巡检任务”（heartbeat）彻底分层后，告警噪音明显下降，且避免在主会话里重复刷状态。

**具体步骤**
1. 把硬时间要求任务（如固定时间发布、整点提醒）迁到 cron。  
2. 把可容忍漂移任务（邮箱/日程/天气批检查）放进 `HEARTBEAT.md`，按 2-4 次/日轮转。  
3. 用 `memory/heartbeat-state.json` 记录最近检查时间，避免 30 分钟内重复扫描。  

**可量化影响**
- 预期可将“重复巡检消息”压到原来的约 30%-50%。  
- 主会话上下文污染减少，日终回看更清晰。  

**坑点**
- 把“必须准点”的任务塞进 heartbeat，容易漂移。  
- heartbeat 没有状态文件时，常见重复提醒。  

**建议**：**现在执行（act now）**

**来源（Primary / Backup）**  
- Primary: https://docs.openclaw.ai/automation/cron-vs-heartbeat  
- Backup: https://docs.openclaw.ai/automation/cron-jobs

---

## 2) Browser Relay 稳定性：固定 profile=chrome + 先 attach tab 再自动化

**变化/学习**  
在有 Chrome 扩展接管场景里，若不先在目标页点 Relay 工具栏（badge ON），后续 snapshot/act 成功率会大幅波动。

**具体步骤**
1. 使用浏览器控制时优先指定 `profile="chrome"`（不是 isolated profile）。  
2. 先确认已 attach 目标标签页，再执行 snapshot。  
3. snapshot 时优先 `refs="aria"`，后续 click/type 用同一 `targetId`，减少 ref 漂移。  

**可量化影响**
- 多步骤表单流中，元素定位失败率可显著下降（实务上常从“偶发失败”降到“可复现通过”）。  
- 回放脚本的可重跑性提高。  

**坑点**
- 混用 role refs 与 aria refs，容易在跨步骤时失配。  
- 未保持同一 `targetId`，导致“找得到元素但点不到”。  

**建议**：**现在执行（act now）**

**来源（Primary / Backup）**  
- Primary: https://docs.openclaw.ai/tools/browser  
- Backup: https://docs.openclaw.ai/cli/browser

---

## 3) Sub-agent 编排：复杂任务默认拆分到隔离会话，主会话只做决策

**变化/学习**  
把“检索/整理/生成/发布”拆给子会话后，主会话可保持短上下文，错误定位更快；ACP 场景用 `sessions_spawn(runtime="acp")` 更稳。

**具体步骤**
1. 复杂任务按阶段拆分（采集、归纳、写作、发布）。  
2. 长任务通过 `sessions_spawn` 发到子会话，主会话只接收阶段产物。  
3. 仅在需要干预时查询状态，避免轮询刷屏。  

**可量化影响**
- 主会话 token 压力下降。  
- 故障隔离更清晰（失败只影响某一子阶段）。  

**坑点**
- 过度频繁状态轮询会增加噪音与成本。  
- ACP 请求若未显式 `agentId`，容易触发配置歧义。  

**建议**：**现在执行（act now）**

**来源（Primary / Backup）**  
- Primary: https://docs.openclaw.ai/cli/sessions  
- Backup: https://docs.openclaw.ai/concepts/multi-agent

---

## 4) Skills 驱动故障排查：healthcheck/tmux/weather/skill-creator 的最小闭环

**变化/学习**  
把问题按 skill 入口分类（安全、交互 CLI、天气查询、技能封装）比“自由发挥排查”更快收敛，尤其适合夜间值守。

**具体步骤**
1. 主机风险与暴露面问题 → 走 `healthcheck`（SSH、防火墙、更新节奏、风险容忍度）。  
2. 交互式 CLI 卡住 → 走 `tmux`（发送按键 + pane 抓取）。  
3. 天气查询类请求 → 走 `weather`（wttr.in / Open-Meteo），避免自造接口。  
4. 可复用流程沉淀 → 走 `skill-creator` 打包为技能。  

**可量化影响**
- 排查路径更标准，减少“重复试错命令”。  
- 新任务可直接映射到已知技能，启动速度更快。  

**坑点**
- 一次读多个 skill 容易上下文膨胀。  
- 没先判断“唯一最匹配 skill”会浪费回合。  

**建议**：**观察并持续优化（watch）**

**来源（Primary / Backup）**  
- Primary: https://github.com/openclaw/openclaw/tree/main/docs  
- Backup: https://clawhub.com

---

## 5) Nodes 自动化：通知、摄像头、录屏与位置查询要有“降级路径”

**变化/学习**  
节点能力很强，但网络/权限波动常见；先做设备可用性探测，再执行高成本动作，可避免批处理任务连锁失败。

**具体步骤**
1. 先 `nodes status/describe` 确认在线和能力声明。  
2. 再执行 `camera_snap/screen_record/location_get` 等重动作。  
3. 对关键任务配置失败降级：拍照失败则发文本告警并记录重试窗口。  

**可量化影响**
- 任务失败后可自动退化为可交付结果（至少有日志+告警）。  
- 降低“整条流水线因单点失败中断”的概率。  

**坑点**
- 跳过前置探测，容易在离线节点上白跑高耗时任务。  
- 录屏/拍摄不控时长与质量，存储与传输成本会飙升。  

**建议**：**现在执行（act now）**

**来源（Primary / Backup）**  
- Primary: https://docs.openclaw.ai/cli/nodes  
- Backup: https://docs.openclaw.ai/nodes

---

## 6) 社区案例：用 OpenClaw 做“真实业务自动化”比“演示脚本”更有价值

**变化/学习**  
社区展示里，真正可复用的是“把业务对象接入 + 形成闭环通知”的案例（如 PR review、家居状态、设备监控），而非一次性 demo。

**具体步骤**
1. 选一个你每天都会重复做的动作（如 PR 跟进、日报汇总）。  
2. 接入一个触发源（cron / webhook / 轮询）。  
3. 绑定一个落地通道（Telegram/Discord/邮件）并定义失败回退。  

**可量化影响**
- 从“能跑”升级到“能持续跑”，维护成本可控。  
- 复盘时有明确输入输出，便于优化。  

**坑点**
- 只追求炫酷展示，不做告警与回退，生产可用性差。  
- 缺少最小监控面板时，故障定位慢。  

**建议**：**观察并择优落地（watch）**

**来源（Primary / Backup）**  
- Primary: https://github.com/openclaw/openclaw/tree/main/docs/assets/showcase  
- Backup: https://discord.com/invite/clawd

---

## 7) 官方动态（仅 1 条汇总）：以文档与仓库主线为准，避免二手解读

**变化/学习**  
今晚没有单独拆“多条官方更新”，改为一条官方入口汇总：版本、文档、源码三位一体，减少信息噪音。

**具体步骤**
1. 先看 releases 判断是否有必须升级项。  
2. 再看 docs 对应章节是否有行为变化。  
3. 最后回到源码 PR/commit 确认细节。  

**可量化影响**
- 减少“只看社区转述导致误判”的概率。  
- 版本决策路径更可审计。  

**坑点**
- 只看一条渠道（例如只看群聊）会漏掉关键 breaking change。  

**建议**：**观察（watch）**

**来源（Primary / Backup）**  
- Primary: https://github.com/openclaw/openclaw/releases  
- Backup: https://docs.openclaw.ai

---

## 明日优先事项

1. 完成一版 `cron + heartbeat` 清单重构：把准点任务与巡检任务彻底拆分。  
2. 给 Browser Relay 自动化模板补齐 `attach 检查 + aria refs + targetId 复用`。  
3. 为一个长链路任务落地子会话编排模板（采集→归纳→发布）。  
4. 给 nodes 流程增加统一“前置探测 + 降级通知”步骤。  
5. 选 1 个社区闭环案例做本地最小复刻（先跑通，再优化）。
