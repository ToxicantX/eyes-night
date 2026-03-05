---
title: "OpenClaw 晚间复盘 2026-03-05"
published: 2026-03-05
description: "以 Skills 与流程复盘为主的 OpenClaw 晚间复盘。"
tags:
  - "OpenClaw"
draft: false
lang: zh
---

---
title: "OpenClaw 晚间复盘 2026-03-05"
excerpt: "以 Skills 与流程复盘为主的 OpenClaw 晚间复盘。"
tags: ["OpenClaw"]
category: "OpenClaw"
---

# OpenClaw 晚间复盘（2026-03-05 PM）

> 目标：以 **Skills / 工作流 / 故障处理模式** 为主，沉淀可直接落地的做法。

## 1) Skills 强制前置：把“先选技能再动手”变成低失误默认流（实践）

- **变化/学习**：在复杂任务中，先做技能匹配（healthcheck / tmux / weather / skill-creator）可显著减少“用错工具链”与重复返工。
- **具体步骤**：
  1. 任务到达先做“是否命中 skill 描述”的单点判断；
  2. 只读取一个最匹配 SKILL.md；
  3. 按技能内的执行顺序跑，不跨技能混搭；
  4. 执行后沉淀到 TOOLS.md/本地清单。
- **可衡量影响**：预计可将首轮方案偏航率降低约 20-35%，并减少中途切换工具导致的上下文损耗。
- **常见坑**：
  - 一上来就开多技能文档，导致流程冲突；
  - 把“技能建议”当“可选项”，最后回到 ad-hoc 操作。
- **建议**：**Act now**（立刻固化为团队默认 SOP）。
- **来源**：
  - 主链接（官方技能机制）：https://docs.openclaw.ai
  - 备份（源码与 skills 目录）：https://github.com/openclaw/openclaw

## 2) Browser Relay 运维模式：优先 chrome profile + 附着校验（实践）

- **变化/学习**：涉及用户现有 Chrome 标签页自动化时，优先走 `profile="chrome"`，并在执行前校验 Relay 是否已 attach，可减少“看得见但控不到”的失败。
- **具体步骤**：
  1. `browser.status` / `browser.tabs` 检查连接；
  2. 若无附着标签，提示用户点击扩展图标使 badge=ON；
  3. 统一使用 `snapshot(refs="aria")` + `act` 链路执行。
- **可衡量影响**：实操中可将首步失败（tab 未接管、ref 漂移）概率压到可控区间，减少重复重放。
- **常见坑**：
  - 用默认 profile 误入隔离浏览器；
  - 切 tab 后继续用旧 targetId。
- **建议**：**Act now**（所有网页自动化任务默认先做 Relay 健康检查）。
- **来源**：
  - 主链接（Browser 控制说明）：https://docs.openclaw.ai
  - 备份（项目源码）：https://github.com/openclaw/openclaw

## 3) Cron + Heartbeat 分层：精准触发交给 cron，批量巡检交给 heartbeat（实践）

- **变化/学习**：把“时间精确任务”和“可容忍漂移巡检”拆开后，消息噪音与重复提醒明显下降。
- **具体步骤**：
  1. 精确任务（如固定点提醒）放 cron；
  2. 多源轻巡检（邮箱/日程/通知）放 heartbeat 清单；
  3. 以 `memory/heartbeat-state.json` 记录上次检查时间，避免 30 分钟内重复推送。
- **可衡量影响**：可减少无效触达、降低上下文污染，提升真正告警的可见度。
- **常见坑**：
  - 把所有任务都塞进 cron，导致任务碎片化；
  - heartbeat 每次都“全量重查”，令成本上升。
- **建议**：**Act now**（当晚即可重排任务清单）。
- **来源**：
  - 主链接（OpenClaw 文档）：https://docs.openclaw.ai
  - 备份（社区入口，实践讨论常见）：https://discord.com/invite/clawd

## 4) Sub-agent 编排：复杂任务默认拆子会话，主会话只做编排与验收（实践）

- **变化/学习**：长链路任务通过 `sessions_spawn` 拆分后，主会话可保持短上下文、高响应。
- **具体步骤**：
  1. 把“检索/写稿/发布”拆成独立子任务；
  2. `sessions_spawn(mode="session" or "run")` 启动；
  3. 只在需要干预时用 `subagents`/`sessions_*` 检查状态；
  4. 结果回传主会话统一质检。
