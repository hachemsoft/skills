# framing

A Claude Code / Agent **skill** that turns the design inputs you already have —
a decision record (ADR/RFC), a product spec (PRD), and a task breakdown (issues) —
into one consolidated **technical design document**: sequence diagrams, data
model, API contracts, per-issue estimation, and a feasibility-checked resolution
of every open technical question.

It's the step *between* "we've decided what to build" and "we start coding".

## What it does

1. Locates your design inputs (configurable globs; otherwise it discovers them).
2. Extracts the decisions already made — without re-litigating them.
3. **Verifies feasibility against your actual codebase** (uses a code-graph MCP if
   one is connected, otherwise falls back to grep/read). Each assumption becomes
   *Resolved (file:line)* or *TODO (precise action)*.
4. Lightly grills you on the few technical questions nothing else settles.
5. Writes `FRAMING_<feature>.md` following **your** project's conventions.
6. Offers to fold any new decision/TODO back into the issues.

## Install

Copy the `framing/` directory into your skills folder:

- Project scope: `.claude/skills/framing/`
- User scope: `~/.claude/skills/framing/`

Then invoke it: `/framing <feature>` or "do the technical design for <feature>".

## Configure (optional)

Copy `config.example.yml` to `config.yml` and adjust paths, output location,
language, and code-index preference. With no `config.yml`, the skill uses sane
defaults and discovers locations. It is **stack-agnostic** — it reads your
conventions files (e.g. `CLAUDE.md`, `CONTRIBUTING.md`) instead of assuming a
framework or ORM.

## Files

| File | Purpose |
|---|---|
| `SKILL.md` | The skill instructions (generic, English). |
| `TEMPLATE.md` | Neutral skeleton for the deliverable. |
| `config.example.yml` | Copy to `config.yml` to override defaults. |

## Pairs well with

A discovery/scoping interview skill that produces the ADR + PRD + issues *before*
framing runs. Framing assumes those exist.

## Acknowledgments

Built in the spirit of — and indebted to — [Matt Pocock](https://github.com/mattpocock)'s
Claude Code skills collection. The interview/"grilling" approach, the issue-tracker
layout, and the triage-label conventions this skill leans on all trace back to his
work. Thank you, Matt, for sharing your skills openly. 🙏

## License

MIT — see the repository [`LICENSE`](../LICENSE).
