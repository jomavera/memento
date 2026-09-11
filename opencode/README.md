# Memento for opencode

Memento is written as a Claude Code plugin. This directory builds an
[opencode](https://opencode.ai) version of it from that same source.

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
| `command/<name>.md` | One command per skill, five in total |
| `skill/memento/SKILL.md` | Bundle entry point, also a `/memento` skill |
| `skill/memento/reference/` | `conventions.md` and the profiles |
| `skill/memento/templates/` | The document templates |
| `agent/memento-brief.md` | Read-only agent behind `/project-brief` |

`skill/memento/` is a **build artifact**. Edit the plugin source and re-run the
installer; never edit the installed copy, and re-run after changing `reference/`
or `templates/` or the two will drift.

The generated commands embed absolute paths into that bundle, so re-run the
installer if this repository moves.

### Why the files live in a skill folder

opencode commands are single markdown files with no bundling mechanism, so the
reference material has to live somewhere a command can point at. A skill folder
is opencode's only native home for resource files: its loader lists every file
under a skill's directory and hands the model that list along with the directory
path.

It also earns a permission: opencode automatically grants every agent
`external_directory` access to `skill/memento/*`, so commands read
`conventions.md` without a prompt. A folder anywhere else would be asked about
on every session.

## What differs from the Claude Code build

The two builds run the same instructions and produce an identical `docs/ai/`.
Four things could not carry across.

**`/memento:doctor` becomes `/memento-doctor`.** opencode commands are flat and
have no `:` namespace.

**Tool restrictions are dropped, except one.** A skill's `allowed-tools` and
`disallowed-tools` have no opencode equivalent, and opencode command frontmatter
accepts only `description`, `agent`, `model`, `variant` and `subtask`. The
restriction that carried a guarantee — `/project-brief` never writing — is
restored by running that command under the `memento-brief` agent, which denies
`edit`, `write`, `apply_patch` and `task`, and allows only read-only `git`
through `bash`. The others were advisory and are simply gone.

**Commands are always user-invoked.** Four of the five skills set
`disable-model-invocation: true`, which opencode ignores — but opencode commands
are user-invoked by definition, so the intent survives. This is why the skills
are built as commands rather than as skills: an opencode skill is a tool the
model may call on its own, which is the opposite of what the session cycle
wants. The `/memento` skill is the deliberate exception: it carries the
reference material and may be read at any time, but it opens no session.

**`claude_session_ids` is always empty.** opencode exposes no conversation id to
a command, so there is nothing to seed it with. Conventions §8 already treats
the field as a local recovery aid that nothing reads back, so nothing depends on
it; the per-stage records are the recovery path. The field keeps its name in
both builds so one knowledge base can be worked on from either harness.

`AGENTS.md` replaces `CLAUDE.md` as the file `/session-init` appends the memento
block to.

## How the build works

`install.sh` applies five single-line substitutions to the five skill files, and
copies everything else verbatim:

| From | To |
|---|---|
| `${CLAUDE_PLUGIN_ROOT}` | the installed bundle path |
| `${CLAUDE_PROJECT_DIR}/` | *removed — opencode runs commands in the repo root* |
| `${user_config.document_language}` | the `--language` value |
| `/memento:doctor` | `/memento-doctor` |
| `CLAUDE.md` | `AGENTS.md` |

`${CLAUDE_SESSION_ID}` is deliberately left alone: the two passages that use it
name Claude Code explicitly and tell any other harness to leave the field empty,
so they read correctly unported.

Everything else that differs between the harnesses was resolved **upstream** in
the plugin source, which now names both harnesses where they genuinely diverge.
That is what keeps this build a set of mechanical substitutions instead of a
fork, and it is why `reference/` and `templates/` copy across untouched.

After writing, the installer greps everything it produced for leftover
Claude-only constructs and fails the install if it finds any. So if a skill
later grows a new `${CLAUDE_...}` reference, the install stops and says so,
rather than leaving commands that silently cannot find their own rules.
