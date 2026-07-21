# Handoff Contract

Maintain one internal state object across SharpInput capabilities. Do not expose this object to the user.

## Canonical Object

```json
{
  "raw_input": "",
  "target_input": "",
  "user_instruction": "",
  "task_mode": "prompt_optimization",
  "ambiguity_level": "low | medium | high",
  "level": 1,
  "route": "quick_rewrite | clarify_first | pressure_prompt | judge_mode",
  "resume_route": "",
  "primary_intent": "",
  "secondary_intent": "",
  "intent_confidence": "high | medium | low",
  "scenario": "",
  "scenario_confidence": "high | medium | low",
  "slot_template": "",
  "known_context": {},
  "missing_fields": [],
  "blocking_fields": [],
  "slot_questions": [],
  "clarified_dimensions": [],
  "context_status": "complete | partial | insufficient",
  "placeholder_strategy": true,
  "pressure_requirements": [],
  "overpressure_risk": "low | medium | high",
  "compiled_prompt_draft": "",
  "path_drafts": [],
  "missing_placeholders": [],
  "fidelity_check": {
    "status": "pass | minor_drift | fail",
    "notes": []
  },
  "quality_score": {
    "overall": 0.0,
    "weak_dimensions": []
  },
  "judge_result": {},
  "judge_results": [],
  "risk_notes": [],
  "final_prompt": ""
}
```

## Lifecycle

1. Normalization sets the raw and target inputs.
2. Gate sets `level`, `route`, and optional `resume_route`.
3. Intent detection sets intent and confidence.
4. Scenario detection sets scenario, slot template, and confidence when useful.
5. Context completion sets known context, missing/blocking fields, placeholders, and questions.
6. Pressure selection writes `pressure_requirements` and `overpressure_risk`.
7. Compiler consumes those requirements and writes the prompt draft or path drafts.
8. Fidelity and quality checks write their results.
9. Judge writes `judge_result` or `judge_results` for Level 3.
10. Renderer writes the final user-facing response.

## Merge Rules

- Preserve earlier fields unless later user evidence proves them wrong.
- Use arrays for missing fields, questions, requirements, paths, and risks.
- Mark uncertainty rather than guessing.
- Do not run Compiler before pressure selection on Pressure or Judge routes.
- When `clarify_first` is active, keep the intended final route in `resume_route`.
- If a capability is unavailable, retain the canonical schema and record the downgrade in `risk_notes`.
