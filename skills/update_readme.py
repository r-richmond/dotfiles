#!/opt/homebrew/bin/python3
# Run directly: uv run skills/update_readme.py
# /// script
# requires-python = ">=3.13"
# dependencies = ["pydantic>=2.0"]
# ///

"""Refresh the generated managed-skills inventory in README.md."""

from __future__ import annotations

import re
from pathlib import Path

from pydantic import BaseModel, ConfigDict, Field

SKILLS_DIR = Path(__file__).resolve().parent
README_PATH = SKILLS_DIR / "README.md"
SOURCES_PATH = SKILLS_DIR / "sources.txt"
SKILL_ROOT = SKILLS_DIR / "symlink.agents+skills"
SECTION_START = "<!-- BEGIN MANAGED SKILLS -->"
SECTION_END = "<!-- END MANAGED SKILLS -->"
REFERENCE_PATTERN = re.compile(r"(?<![\w-])/([a-z0-9][a-z0-9-]*)\b")


class Skill(BaseModel):
    """Metadata used to render one installed skill in the README."""

    model_config = ConfigDict(frozen=True)

    name: str = Field(description="The skill name declared in its frontmatter.")
    description: str = Field(
        description="The skill description declared in its frontmatter."
    )
    dependencies: tuple[str, ...] = Field(
        description="Ordered names of other installed skills referenced by this skill."
    )
    source_url: str | None = Field(
        description="Repository URL from sources.txt, or None for a locally maintained skill."
    )


def managed_skill_sources() -> dict[str, str]:
    """Return source URLs keyed by skill name from sources.txt.

    The dictionary key is the managed skill directory name; the value is that
    skill's upstream repository URL.
    """
    sources: dict[str, str] = {}
    for line in SOURCES_PATH.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        name, repository_url, *_ = line.split("|")
        sources[name] = repository_url
    return sources


def installed_skill_names(sources: dict[str, str]) -> list[str]:
    """Return installed skill names with managed sources first and local skills last.

    Args:
        sources: Maps each managed skill directory name to its upstream
            repository URL, preserving the manifest's order.

    Returns:
        A list of installed skill directory names: manifest-managed entries in
        manifest order, followed by unlisted local entries in alphabetical order.
    """
    installed_names = {path.parent.name for path in SKILL_ROOT.glob("*/SKILL.md")}
    missing_names = [name for name in sources if name not in installed_names]
    if missing_names:
        raise ValueError(f"missing installed skills: {', '.join(missing_names)}")

    local_names = sorted(installed_names.difference(sources))
    return [*sources, *local_names]


def frontmatter_value(frontmatter: str, key: str) -> str:
    match = re.search(rf"^{key}:\s*(.+)$", frontmatter, re.MULTILINE)
    if match is None:
        raise ValueError(f"missing {key!r} in skill frontmatter")

    value = match.group(1).strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
        return value[1:-1]
    return value


def read_skill(name: str, known_names: list[str], source_url: str | None) -> Skill:
    """Read frontmatter and direct dependencies for one installed skill.

    Args:
        name: Directory name of the skill to read.
        known_names: Ordered list of all installed skill directory names; only
            references to these names become documented dependencies.
        source_url: Upstream repository URL for a managed skill, or None for a
            locally maintained skill.
    """
    path = SKILL_ROOT / name / "SKILL.md"
    content = path.read_text()
    if not content.startswith("---\n"):
        raise ValueError(f"missing frontmatter in {path}")

    _, frontmatter, body = content.split("---\n", 2)
    references = set(REFERENCE_PATTERN.findall(body))
    dependencies = tuple(
        dependency
        for dependency in known_names
        if dependency != name and dependency in references
    )
    return Skill(
        name=frontmatter_value(frontmatter, "name"),
        description=frontmatter_value(frontmatter, "description"),
        dependencies=dependencies,
        source_url=source_url,
    )


def render_skills(skills: list[Skill]) -> str:
    """Render the generated README section for an ordered list of skill metadata."""
    lines: list[str] = []
    for skill in skills:
        dependencies = ", ".join(f"`{name}`" for name in skill.dependencies) or "None"
        source = f"<{skill.source_url}>" if skill.source_url else "local"
        if lines:
            lines.append("")
        lines.extend(
            (
                f"1. **{skill.name}**",
                "",
                f"    Description: {skill.description}",
                "",
                f"    Dependencies: {dependencies}",
                "",
                f"    Source: {source}",
            )
        )
    return "\n".join(lines)


def update_readme(generated_section: str) -> None:
    readme = README_PATH.read_text()
    start = readme.find(SECTION_START)
    end = readme.find(SECTION_END)
    if start == -1 or end == -1 or end < start:
        raise ValueError("README.md is missing managed-skills section markers")

    content_start = start + len(SECTION_START)
    updated = f"{readme[:content_start]}\n{generated_section}\n{readme[end:]}"
    if not updated.endswith("\n"):
        updated += "\n"
    README_PATH.write_text(updated)


def main() -> None:
    sources = managed_skill_sources()
    names = installed_skill_names(sources)
    skills = [read_skill(name, names, sources.get(name)) for name in names]
    update_readme(render_skills(skills))


if __name__ == "__main__":
    main()
