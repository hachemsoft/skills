# skills

Public collection of standalone Claude Code skills. Users copy or symlink one
skill directory into `~/.claude/skills/` or `.claude/skills/` and invoke it by
its bare name, so every skill must work in an unknown host project.

## Skill layout

- One top-level directory per skill; the directory name equals the frontmatter
  `name` (it becomes the `/command`).
- `SKILL.md` is required. Optional siblings: `README.md` (human docs),
  `TEMPLATE.md`, `scripts/`, `config.example.yml`.
- Paths in `SKILL.md` (scripts, templates) are relative to the skill's own
  directory, never to the repo root or the host project.

## Portability

- **Generic**: no references to a specific company, repo, stack, or framework.
  Skills imported from private sets get their project-only triggers and
  assumptions stripped (see `fe2f977`).
- **Optional dependencies degrade**: an MCP server or CLI the skill can live
  without gets a fallback (e.g. `framing` uses codegraph if present, else
  grep/read). A hard dependency is named in `SKILL.md` with how to install or
  authenticate it, and in the README table.
- **Config**: tunables ship as `config.example.yml`; the skill reads `config.yml`
  from its own directory and falls back to defaults written in `SKILL.md`.
  `config.yml` is gitignored — it holds the user's local values.
- Scratch output (downloads, transcripts) goes under `/tmp/`, never into the
  host repo.

## Language

Skill bodies may be English or French. Descriptions carry trigger phrases in
both languages when users ask in both (e.g. "framing" / "cadrage technique").

## Adding or renaming a skill

Update the **Skills** table in `README.md` in the same commit: link, one-line
summary including hard requirements, and the invoke example.
