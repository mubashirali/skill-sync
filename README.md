# skill-sync

Personal [Claude Code](https://claude.ai/code) skills — reusable techniques and workflows that load into Claude automatically when needed.

## Install via npx (recommended)

```bash
# Install all skills from this repo
npx @alimubashir/skillsync add https://github.com/alimubashir/skill-sync

# Install a specific skill
npx @alimubashir/skillsync add https://github.com/alimubashir/skill-sync --skill writing-linkedin-posts
```

No installation required — `npx` runs it directly. Requires Node.js 18+.

## Other Commands

```bash
# List installed skills
npx @alimubashir/skillsync list

# Update all skills to latest
npx @alimubashir/skillsync update

# Update one skill
npx @alimubashir/skillsync update writing-linkedin-posts

# Remove a skill
npx @alimubashir/skillsync remove writing-linkedin-posts
```

## Quick Install (bash alternative)

```bash
curl -fsSL https://raw.githubusercontent.com/alimubashir/skill-sync/main/skills.sh | bash
```

## Skills

| Skill | Description |
|-------|-------------|
| [writing-linkedin-posts](skills/writing-linkedin-posts/SKILL.md) | Use when the user wants to write, draft, or improve a LinkedIn post — especially when they want it to sound human, use trending language, and drive engagement in the tech/software space |

## Adding a New Skill

1. Create a directory under `skills/`:
   ```
   skills/your-skill-name/
   └── SKILL.md
   ```

2. Add YAML frontmatter to `SKILL.md`:
   ```markdown
   ---
   name: your-skill-name
   description: Use when [specific triggering conditions]
   ---

   # Your Skill Name

   ## Overview
   ...
   ```

3. Push to `main` — GitHub Actions will validate the skill and create a new versioned release automatically.

**Rules for `name`:** letters, numbers, and hyphens only. No spaces or special characters.
**Rules for `description`:** must start with "Use when...", under 1024 total frontmatter chars, written in third person.

## How It Works

```
Push to main
    │
    ▼
validate.yml — checks every skill for:
  • SKILL.md exists
  • valid YAML frontmatter
  • name (letters/numbers/hyphens only)
  • description not empty
  • frontmatter under 1024 chars
    │
    ▼ (if valid)
release.yml — auto:
  • bumps patch version (version.txt)
  • packages skills/ into a zip
  • creates GitHub Release with install notes
```

PRs also run validation — broken skills are caught before they reach main.

## GitHub Actions Setup

The release workflow needs write access to create releases and commit the version bump. This is already configured via `permissions: contents: write` in the workflow. No additional secrets are needed beyond the default `GITHUB_TOKEN`.

## Version

Current: `0.1.0` — see [releases](https://github.com/alimubashir/skill-sync/releases) for history.
