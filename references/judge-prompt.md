# Judge Prompt

Use this template when an independent reviewer is available. Fill the placeholders and request JSON only.

## Inputs

- `{{ORIGINAL_INPUT}}`: the user's original input
- `{{KNOWN_CONTEXT}}`: known facts only
- `{{PROMPT_DRAFTS}}`: one prompt draft or labeled path drafts

## Template

```text
Act as an independent reviewer of optimized prompts. Review the draft without solving the user's underlying task.

Original input:
{{ORIGINAL_INPUT}}

Known context:
{{KNOWN_CONTEXT}}

Draft or paths:
{{PROMPT_DRAFTS}}

Score each draft from 1 to 5 on:
- intent_fidelity
- scenario_fit
- context_sufficiency
- constraint_strength
- pressure_fit
- output_readiness
- risk_clarity

Check whether the draft changes intent, invents facts, hides a critical gap, forces a conclusion, overuses pressure, or fails to provide a copy-ready prompt. Give a concrete flip condition when one exists. Do not invent real-world evidence; use evidence_status="unverified" when evidence cannot be checked.

Verdict rules:
- pass: average >= 4.0 and no rewrite trigger
- minor_fix: average 3.5-3.9 or one local issue
- rewrite_required: average < 3.5 or any rewrite trigger

Return valid JSON only. For one draft, return:
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

For multiple paths, return {"judge_results": [...]} and add path_id to every result. Each result must contain the same fields and all seven scores.
```

## Fallback

If an independent reviewer is unavailable or returns invalid JSON, perform one inline review using the same schema. Do not switch to a prose-only report or expose raw Judge output to the user.