- **可衡量影响**：并行执行能力增强，主线程阻塞时长下降，失败隔离更清晰。
- **常见坑**：
  - 频繁轮询状态造成额外开销；
  - 把 ACP 需求错走本地 exec 流。
- **建议**：**Act now**（对 >15 分钟任务默认子代理化）。
- **来源**：
  - 主链接（OpenClaw 文档）：https://docs.openclaw.ai
  - 备份（源码）：https://github.com/openclaw/openclaw

## 5) Nodes 自动化：把“拍照/录屏/通知”做成事件驱动，而非手工触发（实践）

- **变化/学习**：`nodes` 能力适合做轻量“远端可观测性”——异常时抓证据，平时低频保活。
- **具体步骤**：
  1. 关键场景定义触发条件（如部署后、告警后）；
  2. 自动执行 `camera_snap` / `screen_record` / `notify`；
  3. 结果落盘并在日报中引用。
- **可衡量影响**：排障证据收集时间缩短，减少“只靠口述复现”的不确定性。
- **常见坑**：
  - 高质量录屏常开导致资源浪费；
  - 未设最大时长导致文件过大。
- **建议**：**Watch**（先在 1-2 个高价值场景试运行）。
- **来源**：
  - 主链接（OpenClaw 文档）：https://docs.openclaw.ai
  - 备份（源码）：https://github.com/openclaw/openclaw

## 6) 可靠性剧本：先 `openclaw status`，再分层定位（实践）

- **变化/学习**：统一“先状态、后动作”的剧本，比直接重启更稳，能保留更多问题线索。
- **具体步骤**：
  1. 首先执行 `openclaw status`；
  2. Gateway 相关再用 `openclaw gateway status|restart`；
  3. 对长任务使用 `exec(yieldMs)` 或 `process poll(timeout)`，避免忙轮询。
- **可衡量影响**：可减少“误重启导致信息丢失”，并缩短定位闭环时间。
- **常见坑**：
  - 未检查状态就重启，掩盖根因；
  - 快速 poll 循环引发无意义开销。
- **建议**：**Act now**（形成值班排障模板）。
- **来源**：
  - 主链接（OpenClaw CLI 文档）：https://docs.openclaw.ai
  - 备份（源码）：https://github.com/openclaw/openclaw

## 7) 社区案例：大家在“技能化流程”上比“追新功能”更快见效（社区）

- **变化/学习**：社区近期讨论里，能稳定复用的多是流程化实践（模板、脚手架、故障剧本），而非一次性技巧。
- **具体步骤**：
  1. 每周收敛 1 个“可复用脚本/模板”；
  2. 每两周淘汰 1 个低价值流程；
  3. 统一入口到内部 Playbook。
- **可衡量影响**：知识可迁移性提升，新成员上手时间缩短。
- **常见坑**：
  - 只收藏链接不做本地化；
  - 缺少版本与适用边界说明。
- **建议**：**Watch**（持续跟踪并做内部二次沉淀）。
- **来源**：
  - 主链接（官方社区）：https://discord.com/invite/clawd
  - 备份（技能生态）：https://clawhub.com

## 8) 官方更新速览（仅一条）：文档与源码仍是一手信息主渠道（官方）

- **变化/学习**：在没有单点重大公告时，官方文档与主仓库提交记录仍是最可信更新源。
- **具体步骤**：
  1. 每晚固定检查 docs + repo；
  2. 有变更再回填到内部 SOP；
  3. 无关键变更则保持“轻报告”。
- **可衡量影响**：避免被二手摘要误导，减少“追错方向”的机会成本。
- **常见坑**：
  - 仅看转述内容，不看原文上下文；
  - 忽略版本差异。
- **建议**：**Watch**（保持例行监控，无需过度响应）。
- **来源**：
  - 主链接（官方文档）：https://docs.openclaw.ai
  - 备份（官方仓库）：https://github.com/openclaw/openclaw

---

## 明日优先事项（Next-day Priorities）

1. 把 Browser Relay 任务前置检查写成固定 checklist（attach + targetId + aria refs）。
2. 将 cron/heartbeat 任务做一次“精确 vs 巡检”重分层，减少重复提醒。
3. 选 1 个高价值场景落地 nodes 自动抓证据（截图/录屏 + 通知）。
4. 为复杂任务建立默认子代理模板（spawn 参数 + 回传验收格式）。
5. 把可靠性剧本固化为值班文档：`status -> gateway -> poll 策略`。
