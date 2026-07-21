# SharpInput Orchestration

Use this file for non-trivial, scenario-heavy, or Level 2/3 requests. `SKILL.md` is the canonical contract; this file only expands its runtime workflow.

## State Initialization

Initialize the object defined in [`references/handoff-contract.md`](references/handoff-contract.md):

```json
{
  "raw_input": "",
  "target_input": "",
  "user_instruction": "",
  "task_mode": "prompt_optimization",
  "level": 1,
  "route": "quick_rewrite"
}
```

Extract only what the user supplied. Represent uncertainty explicitly instead of guessing.

## Canonical Flow

1. **Normalize**: isolate the input to optimize and any requested tone, depth, or format.
2. **Gate**: set `level` and the intended final route.
3. **Detect intent**: identify primary and optional secondary intent.
4. **Detect scenario**: run for known scenarios or whenever scenario slots could improve the prompt; leave it empty at low confidence.
5. **Complete context**: identify known facts, placeholders, and at most the allowed number of blocking questions.
6. **Select pressure**: write `pressure_requirements` before compilation. Skip when pressure adds no value.
7. **Compile**: produce `compiled_prompt_draft` using all selected requirements.
8. **Judge**: for Level 3, return the canonical `judge_result`; revise once when required.
9. **Quality check**: score internally and repair weak dimensions.
10. **Render**: write the final response at the depth required by the level.

## Route Map

| Route | Module order |
|---|---|
| `quick_rewrite` | intent -> optional scenario/context -> compiler -> renderer |
| `clarify_first` | intent -> scenario/context -> ask -> resume original route |
| `pressure_prompt` | intent -> scenario -> context -> pressure -> compiler -> renderer |
| `judge_mode` | intent -> scenario -> context -> pressure -> compiler -> judge -> renderer |

`clarify_first` is temporary. Preserve `resume_route` so a Level 2 request returns to `pressure_prompt` after the user answers.

## Question Policy

- Level 0: do not ask.
- Level 1: ask at most one question when the answer materially changes the prompt.
- Level 2: ask at most one question only when the missing value can reverse or invalidate the downstream decision; otherwise use placeholders.
- Level 3: ask at most two critical questions together. Do not collect optional context exhaustively.
- Any level: respect requests for speed or no questions by using placeholders.

Use [`references/interaction-patterns.md`](references/interaction-patterns.md) for choices. If an interactive choice tool is unavailable, ask in concise text.

## Feedback Loop

| User feedback | Return to |
|---|---|
| "偏了" | intent detection |
| "不是这个场景" | scenario detection |
| "没问到关键点" | context or scenario slots |
| "太普通" | pressure selection |
| "太复杂" | level/output depth reduction |
| "太强硬" | lower or remove pressure |

Update durable preferences only when the user previously opted in. Otherwise apply feedback only to the current conversation.

## Acceptance

Succeed only when the response contains a complete upgraded prompt, preserves the original intent, respects the interaction limit, and does not directly solve the underlying task by default.
