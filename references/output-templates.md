# Output Templates

Put the copy-ready prompt first. Include supporting information only when it helps the user fill placeholders or choose between meaningful alternatives.

## Level 0

```text
> [Complete upgraded prompt]
```

Optionally add one short note when a placeholder needs explanation.

## Level 1

```text
[升级版输入]
> [Complete upgraded prompt]

[关键改动]
[One concise sentence]
```

## Level 2

```text
[升级版输入]
> [Complete upgraded prompt]

[待替换信息]
- [Only material placeholders]

[取舍]
[One concrete trade-off introduced by the prompt]
```

Omit `[待替换信息]` when no material placeholders remain.

## Level 3

```text
[路径 A：label]
> [Complete prompt A]
Judge: pass | minor_fix | rewrite_required
风险: low | conditional | high
翻转条件: ...

[路径 B：label]
> [Complete prompt B]
Judge: pass | minor_fix | rewrite_required
风险: low | conditional | high
翻转条件: ...

[默认推荐]
[Choose one path and state the deciding trade-off]
```

Include Path C only when it is materially different. Derive every Judge field from the canonical `judge_result`; never expose scores or raw review traces.

## Rules

- Keep the user's language unless another language was requested.
- Always include at least one complete upgraded prompt.
- Use `[方括号占位符]` for missing information.
- Use one consistent quote-block or plain-text presentation.
- Do not emit empty metadata sections, internal scores, module state, or hidden reasoning.
- Do not make users read a diagnostic report before reaching the prompt.
- Use "默认答案压力测试" only when it was actually applied.
