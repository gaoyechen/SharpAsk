# Context Completion

Identify only the missing information that materially improves the upgraded prompt.

## Inputs

- `level`
- `primary_intent`
- `secondary_intent`
- `target_input`
- `known_context`
- `scenario`
- `user_instruction`

## Generic Fields

- goal
- audience
- constraints
- output format
- evaluation criteria
- attempted solutions
- unacceptable outcomes

## Output

```json
{
  "context_status": "complete | partial | insufficient",
  "known_context": {},
  "missing_fields": [],
  "blocking_fields": [],
  "slot_questions": [],
  "placeholder_strategy": true,
  "resume_route": ""
}
```

## Rules

- Do not ask for information already present in the user's input.
- Do not ask for a generic bundle such as "背景、目标和场景是什么".
- Mark a field as blocking only when different values could materially reverse, invalidate, or misdirect the downstream result.
- Level 0: ask nothing; use placeholders when needed.
- Level 1: ask at most one blocking question; otherwise compile immediately.
- Level 2: ask at most one blocking question. Partial context alone is not blocking; use placeholders for non-critical gaps and preserve `pressure_prompt` as `resume_route`.
- Level 3: ask at most two decision-critical questions in one turn. Do not require optional fields to be complete.
- If the user requests speed or no questions, ask nothing at every level and use explicit placeholders.
- For decision or purchase prompts, treat a non-negotiable constraint as high impact, but do not assume it is always blocking.
- When asking, explain in one short phrase why the answer changes the resulting prompt.
