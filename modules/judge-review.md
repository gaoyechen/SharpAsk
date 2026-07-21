# Judge Review

Use Judge for Level 3, high-risk or hard-to-reverse decisions, genuinely useful multi-path analysis, or an explicit request to stress-test a prompt. Skip it for Level 0/1 polish.

## Inputs

- `raw_input`
- `compiled_prompt_draft` or `path_drafts`
- `known_context`
- `missing_fields`
- `pressure_requirements`

## Canonical Output

Return exactly the `judge_result` shape defined in [`references/judge-rubric.md`](../references/judge-rubric.md):

```json
{
  "verdict": "pass | minor_fix | rewrite_required",
  "scores": {
    "intent_fidelity": 0,
    "scenario_fit": 0,
    "context_sufficiency": 0,
    "constraint_strength": 0,
    "pressure_fit": 0,
    "output_readiness": 0,
    "risk_clarity": 0
  },
  "main_problem": "",
  "fix_instruction": "",
  "flip_condition": "",
  "risk_level": "low | conditional | high",
  "evidence_status": "verified | unverified | not_applicable"
}
```

For multiple paths, return the `judge_results` wrapper defined in the rubric, with one canonical result object per path.

## Rules

- Use [`references/judge-rubric.md`](../references/judge-rubric.md) for scores and verdicts.
- Use [`references/judge-prompt.md`](../references/judge-prompt.md) when an independent reviewer is available.
- If `verdict` is `minor_fix`, patch once and recheck the affected dimensions.
- If `verdict` is `rewrite_required`, return to context or compiler according to `fix_instruction`.
- Never invent a real-world counterexample. Mark `evidence_status` as `unverified` when evidence cannot be checked.
- If an independent reviewer is unavailable, perform the same schema-based review inline; do not invent a different fallback format.
