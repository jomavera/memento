# Profile: code

Software repositories — applications, libraries, services, infrastructure.

## Survey

What `/session-init` reads to seed `PROJECT.md`, in this order:

1. `README*`, `CONTRIBUTING*`, `CLAUDE.md`, `AGENTS.md`
2. Package and build manifests — `package.json`, `pyproject.toml`,
   `requirements.txt`, `Cargo.toml`, `pom.xml`, `*.csproj`, `go.mod`, `Gemfile`,
   `Makefile`, `justfile`, `docker-compose*`, CI workflow files
3. Anything under `docs/`
4. The top two levels of the directory tree, to identify the real components
5. Config files that name external systems — record the system, never a credential

## Sections contributed to PROJECT.md

```markdown
## Stack and layout

- **Language / runtime:** <versions that matter>
- **Key dependencies:** <only ones that shape how code is written>
- **Components:**
  - `<path/>` — <what it is responsible for>

## Architecture notes

<Only the non-obvious: why the structure is the way it is, where the seams are,
what depends on what in a way the directory tree does not reveal.>

## Conventions not already in CLAUDE.md

<Project-specific patterns to follow. If CLAUDE.md already says it, link there.>
```

## What counts as a check

A command whose exit status decides the matter, or an observation that could
have come out the other way.

- the test suite, or the specific tests covering the change
- a linter, formatter or type checker
- a build or compile
- a script asserting the invariant the stage was supposed to establish
- a smoke request against the thing actually running
- a benchmark, when the stage was about performance — record both numbers

**Not a check:** reading the diff and finding it reasonable; the code compiling
when the stage was about behaviour; "no errors appeared".

Record the command as typed and its verdict. Where a stage changed behaviour
that no existing test covers, say so — an untested change reported as `done` is
the failure mode this profile exists to prevent.
