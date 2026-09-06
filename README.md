# jmvera-plugins

A local Claude Code plugin marketplace. This repository is the catalog; the
plugins live under `plugins/`.

## Plugins

| Plugin | What it does |
|---|---|
| [`memento`](plugins/memento/) | Lean session framework: two commands that give Claude Code a memory across sessions, with a traceable log per session and a cumulative knowledge base in `docs/ai/`. Profiles for software and data work. Documents in any language, English by default. |

## Install

Register this marketplace, once:

```
/plugin marketplace add jomavera/jmvera-plugins
```

Then install the plugin:

```
/plugin install memento@jmvera-plugins
```

The commands become available in every repository:

```
/session-init     once per repository
/session-start    before substantial work
/session-close    before ending work

/project-brief    where does this project stand? (read-only)
/memento:doctor   audit the knowledge base    (--fix for mechanical repairs)
```

They are also reachable namespaced as `/memento:session-start`. `doctor` needs
the namespace: `/doctor` is one of Claude Code's own bundled commands and cannot
be displaced by a plugin.

`/session-init` picks a profile from what it finds in the project — `code`,
`analysis`, or both — and writes it to `docs/ai/config.yml` along with the
document language. To set the language globally instead, use `document_language`
in the plugin's settings via `/plugin`, or pass it once: `/session-init Spanish`.
See the plugin's [README](plugins/memento/README.md#profiles).

## Catalog vs. plugin

Two manifests with two different jobs:

| File | Role | Its `name` |
|---|---|---|
| `.claude-plugin/marketplace.json` | The catalog this repo publishes | `jmvera-plugins` — used after the `@` |
| `plugins/<plugin>/.claude-plugin/plugin.json` | One plugin: its skills and version | `memento` — used before the `@`, and as the command prefix |

To add a second plugin: create `plugins/<new-plugin>/` with its own
`plugin.json` and `skills/`, then add an entry to the `plugins` array in
`marketplace.json`.

Keep the `version` in both manifests in step. At install time `plugin.json`
wins and the catalog's value is ignored, so a stale entry is a silent lie —
`claude plugin validate` warns about it.

## Develop

After editing a plugin, pick up the changes without restarting:

```
/plugin marketplace update jmvera-plugins
/reload-plugins
```

Validate the manifests before committing:

```
claude plugin validate .
```
