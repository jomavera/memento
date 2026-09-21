# Memento for opencode

Memento ships as a Claude Code plugin, but its substance lives in
`skills/memento/` — a canonical [Agent Skills](https://agentskills.io) bundle
that is harness-agnostic by construction. This directory builds an
[opencode](https://opencode.ai) front end for it.

```sh
./opencode/install.sh                    # install
./opencode/install.sh --language Spanish # set the default document language
./opencode/install.sh --dry-run          # show what would be written
```

Restart opencode afterwards — config is read once at startup and is not
hot-reloaded. Then `/session-start`, `/session-close`, `/session-init`,
`/project-brief` and `/memento-doctor` are available.

## What gets installed

Into `$OPENCODE_CONFIG_DIR`, else `~/.config/opencode` — **not** `~/.opencode`,
which opencode ignores for configuration:

| Path | What |
|---|---|
| `skill/memento/` | The bundle, copied verbatim |
| `command/<name>.md` | One thin wrapper per procedure, five in total |
| `agent/memento-brief.md` | Read-only agent behind `/project-brief` |

`skill/memento/` is a **build artifact**: re-run the installer after editing
`skills/memento/`, and never edit the installed copy.

## How it works

The installer ports nothing. Every path inside the bundle is relative to the
bundle root and there are no variables to substitute, so it copies across
unchanged — the same bytes Claude Code reads.

What differs between harnesses is supplied separately, as a short **harness
context** block. That is all a generated command is:

```markdown
---
description: Open a traceable work session — ...
---

Harness context:
- Argument: $ARGUMENTS
- Default document language: English
- Conversation id: opencode exposes none to a command, so leave
  `claude_session_ids` empty (conventions §8)
- Bundle root: `/home/you/.config/opencode/skill/memento`

Follow `<bundle>/references/session-start.md` in full. ...
```

The Claude Code plugin does exactly the same thing in `skills/<name>/SKILL.md`,
with `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_SESSION_ID}` and the plugin's user
config filling the same three slots. Two front ends, one bundle, no fork.

Command descriptions are read from the Claude Code wrappers, so both builds
describe each command with the same sentence.

Before installing, the script checks that the bundle contains no
harness-specific interpolation anywhere. That invariant is what makes the bundle
portable, so a regression upstream fails the install rather than shipping a
bundle whose paths silently do not resolve.

### Why the bundle goes in a skill folder

A skill folder is opencode's native home for resource files: its loader lists
every file under a skill's directory and hands the model that list along with
the directory path. It also earns a permission — opencode automatically grants
every agent `external_directory` access to `skill/memento/*`, so commands read
the bundle without a prompt. A folder anywhere else would be asked about on
every session.

It also means `/memento` itself is available in opencode as a reference skill,
for questions about how `docs/ai/` is structured.

## What differs from the Claude Code build

Both builds run the same procedures and produce an identical `docs/ai/`. Three
things could not carry across.

**`/memento:doctor` becomes `/memento-doctor`.** opencode commands are flat and
have no `:` namespace.

**Tool restrictions are dropped, except one.** opencode command frontmatter
accepts only `description`, `agent`, `model`, `variant` and `subtask`, so the
`allowed-tools` the Claude wrappers declare have no equivalent. The restriction
that carried a guarantee — `/project-brief` never writing — is restored by
running that command under the `memento-brief` agent, which denies `edit`,
`write`, `apply_patch` and `task` and allows only read-only `git` through
`bash`. The others were advisory and are simply gone.

**`claude_session_ids` is always empty.** opencode exposes no conversation id to
a command, so the harness context says so and the procedure leaves the list
empty. Conventions §8 already treats the field as a local recovery aid that
nothing reads back; the per-stage records are the recovery path. The field keeps
its name in both builds so one knowledge base can be worked on from either.

One more, not a loss: commands in opencode are user-invoked by definition, which
matches the `disable-model-invocation: true` the Claude wrappers declare. That
is why the procedures are exposed as commands here rather than as skills.
