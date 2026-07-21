# SharpInput Self-Learning System (v2.5+)

## Overview

Use durable preference learning only after the user explicitly opts in. Without opt-in, adapt within the current conversation and perform no preference-file reads or writes.

After opt-in, record only user-provided choices and feedback. On later invocations, read preferences to personalize the flow.

**Storage**: user-local runtime state, not the published skill package.

Recommended locations:

1. Hermes profile data file: `$HERMES_HOME/data/sharpinput/user-preferences.json`
2. If `$HERMES_HOME` is unavailable: the active agent/profile data directory equivalent
3. If durable file storage is unavailable: skip self-learning silently and run with no preferences

Store consent in the preference file. Treat legacy files without `consent.enabled: true` as not opted in.

The repository ships only:

- `references/user-preferences.schema.json` — JSON schema
- `references/user-preferences.example.json` — empty/sanitized example

Never commit a real user's `user-preferences.json`. Runtime preferences are private local state.

**Migration note**: If an old install has `references/user-preferences.md` or `references/user-preferences.json` with data, migrate it once into the user-local runtime state path above, then remove it from the installed skill package.

---

## JSON Schema

用户偏好文件使用严格的 JSON 格式，终结 Markdown 格式漂移问题。

### 文件结构

```json
{
  "schema_version": "1.0",
  "last_updated": "2026-05-07",
  "consent": {"enabled": true, "granted_at": "2026-05-07"},
  "history": [ ... ],
  "summary": { ... }
}
```

### history 条目字段

#### All Levels (0/1/2/3)

| Field | Type | Example | Required |
|-------|------|---------|----------|
| timestamp | string | "2026-05-02" | yes |
| level_used | int | 3 | yes |
| level_assigned | int | 2 | yes |
| level_upgraded | bool | true | no |
| intent_primary | string | "决策" | yes |
| intent_secondary | string | "分析" | no |
| language | string | "zh" | yes |

#### Level 2+ Additional

| Field | Type | Example |
|-------|------|---------|
| pressure_strategy | string | "regret pre-mortem" |
| strategy_skipped | string \| null | null |

#### Level 3 Additional

| Field | Type | Example |
|-------|------|---------|
| angle_selected | string | "risk-first" |
| paths_presented | string[] | ["risk-first", "counter-intuitive", "minimalist"] |
| user_choice | string | "single" / "combination" |
| choice_detail | string | "B: counter-intuitive" |
| feedback | string \| null | "great" / "off track" / null |

#### Outcome Tracking (v2.4+)

| Field | Type | Example |
|-------|------|---------|
| outcome_score | int \| null | null (未追踪), 1-5 (见输出效果追踪) |
| outcome_note | string \| null | "AI回答质量明显提升" |

#### Reflection (v2.5+ — Reflective Evolution)

Only present when `outcome_score` is 1 or 2 and reflective diagnosis was triggered.

| Field | Type | Example |
|-------|------|---------|
| reflection | object \| null | see below |

```json
{
  "failure_cause": "intent_misidentification | scenario_mismatch | over_pressure | context_gap | generic_output | unknown",
  "diagnosis": "用户想问技术选型，但被识别为产品决策，导致优化方向偏了",
  "auto_action": "updated correction_map: '技术选型' → '分析'",
  "confidence": "high | medium | low"
}
```

#### Confirmed Context

| Field | Type | Example |
|-------|------|---------|
| context_role | string \| null | "产品经理" |
| context_tech_stack | string \| null | "React + Python" |
| context_budget | string \| null | "~6000" |
| context_team_size | int \| null | 8 |
| context_domain | string \| null | "互联网/Web开发" |
| context_constraints | string \| null | "预算有限、短期出成果" |

### summary 字段

| Field | Type | Example |
|-------|------|---------|
| level_bias | object | {"total_sessions": 9, "level_distribution": {"0":0,...,"3":9}, "top_level_pct": 100} |
| angle_preference | string[] | ["risk-first", "adversarial", "counter-intuitive"] |
| intent_history | object | {"决策": 5, "分析": 3} |
| correction_map | object | {"模式A": "正确意图A"} |
| intent_priming | object\|null | {"primary_intent_top3": ["决策","分析","验证"], "corrections": {}} |
| context_autofill | object | {"role": "产品经理", "tech_stack": "React + Python"} |
| outcome_stats | object\|null | {"avg_score": 4.2, "positive_ratio": 0.8, "tracked_count": 5} |
| reflection_stats | object\|null | {"total_reflections": 3, "top_cause": "intent_misidentification", "auto_corrections": 2} |

### outcome_stats 字段（v2.4+）

