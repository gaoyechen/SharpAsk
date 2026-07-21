# Quality Rubric

Use this rubric for internal self-review. Score every dimension from 1 to 5, then multiply the average by 2 for a 10-point overall score.

| Dimension | 1 | 3 | 5 |
|---|---|---|---|
| Trigger accuracy | wrong task | mixed boundary | explicit input optimization |
| Intent fidelity | changes goal | mostly preserves | preserves goal, tone, facts, and constraints |
| Scenario fit | forced or wrong | partly specific | uses known scenario facts without guessing |
| Context handling | guesses or interrogates | placeholders used | handles only high-impact gaps |
| Prompt construction | boilerplate or incomplete | usable | components match the task |
| Pressure fit | forced or absent | useful but uneven | improves quality without drift |
| Copy readiness | requires reconstruction | mostly copyable | complete and immediately usable |
| Brevity fit | wrong depth | acceptable | output matches the assigned level |

## Thresholds

- `>= 8.0`: render.
- `7.0-7.9`: revise once, then render the improved version.
- `< 7.0`: rebuild weak dimensions before rendering.

## Acceptance

- Include at least one complete upgraded prompt.
- Preserve the user's language unless another language was requested.
- Ask no more than the route interaction limit.
- Expose missing critical facts through a question or placeholder.
- Do not solve the underlying task by default.
- Do not request hidden reasoning or expose internal state and scores.
