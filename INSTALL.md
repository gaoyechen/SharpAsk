# Install SharpInput

Install the runtime subset rather than copying the entire repository. The runtime package contains:

```text
sharpinput/
├── SKILL.md
├── AGENT.md
├── agents/
├── modules/
└── references/
```

Repository documentation, examples, tests, demo assets, and archives are not runtime dependencies.

## Hermes Agent

### Windows PowerShell

From the parent directory of the cloned `SharpInput` repository:

```powershell
$dest = Join-Path $env:LOCALAPPDATA "hermes\skills\sharpinput"
New-Item -ItemType Directory -Force $dest | Out-Null
Copy-Item SharpInput\SKILL.md, SharpInput\AGENT.md -Destination $dest -Force
Copy-Item SharpInput\agents, SharpInput\modules, SharpInput\references -Destination $dest -Recurse -Force
```

### macOS, Linux, Or Git Bash

```bash
dest="${HERMES_HOME:-$HOME/.hermes}/skills/sharpinput"
mkdir -p "$dest"
cp SharpInput/SKILL.md SharpInput/AGENT.md "$dest/"
cp -R SharpInput/agents SharpInput/modules SharpInput/references "$dest/"
```

Reload skills in an existing Hermes session:

```text
/reload-skills
```

Then run:

```text
/skill sharpinput
```

## Codex

Install the same runtime subset under `$CODEX_HOME/skills/sharpinput`. When `CODEX_HOME` is unset, use `~/.codex/skills/sharpinput`.

### Windows PowerShell

```powershell
$root = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$dest = Join-Path $root "skills\sharpinput"
New-Item -ItemType Directory -Force $dest | Out-Null
Copy-Item SharpInput\SKILL.md, SharpInput\AGENT.md -Destination $dest -Force
Copy-Item SharpInput\agents, SharpInput\modules, SharpInput\references -Destination $dest -Recurse -Force
```

### macOS Or Linux

```bash
dest="${CODEX_HOME:-$HOME/.codex}/skills/sharpinput"
mkdir -p "$dest"
cp SharpInput/SKILL.md SharpInput/AGENT.md "$dest/"
cp -R SharpInput/agents SharpInput/modules SharpInput/references "$dest/"
```

Start a new Codex task after installation so the skill catalog reloads.

## Verify

Use an explicit invocation first:

```text
Use $sharpinput to improve this request: 我想买电脑，怎么选？
```

A healthy installation should:

- load one skill named `sharpinput`
- output a complete upgraded prompt before supporting commentary
- identify the purchase scenario without inventing budget or usage
- use placeholders or at most one blocking question
- avoid directly recommending a computer

Internal modules must not appear as separate skills.

## Upgrade

Before replacing an older folder named `SharpInput` or `sharpinput`, move it to a backup outside the active `skills` directory. Then create a fresh lowercase `sharpinput` directory and copy only the runtime subset above. This prevents stale files from older layouts from remaining active.

## Troubleshooting

### Skill Does Not Trigger

Check that:

1. The folder is named `sharpinput`.
2. `SKILL.md` is directly inside that folder.
3. The current task/session was started after installation or skills were reloaded.
4. The request explicitly asks to improve the input itself rather than execute the underlying task.

### Too Many SharpInput Entries

Remove old layouts containing nested `skills/*/SKILL.md`. The current package has only one `SKILL.md`.

### Preferences

Durable preferences are disabled by default. SharpInput may create or read a user-local preference file only after explicit opt-in. See [`PRIVACY.md`](PRIVACY.md).
