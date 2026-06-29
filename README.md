# skills

A small collection of standalone [Claude Code](https://code.claude.com) skills by
**hachemsoft**. Each skill is a self-contained directory you drop into your skills
folder and invoke by its bare name (no namespace prefix).

## Skills

| Skill | What it does | Invoke |
|---|---|---|
| [`framing`](framing/) | Consolidate an existing ADR/PRD/issues into one technical design (framing) document — sequence diagrams, data model, API contracts, estimation, feasibility-checked. | `/framing` |

## Install

Copy the skill directory into your skills folder:

```bash
git clone https://github.com/hachemsoft/skills /tmp/hachemsoft-skills
cp -r /tmp/hachemsoft-skills/framing ~/.claude/skills/framing   # all projects
# …or project scope:
# cp -r /tmp/hachemsoft-skills/framing /path/to/project/.claude/skills/framing
```

Then invoke it: `/framing <feature>`.

To stay in sync with updates, symlink instead of copying:

```bash
ln -s "$(pwd)/framing" ~/.claude/skills/framing
```

## Configure (optional)

Skills that support config ship a `config.example.yml`. Copy it to `config.yml`
next to the skill and adjust. With no `config.yml`, the skill uses sane defaults.
See each skill's own README.


## License

MIT — see [`LICENSE`](LICENSE).
