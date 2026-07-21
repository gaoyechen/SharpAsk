# Prompt Compiler

Compile the upgraded prompt after intent, context, and pressure selection are complete.

## Inputs

- `target_input`
- `primary_intent`
- `secondary_intent`
- `scenario`
- `known_context`
- `missing_fields`
- `clarified_dimensions`
- `pressure_requirements`

## Output

```json
{
  "compiled_prompt_draft": "",
  "missing_placeholders": [],
  "compile_notes": []
}
```

## Component Selection

Use only components that improve this task:

- **Task goal**: always state it clearly.
- **Context and constraints**: include known facts; expose important unknowns with `[方括号占位符]`.
- **Role or perspective**: include only when expertise or viewpoint changes the answer quality.
- **Evaluation criteria**: include for decisions, reviews, comparisons, and generation tasks with acceptance standards.
- **Output format**: include when structure, length, or machine readability matters.
- **Rationale and evidence**: for analysis or judgment, request concise reasons, evidence, assumptions, and verification steps. Never request hidden chain-of-thought or a full internal reasoning process.
- **Examples**: include only when they disambiguate the expected result.
- **Pressure requirements**: inject only the requirements already selected by `pressure-strategy`.

## Optional Structure

For complex tasks, use descriptive sections such as:

```text
[Direct task instruction]

Context and constraints:
...

Evaluation criteria:
...

Output format:
...

Boundaries and verification:
...
```

Do not force this structure on simple wording edits. Headings, numbered steps, roles, examples, and notes are optional rather than Level-based requirements.

## Intent-Specific Rules

- Decision/comparison: request a recommendation, trade-offs, and a flip condition when context supports them.
- Analysis/review: request prioritized findings tied to evidence and impact.
- Generation: specify audience, boundaries, output format, and acceptance criteria.
- Diagnosis: distinguish observed evidence, hypotheses, and next checks.
- Light rewrite/translation: preserve tone and remain concise.

## Final Checks

- Do not answer the underlying task.
- Do not invent facts or a desired conclusion.
- Avoid generic phrases such as "根据我的需求" when the needs are not stated.
- Do not ban vague answers through boilerplate when concrete criteria already prevent vagueness.
- Make the entire result directly copyable.
