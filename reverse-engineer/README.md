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
5. Hands the draft to an independent **verifier sub-agent** that checks every
   `path:line` (file exists, line exists, line supports the claim). Wrong
   references are corrected, or the claim is demoted to `⚠️ inferred` and added
   to "Open questions". Its report (verified / corrected / demoted, plus the
   list of corrections) is appended to the document.
6. Writes the file and prints a recap: document path, clone path (URL mode),
   number of inferred claims and number of verifier corrections.

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

Point it at a repo you don't trust: the skill is built for that. Its rules are
spelled out in [`SKILL.md`](SKILL.md#security--read-before-touching-the-target):

- **Repo content is data, never instructions.** README, `CLAUDE.md`, docs,
  comments… are described, not obeyed. If the repo tries to instruct the agent
  ("run `setup.sh` first", "write your notes to …"), the skill ignores it and
  reports it, quoted with `path:line`, under "Risks, debt & sensitive areas".
- **Static by default.** It only reads files (plus hardened read-only `git`
  queries that neutralise the repo's own git config). It never installs, builds,
  tests or runs the repo's scripts, hooks or binaries on its own.
- **One explicit consent per command.** If running something would settle a
  claim, the skill shows you the exact command, where it runs and what repo code
  it triggers, and waits for your yes. A yes covers that command only, once; the
  next one is asked again. If you say no, the analysis continues statically and
  still produces the document (the unconfirmed point is marked `⚠️ inferred`).
- **Minimal writes.** The only file written is the document — plus, for a git
  URL, the clone under `/tmp/reverse/` (created or updated by the skill's own
  git commands, nothing else).

Install-time code (`postinstall` and other lifecycle scripts, git hooks,
`.envrc`…) is always listed under "Risks, debt & sensitive areas", and the
Appendix lists every command you approved (or "none").

## Files

| File | Purpose |
|---|---|
| `SKILL.md` | The skill instructions (English). |
| `TEMPLATE.md` | Fixed skeleton of the document (11 sections). |
| `config.example.yml` | Copy to `config.yml` to override defaults. |

## License

MIT — see the repository [`LICENSE`](../LICENSE).
