# Privacy and Local State

SharpInput is a prompt/input optimization skill. Durable preference learning is disabled by default and requires explicit user opt-in. Real user preference history must never be published or committed.

## What the repository contains

The public repository only contains sanitized state definitions:

```text
references/user-preferences.schema.json
references/user-preferences.example.json
```

These files are safe to commit because they contain schema/default structure, not personal history.

## What must stay local

After opt-in, real runtime preference data should be stored in the active user's local agent/profile data directory. For Hermes, for example:

```text
$HERMES_HOME/data/sharpinput/user-preferences.json
```

For Codex or another host, use that host's user-local profile data directory. Never use the skill installation directory as runtime storage.

Before reading or writing a preference file, verify:

```json
{"consent":{"enabled":true,"granted_at":"..."}}
```

Treat missing or legacy consent data as not opted in.

Do **not** write private preferences into:

```text
references/user-preferences.json
```

That path is ignored by git and reserved only as a legacy migration source for older installs.

## Why this matters

Keeping runtime state outside the skill package prevents:

- leaking the author's personal usage history into the public repo
- new users inheriting someone else's preferences
- skill updates overwriting user preferences
- multiple Hermes profiles sharing the wrong state
- dirty git working trees after normal skill usage

## Resetting preferences

If the user says "重置偏好" or "reset preferences", clear the runtime file contents back to the empty example shape. This action is allowed even when durable learning is currently disabled.

CLI reset example:

```bash
mkdir -p "$HERMES_HOME/data/sharpinput"
cp references/user-preferences.example.json "$HERMES_HOME/data/sharpinput/user-preferences.json"
```

Or delete the file and let SharpInput run with no preferences:

```bash
rm -f "$HERMES_HOME/data/sharpinput/user-preferences.json"
```

## Legacy migration

Older SharpInput versions stored preferences under:

```text
references/user-preferences.json
references/user-preferences.md
```

If either file exists in an installed package and contains real data, ask for opt-in before migration. After consent:

1. Copy it once into the runtime state path.
2. Validate or normalize it against `references/user-preferences.schema.json`.
3. Remove the legacy file from the installed skill package.
4. Never commit the migrated runtime file.

## Data handling promise

SharpInput does not require network upload of preference data. It must not infer numeric outcome scores from tone, and it must not read, create, migrate, or update durable preference state without explicit opt-in.