| 子字段 | 类型 | 说明 |
|--------|------|------|
| avg_score | float | 所有已追踪的效果评分平均值（1.0-5.0） |
| positive_ratio | float | 评分 ≥ 4 的条目占比 |
| tracked_count | int | 有 outcome_score 的条目数 |
| best_intent | string | 评分最高的意图类型 |
| worst_intent | string | 评分最低的意图类型 |

### reflection_stats 字段（v2.5+）

| 子字段 | 类型 | 说明 |
|--------|------|------|
| total_reflections | int | 触发反思诊断的总次数 |
| top_cause | string | 出现最多的 failure_cause 类型 |
| auto_corrections | int | 自动修正成功执行的次数 |
| persistent_issues | string[] | 连续3次反思未改善的 failure_cause 列表 |

完整 JSON 结构示例见 `user-preferences.example.json`；字段约束见 `user-preferences.schema.json`。

---

## When to Write — Explicit Opt-In Required

After producing the final prompt:
1. Confirm that the user explicitly enabled durable SharpInput preferences.
2. Resolve the user-local runtime state file path, preferably `$HERMES_HOME/data/sharpinput/user-preferences.json`.
3. If the file does not exist, initialize it from `references/user-preferences.example.json` and set `consent.enabled` plus `consent.granted_at`.
4. Extract only applicable, user-provided fields from this session.
5. Append the session data to `history` and keep the last 10 entries.
6. Recalculate `summary`, update `last_updated`, and validate the JSON object.
7. Write only to the runtime state path; never write private preferences into `references/`.

If consent is absent, false, or ambiguous, skip all persistence without prompting during an unrelated request.

### Post-Interaction 效果追踪（可选扩展）

不在输出阶段执行。而是在用户后续回来说"上次你帮我优化的那个问题……"时追踪效果：

| 触发模式 | 提取字段 | 更新方式 |
|---------|---------|---------|
| 用户主动反馈（"上次那个问题好/不好"） | outcome_score (1-5), outcome_note | 查找最后一次同意图的历史条目，更新 |
| 用户用优化后的问题获得AI回答后回来说结果 | Ask for or record an explicit 1-5 score; do not infer a numeric score from tone | 同上 |
| 跨会话效果对比（"比上次更好了"） | 无需更新，已记录在 timestamp | 用于 summary 效果趋势分析 |

效果追踪触发后即时更新 history 中对应条目。

### Reflective Evolution（v2.5+ — 反思式进化）

当 `outcome_score` 为 1 或 2 时，**自动触发反思诊断**。这是从"被动记录"到"主动诊断"的升级。

#### 触发条件

- explicit `outcome_score` ≤ 2
- 或用户反馈包含以下模式："效果不好"、"更差了"、"偏了"、"完全不对"、"答非所问"

#### 反思诊断流程

Step 1: **归因分析** — 判断失败属于哪个环节

| failure_cause | 判断依据 | 典型表现 |
|--------------|---------|---------|
| `intent_misidentification` | 用户说"不是这个意思"或纠正了意图 | 优化方向与用户期望完全不一致 |
| `scenario_mismatch` | 场景模板被错误应用或缺少匹配场景 | 优化后的prompt带了不相关场景的约束 |
| `over_pressure` | 用户说"太强硬"、"太偏激"、"不需要这么极端" | 压力策略过度，改变了用户原始意图 |
| `context_gap` | 用户说"没问到关键点"、"缺了重要信息" | 关键上下文缺失导致prompt空洞 |
| `generic_output` | 用户说"太泛了"、"跟没优化一样" | 优化后prompt仍有大量通用表述 |
| `unknown` | 无法归因 | 多因素混合或用户反馈模糊 |

Step 2: **自动修正** — 根据归因执行对应修正动作

| failure_cause | 自动修正动作 |
|--------------|-------------|
| `intent_misidentification` | 更新 `correction_map`：将本次输入模式→正确意图的映射写入 |
| `scenario_mismatch` | 在该场景模板上标记 `mismatch_count +1`；≥3次时标记为"待审查" |
| `over_pressure` | 降低当前 `pressure_strategy` 的优先级；记录到 `strategy_penalty` |
| `context_gap` | 将缺失的关键字段加入该意图的 `required_fields` 列表 |
| `generic_output` | 在该意图类型的编译规则中增加"禁止通用表述"的强化约束 |
| `unknown` | 仅记录，不做自动修正 |

Step 3: **记录反思结果** — 写入 history 对应条目的 `reflection` 字段

Step 4: **更新 summary** — 在 `reflection_stats` 中累计统计

#### 反思结果的消费

