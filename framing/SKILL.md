---
name: framing
description: Consolidates an already-written ADR/RFC + PRD/spec + issues into a single technical design (framing) document — sequence diagram, data model, API contracts, per-issue estimation, and resolution of open technical questions, with feasibility checked against the codebase. Use when the user asks for "framing", "cadrage technique", a "design doc", a "TDD", or "technical design" for a feature that already has design inputs, or wants to consolidate the design and add sequence/ERD/estimation before implementing. Triggers: "framing", "cadrage technique", "design doc", "TDD", "technical design".
---

# Framing — consolidate design inputs into one technical design doc

Produces the **consolidated design deliverable** that's missing once an ADR/RFC,
a PRD/spec, and issues exist. It does NOT rewrite those sources — it **synthesizes**
them and **fills the gaps** (sequence, data, contracts, estimation, feasibility).

**Prerequisite:** a feature that already has design inputs (a decision record +
a product spec + a task breakdown). If those don't exist, tell the user to do the
discovery/scoping interview first — this skill runs *after*.

## 0. Load configuration

If `config.yml` exists in this skill's directory, read it and use its values.
Otherwise use the defaults below and **discover** locations rather than guessing:

```yaml
design_inputs:        # where to look for sources (globs)
  decision: ["docs/adr/**", "docs/rfc/**", "**/ADR*.md", "**/RFC*.md"]
  spec:     ["**/PRD.md", "**/SPEC.md", "**/spec.md"]
  tasks:    ["**/issues/*.md", "**/tickets/*.md"]
output: "<design-dir>/FRAMING_<feature>.md"   # next to the spec
code_index: "auto"    # "auto" → use a code-graph MCP if present, else grep/read
conventions: ["CLAUDE.md", "CONTRIBUTING.md", "docs/architecture/**", "docs/**"]
language: "en"
propagate_to_tasks: "ask"   # ask | always | never — push new decisions/TODOs back into issues
```

## Workflow

1. **Locate the sources.** Resolve the `<feature>` (from args, or ask). Using
   `design_inputs`, find and read the spec, every task/issue, and the referenced
   decision record. If multiple features match, ask which one.

2. **Extract decisions already made** (do NOT re-litigate them): destination,
   data model, endpoints, jobs, cross-cutting constraints. List them as-is.

3. **Verify feasibility against the code.** For every integration assumption and
   every open question in the spec/issues, confirm it in the actual codebase:
   - does the anchor point exist? (the file/module/route to hook into)
   - does the assumed helper/method/field exist with the right signature?
   - what is the blast radius of the change?
   **Tooling:** if `code_index` resolves to a code-graph MCP (e.g. codegraph) and
   it's available, use it — it's faster and structural. Otherwise fall back to
   native grep/read automatically; do not require any MCP. Mark each open question
   **Resolved (with file:line evidence)** or **Still TODO (precise action)**.
   Never claim a symbol exists without having seen it.

4. **Light grilling.** Ask ONLY the technical questions that NEITHER the decision
   record NOR the issues settle AND the code can't resolve (e.g. transport format,
   idempotency strategy, a remaining index choice). One at a time, each with a
   recommendation. Skip this step entirely if everything is already settled.

5. **Read the project's own conventions** (from `conventions`) and write the
   deliverable from [TEMPLATE.md](TEMPLATE.md) to the `output` path. Fill each
   section; delete sections that don't apply (e.g. no ERD if no DB change).
   Diagrams in **Mermaid**. Per-issue estimate (S/M/L) + order/dependencies.
   Link the decision record and the issues by path/reference. The doc must obey
   the host project's conventions — read them, don't assume a stack.

6. **Report**: a short summary (sources consolidated, questions resolved vs TODO
   left, recommended implementation order) + the deliverable path. Then honor
   `propagate_to_tasks`: surface any NEW decision or TODO the framing introduced
   (a new column, a missing helper) and offer to fold it back into the relevant
   issue, so the issues stay the source of truth.

## Rules

- **Source of truth:** the decision record / spec / issues win. If the code
  contradicts a decision (e.g. an assumed helper is missing), flag it under "Open
  questions / risks" — never silently rewrite the decision.
- **No fabrication:** every claim about the existing code cites `file:line` you
  actually saw (via the code index or grep/read).
- **Be additive, not redundant:** the framing completes the spec, it doesn't copy
  it. Point back to the decision record/spec for the "why"; focus on the "how".
- **Stack-agnostic:** do not hardcode a framework, ORM, or naming convention —
  read them from the project's `conventions` files and follow them.
