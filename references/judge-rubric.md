# Judge Rubric

Use Judge for Level 3, high-risk or hard-to-reverse decisions, useful multi-path analysis, or an explicitly requested stress test.

## Dimensions

Score each dimension from 1 to 5.

| Dimension | 1 | 3 | 5 |
|---|---|---|---|
| Intent fidelity | changes the user's goal | mostly aligned | preserves goal and nuance |
| Scenario fit | forces the wrong scenario | partly specific | matches known scenario facts |
| Context sufficiency | hides critical gaps | exposes some gaps | handles every critical gap |
| Constraint strength | vague or invented | usable | explicit and faithful |
| Pressure fit | absent or forced | useful but rough | improves quality without drift |
| Output readiness | fragmented | copyable with edits | directly copy-ready |
| Risk clarity | no meaningful boundary | generic warning | concrete flip condition or failure signal |

## Canonical Result

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

For multiple paths, return:

```json
{
  "judge_results": [
    {
      "path_id": "A",
      "verdict": "pass",
      "scores": {},
      "main_problem": "",
      "fix_instruction": "",
      "flip_condition": "",
      "risk_level": "low",
      "evidence_status": "not_applicable"
    }
  ]
}
```

Each `scores` object in `judge_results` must contain all seven dimensions from the canonical result.

## Verdict Policy

- Average `>= 4.0` and no rewrite trigger: `pass`.
- Average `3.5-3.9` or one local issue: `minor_fix`.
- Average `< 3.5` or any rewrite trigger: `rewrite_required`.

Return `rewrite_required` when the prompt changes the user's intent, invents important scenario facts, answers the underlying task, hides a critical gap, forces an unrequested conclusion, or is not copy-ready.

Set `evidence_status` to `unverified` rather than inventing a real-world example or factual claim.