反思产生的修正数据在后续 session 中被自动消费：

- `correction_map` 更新 → 影响 Intent Priming（已有机制，自然生效）
- `strategy_penalty` → 在 Pressure Strategy 路由时降低被罚策略的优先级
- `required_fields` 补充 → 在 Context Completion 阶段提高这些字段的询问权重
- `mismatch_count` → 在 Scenario Detection 阶段增加对该场景的审查力度

#### 反思限制

- 每次反思只产生 **一个** `failure_cause`，不做多重归因（避免噪音）
- `confidence` 为 `low` 时，不做自动修正，仅记录
- 反思不会覆盖用户的直接反馈（如用户说"重置偏好"，反思数据也一并清除）
- 连续 3 次反思同一 `failure_cause` 且自动修正未改善 → 标记为 `persistent_issue`，在下次输出时提醒用户

### 写入规则

- **直接操作 JSON 对象**，不要手动拼接字符串。使用 JSON.parse + JSON.stringify 逻辑。
- `schema_version` 保持不变（仅在架构升级时更新）。
- `history` 是数组，新条目 append，最旧条目自动弹出（窗口限10）。
- 每次写入后验证 JSON 结构完整性。

---

## When to Read

After Gate, before Intent Recognition:
1. Read durable preferences only when the current user previously opted in.
2. Resolve the runtime preference path and verify `consent.enabled: true` before applying `summary`.
3. If the file or consent marker is absent, skip self-learning with no warning.
4. Do not migrate a legacy file until the user explicitly opts in.

### 读取规则

- 如果文件读取失败（格式错误），降级为无偏好的正常流程
- 如果 `schema_version` 不支持，忽略 `history`，只读取 `summary`
- 始终检查字段存在性再使用

---

## Preference Application Rules

### Default Level Bias
- If ≥70% of last 10 sessions used Level 3 → when Gate assigns Level 1/2, suggest upgrade
- If ≥70% used Level 2 → default hint is Level 2
- Otherwise → no bias, follow Gate's assignment

### Angle Preference
- In Stage 3, generate at least 1 path with the user's top-2 angle tags
- The other paths should explore different angles for diversity

### Forcing Strategy Adjustment
- If a strategy was skipped in ≥50% of sessions where it was applied → lower its priority
- Never remove a strategy entirely; only reduce emphasis

### Recommendation Bias
- In Stage 5 selection prompt, recommend the path whose angle tag matches user's top preference
- If credibility conflicts with preference, show both: "根据偏好推荐 Path A，但 Path B 可信度更高"

### Feedback Integration
- "great" feedback → boost the selected angle tag + intent combination as a strong positive signal
- "off track" → record as negative signal; in next session with similar intent, avoid that angle tag

### Negative Pattern Detection (v2.4+)
- If an angle tag gets "off track" feedback ≥2 times → add to `avoided_angles` in summary
- When generating paths, skip avoided angles unless explicitly requested
- Reset avoided angles on "重置偏好"

### Intent Priming（v2.3）

从历史记录中提取意图偏好，用于偏置当前轮次的意图识别：

- 如果最近 10 次中 ≥60% 共享同一个主意图，该意图置信度 +0.1
- 如果当前输入信号模糊（关键词匹配得分 0.3-0.7），优先选择用户历史 top-3 意图
- 记录意图修正：当用户通过结构化选择或文字回复纠正意图时，将该输入模式→正确意图的映射记录到 `correction_map` 字段

### Context Auto-Fill（v2.3）

当意图专属上下文规则要求询问某一字段，而该字段的值已存在于用户偏好记录中时：

1. **自动填充**该字段，不在交互中重复提问
2. 在最终输出中标注：`根据你的记录，[value]（可调整）`
3. 如果用户在本次交互中调整了该值，更新偏好记录
4. 可自动填充的字段：role, tech stack, budget, team size, domain, common constraints

在打开输出时同步执行：扫描最终优化问题中的 `[xxx]` 占位符，如果用户偏好中有匹配的字段值，自动替换。

---

## Sliding Window

- Keep only the last 10 interaction records
- When adding the 11th, remove the oldest (index 0)
- All statistics (percentages, top preferences) are calculated from the window
- `summary.level_bias.level_distribution` sums to exactly the window size

---

## Preference Reset

If user says "重置偏好" / "reset preferences":
- Resolve the runtime preference file path, preferably `$HERMES_HOME/data/sharpinput/user-preferences.json`
- Clear the `history` array
- Clear `summary` to defaults from `references/user-preferences.example.json`
- Write the reset JSON to the runtime path only
- Confirm: "偏好已重置。" / "Preferences reset."
