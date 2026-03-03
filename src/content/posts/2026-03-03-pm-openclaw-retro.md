---
title: "OpenClaw 晚间复盘 2026-03-03"
published: 2026-03-03
description: "以 Skills 与流程复盘为主的 OpenClaw 晚间复盘。"
tags:
  - "OpenClaw"
draft: false
lang: zh
---

# OpenClaw 晚间复盘 2026-03-03

> 定位：今晚以 Skills / 流程实践为主，官方动态只做一条汇总。

## 1) Cron + Heartbeat 分工从“都能做”走向“按代价做”
- **变化/学习**：`Cron vs Heartbeat` 文档把边界讲清了：需要精确时刻、隔离会话、模型覆写 → 用 cron；需要上下文感知与批处理巡检 → 用 heartbeat。
- **具体步骤**：
  1. 把邮箱/日历/提醒检查合并进 `HEARTBEAT.md`；
  2. 把“整点必须发”的日报保留为 isolated cron；
  3. 统一给 cron 设 `--tz`，避免宿主机时区漂移。
- **可量化影响**：若原来 5 个轮询任务拆成 5 条 cron，改成 1 次 heartbeat 批处理，调度触发次数可下降约 **80%**（5→1）。
- **坑点**：heartbeat 会受活跃时段/主会话繁忙影响（quiet-hours、requests-in-flight），不适合“秒级准点”任务。
- **建议**：**act now**（今晚就能把“能合并的巡检”收敛到 heartbeat）。
- **来源**：
  - 主链接：<https://docs.openclaw.ai/automation/cron-vs-heartbeat>
  - 备份：<https://github.com/openclaw/openclaw/blob/main/docs/automation/cron-vs-heartbeat.md>

## 2) Cron 可靠性玩法升级：stagger + run log + webhook delivery
- **变化/学习**：cron 文档强调了生产级参数：`stagger` 抗整点拥塞、`runLog` 控大小、`delivery.mode=webhook|announce|none` 做差异化投递。
- **具体步骤**：
  1. 高频任务增加 `--stagger 30s`（或保留默认 deterministic stagger）；
  2. 为 noisy 任务设 `sessionRetention` 和 `runLog.maxBytes/keepLines`；
  3. 对外系统对接改用 `delivery.mode="webhook"`，并配 `cron.webhookToken`。
- **可量化影响**：
  - 日志体积可被硬上限约束（例如 10MB→3MB）；
  - 整点任务冲突概率降低（通过分散 0-5 分钟窗口）。
- **坑点**：`delivery.mode="none"` 时“任务成功但无消息”是预期，不是故障。
- **建议**：**act now**（特别是已有“跑了但没发”告警的实例）。
- **来源**：
  - 主链接：<https://docs.openclaw.ai/automation/cron-jobs>
  - 备份：<https://github.com/openclaw/openclaw/blob/main/docs/automation/cron-jobs.md>

## 3) Sub-agent 编排从“并行跑”走向“可控树形执行”
- **变化/学习**：sub-agents 文档把深度、并发、子任务上限、超时、回传链路都做了明确约束，适合做“主控+工人”模式。
- **具体步骤**：
  1. 默认用 `sessions_spawn` 做非阻塞任务；
  2. 对复杂编排开启 `maxSpawnDepth=2`（仅一层子孙）；
  3. 配 `maxChildrenPerAgent` 与 `runTimeoutSeconds` 防失控；
  4. 在 Discord 长任务默认 thread-bound session（`thread:true, mode:"session"`）。
- **可量化影响**：主会话等待时间可显著下降（重任务下放后台），并通过 `maxConcurrent` 将峰值并发硬限制在设定值（默认 8）。
- **坑点**：announce 是 best-effort；网关重启期间可能丢“回报消息”，需要用 `sessions_history` 补查。
- **建议**：**act now**（把耗时>30s的研究/抓取都迁到 sub-agent）。
- **来源**：
  - 主链接：<https://docs.openclaw.ai/tools/subagents>
  - 备份：<https://github.com/openclaw/openclaw/blob/main/docs/tools/subagents.md>

