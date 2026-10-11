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
hot-reloaded. Then `/session-discover`, `/session-start`, `/session-close`,
`/session-init`, `/project-brief` and `/memento-doctor` are available.

## What gets installed

Into `$OPENCODE_CONFIG_DIR`, else `~/.config/opencode` — **not** `~/.opencode`,
which opencode ignores for configuration:

| Path | What |
|---|---|
| `skills/memento/` | The bundle, copied verbatim |
| `commands/<name>.md` | One thin wrapper per procedure, six in total |

`skills/memento/` is a **build artifact**: re-run the installer after editing
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
- Bundle root: `/home/you/.config/opencode/skills/memento`

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
every agent `external_directory` access to `skills/memento/*`, so commands read
the bundle without a prompt. A folder anywhere else would be asked about on
every session.

It also means `/memento` itself is available in opencode as a reference skill,
for questions about how `docs/ai/` is structured.

## Greenfield projects

`/session-discover` is the entry point when there is no code yet. It
bootstraps `docs/ai/` itself — including this bundle's copy — so on that path
there is no separate init step: discover first, then `/session-start` on the
design's build-order slices. `/session-init` remains the entry point for
repositories that already have code.

## What differs from the Claude Code build

Both builds run the same procedures and produce an identical `docs/ai/`. Three
things could not carry across.

**`/memento:doctor` becomes `/memento-doctor`.** opencode commands are flat and
have no `:` namespace.

**Tool restrictions are dropped, except one.** opencode command frontmatter
accepts `description`, `agent`, `model` (with an optional `#variant` suffix)
and `subagent` (`subtask` remains accepted as a deprecated alias), so the
`allowed-tools` the Claude wrappers declare have no equivalent. The restriction
that carried a guarantee — `/project-brief` never writing — is restored by
setting `agent: explore` in that command's frontmatter, delegating to
opencode's built-in read-only `explore` subagent. The others were advisory and
are simply gone.

No custom agent is shipped: per the [Agent Skills spec](https://agentskills.io),
`SKILL.md` frontmatter only recognises `name`, `description`, `license`,
`compatibility` and `metadata`, so the agent binding lives in the generated
command's frontmatter, not in the bundle.

**`claude_session_ids` is always empty.** opencode exposes no conversation id to
a command, so the harness context says so and the procedure leaves the list
empty. Conventions §8 already treats the field as a local recovery aid that
nothing reads back; the per-stage records are the recovery path. The field keeps
its name in both builds so one knowledge base can be worked on from either.

One more, not a loss: commands in opencode are user-invoked by definition, which
matches the `disable-model-invocation: true` the Claude wrappers declare. That
is why the procedures are exposed as commands here rather than as skills.
