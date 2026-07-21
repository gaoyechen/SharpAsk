# Interaction Patterns

Use this file when SharpInput needs a user choice.

## Rules

- Prefer an available structured choice tool when the user must choose an intent, context, direction, or path; otherwise ask concise text.
- Do not output JSON blocks for the user to copy.
- Options must reflect the user's actual input, not generic labels.
- Keep to 2-4 options plus the platform's free-form "Other" option when available.
- If the tool fails, print the same options as concise text and ask the user to reply with the option label.

## 选项推导规则（v2.4）

当需要从用户输入推导具体选项时（如 Context Gap 模板的 `[从原文推导的具体选项]`），按以下算法：

```
1. 扫描用户输入提取 domain 关键词（名词短语、技术术语、实体名称）
2. 将关键词归类到 2-3 个有意义的选择方向
3. 每个选项必须说明选择后的输出方向变化
4. 规则：1 个通用型 + 1 个输入推导的具体型 + 1 个反方向型
```

### 连续数值型 slot 处理规则（v2.4 新增）

当 slot 的值是连续数值（预算、金额、数量、时间长度等）时，**禁止用固定区间选项**：

- ❌ 错误: `["5000左右", "6000-7000", "7000-9000", "不限"]`
- ✅ 正确: 直接用自然语言提问，引导用户输入精确数值

示例:
- 预算: 「你的预算上限大概是多少？直接说数字就行，比如 4800、6500 等。」
- 时间: 「你有多少天准备时间？说个具体数字。」
- 人数: 「团队多少人？」

原因: 固定区间会丢失精度（4800 和 5500 都会被归到「5000左右」，但竞品范围完全不同），且用户的真实数字往往不在预设区间边界上。

示例：输入"我们团队要从单体架构迁移到微服务，团队8个人，预算有限"
- 通用型: "先梳理现有的架构和数据流" → 输出偏重诊断和迁移准备
- 具体型: "分阶段迁移，先迁非核心服务" → 输出偏重渐进式执行计划
- 反方向型: "评估是否真的需要微服务" → 输出偏重组决策和风险分析

## 渐进式交互深度（v2.3）

按 Level 分级，控制交互轮次和深度：

### Level 0 — 无交互
跳过所有上下文问题，直接输出升级版输入；必要信息用占位符表示。

### Level 1 — 最小交互（最多 1 问）
只问一个最关键问题，使用单选项模板。选中最影响输出质量的那个字段。
```text
问题: "你 [输入对象] 最关键的背景是？"
header: "快速确认"
选项:
  - "[从输入推导的选项 A]": [输出方向说明]
  - "[从输入推导的选项 B]": [输出方向说明]
```

### Level 2 — 最小必要交互（最多 1 问）
只问一个会反转或显著改变下游判断的问题；其他缺口使用占位符。
```text
问题: "关于 [输入对象]，你补充哪个会最影响判断？"
header: "关键约束"
选项:
  - "[维度 A]": [选择后的影响]
  - "[维度 B]": [选择后的影响]
  - "[维度 C]": [选择后的影响]
  - "[维度 D]": [选择后的影响]
```

### Level 3 — 深度交互（最多 2 问）
把最多两个决策关键问题放在同一轮中，避免连续打断：
```text
问题: "最后一个需要确认的事：[验证性提问]？"
header: "验证"
选项:
  - "[选项 A]": [输出影响]
  - "[选项 B]": [输出影响]
```
如果一个问题已经足够，只问一个。

## Common Templates

### High-Consensus Upgrade

```text
问题: "这个问题共识度很高，当前级别可能只能得到安全但平庸的回答。要升级吗？"
header: "共识预警"
选项:
  - "升级到 Level 2": 进入上下文补全和完整施压
  - "保持当前级别": 输出快速版本
```

### Level 1 Light Direction Check

Use only when intent confidence is low and the interpretations would materially change the prompt.

```text
问题: "我理解为：[1句重构]。方向对吗？"
header: "方向"
选项:
  - "对，继续": 进入下一阶段
  - "方向对，补充细节": 注入用户补充后继续
  - "偏了": 回到 Stage 1 重构，最多 1 次
```

### Level 2+ Direction Check

Use when the reframe may change the user's meaning, especially for irreversible decisions or value conflicts. Anxiety alone is not enough.

```text
问题: "重构后的核心问题是：[X]。这个方向对吗？"
header: "方向确认"
选项:
  - "对，继续优化": 进入 Stage 2
  - "偏了，我的重点是 [补充]": 回到 Stage 1，用新信息重构，最多 1 次
  - "差不多了，直接输出": 跳到 Stage 3 自检后输出
```

### Context Gap

```text
问题: "你这个 [具体对象] 最缺的是哪类约束？"
header: "补约束"
选项:
  - "[从原文推导的具体选项 A]": 选择后强化 [对应输出方向]
  - "[从原文推导的具体选项 B]": 选择后强化 [对应输出方向]
  - "[从原文推导的具体选项 C]": 选择后强化 [对应输出方向]
```

### Intent Confirmation

Prefer the full examples in `references/intent-details.md`. Keep choices concrete:

```text
问题: "你提到 [原文对象]，核心诉求更接近哪一个？"
header: "意图确认"
选项:
  - "[具体诉求 A]": 输出会偏向 [结果]
  - "[具体诉求 B]": 输出会偏向 [结果]
  - "[具体诉求 C]": 输出会偏向 [结果]
```

### Level 3 Path Choice

```text
问题: "选择路径（可多选），我会输出最终打磨好的问题"
header: "选择路径"
multiSelect: true
选项:
  - "A — [维度标签]": 风险判定: [可靠/有条件/高风险] | 反例: [摘要]
  - "B — [维度标签]": 风险判定: [可靠/有条件/高风险] | 反例: [摘要]
  - "C — [维度标签]": 风险判定: [可靠/有条件/高风险] | 反例: [摘要]（仅当存在路径C）
```

Put the lowest-risk path first and mark it as recommended in the option label when appropriate.

## Fallback Text Format

If a structured choice tool is unavailable:

```text
选择一个方向回复我：
A. [选项 A]
B. [选项 B]
C. [选项 C]

我会按你的选择继续；如果都不对，直接说你的真实重点。
```