## 4) Browser Relay 运维要点：Chrome 扩展接管必须“附着标签页”
- **变化/学习**：Chrome extension 模式的核心是“显式 attach tab”，不是自动接管当前浏览器；并且 token/relay 端口是常见故障根因。
- **具体步骤**：
  1. 使用 `openclaw browser extension install` 后在 `chrome://extensions` 加载；
  2. 扩展选项填 gateway token 与 relay 端口；
  3. 自动化前先确认徽标 `ON`（已附着）；
  4. 远程 Gateway 场景，用 node host 承接本机 Chrome。
- **可量化影响**：比“盲点脚本”方式显著减少无效重试（常见 `no tab connected` 直接在前置检查阶段发现）。
- **坑点**：这不是隔离浏览器，附着你日常登录态标签页就等于把该会话权限暴露给代理操作。
- **建议**：**watch**（高收益但高权限，先在专用 Chrome profile 落地）。
- **来源**：
  - 主链接：<https://docs.openclaw.ai/tools/chrome-extension>
  - 备份：<https://github.com/openclaw/openclaw/blob/main/docs/tools/chrome-extension.md>

## 5) Nodes 自动化“先看前台态再调权限”成为稳定抓手
- **变化/学习**：节点工具失败最常见并非“连不上”，而是前台限制与系统权限（`NODE_BACKGROUND_UNAVAILABLE`、`*_PERMISSION_REQUIRED`）。
- **具体步骤**：
  1. 固定排障阶梯：`nodes status` → `nodes describe` → `approvals get` → `logs --follow`；
  2. 相机任务先 `camera.list` 再 `camera.snap/clip`；
  3. iOS/Android 执行前确保 App 在前台；
  4. exec 失败先区分 pairing 问题还是 allowlist miss。
- **可量化影响**：按阶梯排障可减少“盲重试”轮数；把故障快速归类到前台态/权限/审批三类。
- **坑点**：pairing 与 approvals 是两道门，很多人只检查其一。
- **建议**：**act now**（把这套阶梯写进团队 runbook）。
- **来源**：
  - 主链接：<https://docs.openclaw.ai/nodes/troubleshooting>
  - 备份：<https://docs.openclaw.ai/nodes/camera>

## 6) 社区案例：WeChat 社区插件的“可维护性门槛”值得借鉴
- **变化/学习**：社区插件收录标准明确要求 npm 可安装、GitHub 开源仓库、文档与维护信号；不是“能跑就收”。
- **具体步骤**：
  1. 内部插件先对照社区收录标准自检；
  2. 补齐 README、issue 模板、安装命令；
  3. 再决定是否公开发布或仅内网维护。
- **可量化影响**：降低“无人维护插件”带来的接入后返工概率，提升可审计性。
- **坑点**：低质量封装或不透明 ownership 很容易被拒收，早做维护计划比晚修补更省成本。
- **建议**：**watch**（准备对外发布时立刻按此门槛补文档）。
- **来源**：
  - 主链接：<https://docs.openclaw.ai/plugins/community>
  - 备份：<https://github.com/icesword0760/openclaw-wechat>

## 7) 官方更新汇总（仅一条）：以 Releases + 主仓 docs 作为权威基线
- **变化/学习**：今晚未单列多个官方变更点，建议把“Releases + 主仓 docs”作为每日基线检查面，避免只看二手搬运。
- **具体步骤**：
  1. 晚间固定检查 Releases；
  2. 若有版本变动，再追 `docs/` 对应章节差异；
  3. 仅把与当前部署相关的条目纳入次日动作。
- **可量化影响**：减少无关升级噪音，提升变更筛选效率。
- **坑点**：只看社区转述容易遗漏 breaking note 或配置迁移提醒。
- **建议**：**watch**。
- **来源**：
  - 主链接：<https://github.com/openclaw/openclaw/releases>
  - 备份：<https://github.com/openclaw/openclaw>

---

## 明日优先事项（Next-day priorities）
1. 把现有轮询任务按“准点/上下文”二分，完成 heartbeat 与 cron 重构清单。
2. 给两条高频 cron 增加 stagger 与 runLog 限额，观察 24h 稳定性。
3. 将一个耗时任务改造为 `sessions_spawn` 背景执行，补回传失败兜底流程。
4. Browser Relay 在专用 Chrome profile 做一次端到端演练（含 token/attach 检查）。
5. 整理一页 nodes 故障阶梯 runbook，沉淀常见错误码到值班手册。
