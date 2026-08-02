# Skills

This topic manages curated agent skills under `symlink.agents+skills`, which
`script/bootstrap` links to `~/.agents/skills`. The source manifest in
`sources.txt` names the upstream skill directories; `install.sh` sparse-checks
out and synchronizes only those entries, leaving locally maintained skills
alone.

## Managed Skills

<!-- BEGIN MANAGED SKILLS -->
1. **grill-with-docs**

    Description: A relentless interview to sharpen a plan or design, which also creates docs (ADR's and glossary) as we go.

    Dependencies: `grilling`, `domain-modeling`

    Source: <https://github.com/mattpocock/skills.git>

1. **grilling**

    Description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.

    Dependencies: None

    Source: <https://github.com/mattpocock/skills.git>

1. **domain-modeling**

    Description: Build and sharpen a project's domain model. Use when the user wants to pin down domain terminology or a ubiquitous language, record an architectural decision, or when another skill needs to maintain the domain model.

    Dependencies: None

    Source: <https://github.com/mattpocock/skills.git>

1. **codebase-design**

    Description: Shared vocabulary for designing deep modules. Use when the user wants to design or improve a module's interface, find deepening opportunities, decide where a seam goes, make code more testable or AI-navigable, or when another skill needs the deep-module vocabulary.

    Dependencies: None

    Source: <https://github.com/mattpocock/skills.git>

1. **grill-me**

    Description: A relentless interview to sharpen a plan or design.

    Dependencies: `grilling`

    Source: <https://github.com/mattpocock/skills.git>

1. **to-spec**

    Description: Turn the current conversation into a spec and publish it to the project issue tracker — no interview, just synthesis of what you've already discussed.

    Dependencies: None

    Source: <https://github.com/mattpocock/skills.git>

1. **to-tickets**

    Description: Break a plan, spec, or the current conversation into a set of tracer-bullet tickets, each declaring its blocking edges, published to the configured tracker — edges as text in one file per ticket locally, or native blocking links on a real tracker.

    Dependencies: None

    Source: <https://github.com/mattpocock/skills.git>

1. **wayfinder**

    Description: Plan a huge chunk of work — more than one agent session can hold — as a shared map of decision tickets on your issue tracker, and resolve them one at a time until the way to the destination is clear.

    Dependencies: `grilling`, `domain-modeling`, `prototype`, `research`

    Source: <https://github.com/mattpocock/skills.git>

1. **prototype**

    Description: Build a throwaway prototype to answer a design question. Use when the user wants to sanity-check whether a state model or logic feels right, or explore what a UI should look like.

    Dependencies: None

    Source: <https://github.com/mattpocock/skills.git>

1. **research**

    Description: Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent.

    Dependencies: None

    Source: <https://github.com/mattpocock/skills.git>

1. **implement**

    Description: Implement a piece of work based on a spec or set of tickets.

    Dependencies: `tdd`, `code-review`

    Source: <https://github.com/mattpocock/skills.git>

1. **tdd**

    Description: Test-driven development. Use when the user wants to build features or fix bugs test-first, mentions "red-green-refactor", or wants integration tests.

    Dependencies: None

    Source: <https://github.com/mattpocock/skills.git>

1. **code-review**

    Description: Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes — Standards (does the code follow this repo's documented coding standards?) and Spec (does the code match what the originating issue/PRD asked for?). Runs both reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to "review since X".

    Dependencies: None

    Source: <https://github.com/mattpocock/skills.git>

1. **diagnosing-bugs**

    Description: Diagnosis loop for hard bugs and performance regressions. Use when the user says "diagnose"/"debug this", or reports something broken/throwing/failing/slow.

    Dependencies: None

    Source: <https://github.com/mattpocock/skills.git>
<!-- END MANAGED SKILLS -->

## Updating

Refresh the managed skill definitions and this inventory with:

```sh
bash skills/install.sh
uv run skills/update_readme.py
```

The generator rewrites only the content between the managed-skills markers, so
the integration notes and any later sections remain manual.
