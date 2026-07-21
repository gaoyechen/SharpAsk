# Scenario Slot Elicitation

Ask for the highest-impact scenario variables, not generic background.

## Inputs

- `scenario`
- `slot_template`
- `known_context`
- `user_instruction`

## Output

```json
{
  "missing_fields": [],
  "slot_questions": [],
  "placeholder_strategy": true
}
```

## Rules

- Respect the route interaction limit: none at Level 0, at most one at Level 1/2, and at most two critical slots at Level 3.
- Prefer slots marked `required` in `references/scenario-slot-templates.md`.
- If the user says "直接给/别问", use placeholders instead of asking.
- Do not ask for slots already present in the user's input.
- If all critical slots are missing and output quality would collapse, ask only the highest-impact slots allowed by the route, then use placeholders for the rest.

## Ask Format

Use the interaction patterns in `references/interaction-patterns.md`. Prefer an available structured choice tool; otherwise ask concise text.
