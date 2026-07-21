# Output Renderer

Render the final response without adding new analysis.

## Inputs

- `level`
- `primary_intent`
- `scenario`
- `context_status`
- `compiled_prompt_draft` or `path_drafts`
- `missing_placeholders`
- `judge_result` or `judge_results`
- `risk_notes`

## Output By Level

### Level 0

Return the complete upgraded prompt. Add at most one short note when a placeholder needs explanation.

### Level 1

Return the upgraded prompt, followed by a concise summary of the most important additions.

### Level 2

Return the upgraded prompt, then list only material assumptions/placeholders and one trade-off note.

### Level 3

Return two or three paths only when they are materially different. For each path, include the complete prompt and a concise summary derived from the canonical `judge_result`. Recommend a default path and explain the deciding trade-off.

## Rules

- Put the copy-ready prompt before supporting commentary.
- Keep the user's language unless another language was requested.
- Use one consistent quote block or plain-text presentation for the prompt.
- Never output handoff JSON, internal quality scores, hidden reasoning, or raw Judge traces.
- Do not include empty sections such as "场景：未知" or "最小补充项：无".
- Do not require SharpInput branding or a diagnostic report for quick requests.
- When placeholders remain, name only those that materially affect the downstream answer.
