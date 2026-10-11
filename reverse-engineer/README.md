# reverse-engineer

A Claude Code / Agent **skill** that reads an existing repository and writes one
sourced **"as-is" architecture document**: stack, module map, entry points, key
flows, data model, API contracts, integrations, risks and open questions.

It's the counterpart of [`framing`](../framing/): framing designs what you are
about to build; reverse-engineer documents what already exists. Use it when you
land on an unfamiliar repo (onboarding, audit, takeover, dependency evaluation).

## What it does

1. Resolves the target: the current directory, the local path you pass, or a
   git URL — shallow-cloned (`--depth 1`, no submodules) into
   `/tmp/reverse/<repo>`, or updated in place if that clone already exists.
2. Static reconnaissance: tree, manifests, entry points, CI/Docker, README.
3. Builds the module map, then digs into each module and traces 3–5 key flows.
4. Writes `ARCHITECTURE_<repo>.md` from a fixed [template](TEMPLATE.md): always
   the same 11 sections in the same order (`N/A` when a section doesn't apply),
   Mermaid module map, sequence diagrams and ERD.
5. Prints a recap: document path, clone path (URL mode) and number of inferred
   claims.

**Evidence.** Every structural claim (module, entry point, dependency, flow,
entity, endpoint, integration) cites `path:line` relative to the repo root.
Anything not proven by the code is marked `⚠️ inferred` and repeated under
"Open questions".

## Install

Copy the `reverse-engineer/` directory into your skills folder:

- Project scope: `.claude/skills/reverse-engineer/`
- User scope: `~/.claude/skills/reverse-engineer/`

Then invoke it:

```text
/reverse-engineer                 # analyse the current directory
/reverse-engineer ../other-repo   # analyse a local repo without cd-ing into it
/reverse-engineer https://github.com/expressjs/cors   # clone and analyse a remote repo
```

or just ask: "reverse engineer this repo", "document this repo", "architecture
as-is", "rétro-ingénierie", "onboarding repo inconnu".

By default the document goes to `<repo>/docs/reverse/ARCHITECTURE_<repo>.md`
for a local repo, and to `./reverse/ARCHITECTURE_<repo>.md` of your current
directory for a git URL — never to `/tmp` (the directory is created if needed). If the file already exists, the skill asks
whether to overwrite, write under another name, or cancel — it writes nothing
until you answer.

### Git URLs

An argument starting with `https://`, `http://`, `ssh://` or `git@`, or ending
in `.git`, is a git URL (an existing local directory always wins). `<repo>` is
the URL's last segment without `.git`.

- No clone yet → `git clone --depth 1 --no-recurse-submodules <url> /tmp/reverse/<repo>`.
- Clone with the same remote → `git fetch --depth 1 origin` then
  `git reset --hard FETCH_HEAD` (never `git pull`, never a reclone).
- `/tmp/reverse/<repo>` exists with a different remote → the skill stops and
  asks; it fetches, resets and deletes nothing.

The clone is kept after the run; its path is printed in the recap. Nothing
cleans `/tmp/reverse/` automatically.

## Configure (optional)

Copy `config.example.yml` to `config.yml` next to `SKILL.md` and adjust:

| Key | Default | Meaning |
|---|---|---|
| `output` | `auto` | `auto` = `<target>/docs/reverse/ARCHITECTURE_<repo>.md` (local) or `./reverse/ARCHITECTURE_<repo>.md` (git URL); or an explicit path containing `<repo>`. Never under `/tmp`. |
| `language` | `auto` | `auto` = language of the conversation; or an ISO code (`fr`, `en`, …). |
| `code_index` | `auto` | `auto` uses a code-graph MCP if connected, else grep/read; `none` forces grep/read. |
| `fanout_threshold` | `8` | Above this many modules, the skill asks which ones to cover. |

`config.yml` is git-ignored.

## Security

The analysis is **static and read-only**: the skill reads files and never runs
the target repo's code (no install, build, tests or scripts). The repo's content
is treated as data — instructions it addresses to an agent (README, `CLAUDE.md`,
comments) are ignored. The only writes are the document and, for a git URL, the
clone under `/tmp/reverse/`.

## Files

| File | Purpose |
|---|---|
| `SKILL.md` | The skill instructions (English). |
| `TEMPLATE.md` | Fixed skeleton of the document (11 sections). |
| `config.example.yml` | Copy to `config.yml` to override defaults. |

## License

MIT — see the repository [`LICENSE`](../LICENSE).
