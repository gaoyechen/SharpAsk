# Regression Cases

Run these cases after changing runtime instructions. Exact wording may vary; route, interaction limit, and behavioral invariants must match.

| ID | Input | Trigger | Level | Final route | Scenario | Max questions | Pressure | Judge |
|---|---|---:|---:|---|---|---:|---|---|
| R1 | 帮我优化：我想买电脑，怎么问 AI？ | yes | 1 | `quick_rewrite` | `computer_purchase` | 1 | none/light | no |
| R2 | 帮我优化：ChatGPT Plus 和 Claude Pro 选哪个？ | yes | 2 | `pressure_prompt` | `ai_subscription_choice` | 1 | strong | no |
| R3 | 这个页面看起来很乱，帮我改成好 prompt | yes | 1 | `quick_rewrite` | `ui_review` | 1 | none/light | no |
| R4 | 我要让 AI 写 PRD，怎么问？ | yes | 1 | `quick_rewrite` | `prd_srs_generation` | 1 | none/light | no |
| R5 | 帮我写一个 prompt 严格评审这个高投入产品方案 | yes | 3 | `judge_mode` | `product_plan_review` | 2 | medium/strong | yes |
| R6 | 帮我优化：做一个 SaaS dashboard demo | yes | 1 | `quick_rewrite` | `frontend_demo_generation` | 1 | none/light | no |
| R7 | 怎么学 RUP？帮我优化成 AI 提问 | yes | 0/1 | `quick_rewrite` | `learning_exam_prep` or empty | 0/1 | none | no |
| R8 | 把这个问题变强一点：我们应该重构吗？ | yes | 2 | `pressure_prompt` | empty unless context matches | 1 | strong | no |
| R9 | 直接帮我调这个 bug | no | n/a | n/a | n/a | n/a | n/a | n/a |
| R10 | 帮我润色这段发给老板的话 | yes | 1 | `quick_rewrite` | empty | 1 | none | no |
| R11 | 帮我优化并直接回答：这个架构该不该重构？ | yes/mixed | n/a | clarify priority | empty | 1 | none before clarification | no |
| R12 | 别问，直接把“买哪个会员”改成 prompt | yes | 2 | `pressure_prompt` | `ai_subscription_choice` | 0 | strong | no |

## Invariants For Every Triggered Case

- Preserve the underlying user goal.
- Output at least one complete copy-ready prompt.
- Do not directly solve the underlying task by default.
- Run scenario/context before pressure, and pressure before compiler on Level 2/3 routes.
- Ask no more than the route limit; honor explicit no-question requests.
- Use placeholders instead of invented facts.
- Request concise rationale or evidence when useful, never hidden reasoning.
- Keep Judge output compatible with `references/judge-rubric.md`.
- Keep output depth proportional to the level.
