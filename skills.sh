#!/usr/bin/env bash
# skills.sh — Install and sync Claude Code skills from GitHub
# Usage:
#   ./skills.sh install   — copy skills from repo to ~/.claude/skills/
#   ./skills.sh update    — pull latest from GitHub, then sync
#   ./skills.sh list      — show installed skills

set -euo pipefail

# ── Config ──────────────────────────────────────────────────────────────────
REPO_URL="https://github.com/mubashirali/skill-sync"
REPO_RAW="https://raw.githubusercontent.com/mubashirali/skill-sync/main"
CLONE_DIR="${HOME}/.skill-sync-repo"
SKILLS_SRC="${CLONE_DIR}/skills"
SKILLS_DST="${HOME}/.claude/skills"

# ── Colors ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
RESET='\033[0m'

ok()   { echo -e "${GREEN}✓${RESET} $*"; }
info() { echo -e "${CYAN}→${RESET} $*"; }
warn() { echo -e "${YELLOW}!${RESET} $*"; }
err()  { echo -e "${RED}✗${RESET} $*" >&2; exit 1; }

# ── Helpers ──────────────────────────────────────────────────────────────────
require() {
  command -v "$1" &>/dev/null || err "Required command not found: $1"
}

sync_skills() {
  local src="$1"
  local dst="$2"

  mkdir -p "$dst"

  local count=0
  for skill_dir in "$src"/*/; do
    [ -d "$skill_dir" ] || continue
    local skill_name
    skill_name=$(basename "$skill_dir")

    if [ ! -f "$skill_dir/SKILL.md" ]; then
      warn "Skipping $skill_name — no SKILL.md found"
      continue
    fi

    mkdir -p "$dst/$skill_name"
    cp -r "$skill_dir"/* "$dst/$skill_name/"
    ok "Synced: $skill_name"
    (( count++ )) || true
  done

  echo ""
  info "$count skill(s) synced to $dst"
}

# ── Commands ─────────────────────────────────────────────────────────────────
cmd_install() {
  # Check if we're being piped (curl | bash) — no local repo available
  if [ ! -d "$(dirname "$0")/skills" ] && [ "${BASH_SOURCE[0]}" = "" ]; then
    info "Running via curl — cloning repo to ${CLONE_DIR}..."
    require git
    if [ -d "$CLONE_DIR" ]; then
      info "Repo already cloned. Pulling latest..."
      git -C "$CLONE_DIR" pull --quiet
    else
      git clone --quiet "$REPO_URL" "$CLONE_DIR"
    fi
    sync_skills "$SKILLS_SRC" "$SKILLS_DST"
  else
    # Running locally from inside the cloned repo
    local local_src
    local_src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills"
    [ -d "$local_src" ] || err "skills/ directory not found. Run from inside the skill-sync repo."
    sync_skills "$local_src" "$SKILLS_DST"
  fi
}

cmd_update() {
  require git

  if [ -d "$CLONE_DIR" ]; then
    info "Pulling latest skills from GitHub..."
    git -C "$CLONE_DIR" pull --quiet
    sync_skills "$SKILLS_SRC" "$SKILLS_DST"
  elif [ -d "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.git" ]; then
    # User is inside a cloned repo
    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    info "Pulling latest..."
    git -C "$repo_root" pull --quiet
    sync_skills "$repo_root/skills" "$SKILLS_DST"
  else
    info "No local clone found — cloning repo to ${CLONE_DIR}..."
    git clone --quiet "$REPO_URL" "$CLONE_DIR"
    sync_skills "$SKILLS_SRC" "$SKILLS_DST"
  fi
}

cmd_list() {
  echo ""
  echo -e "${CYAN}Installed Claude Code skills:${RESET}"
  echo "────────────────────────────────"

  if [ ! -d "$SKILLS_DST" ] || [ -z "$(ls -A "$SKILLS_DST" 2>/dev/null)" ]; then
    warn "No skills installed yet. Run: ./skills.sh install"
    return
  fi

  local count=0
  for skill_dir in "$SKILLS_DST"/*/; do
    [ -d "$skill_dir" ] || continue
    local skill_name
    skill_name=$(basename "$skill_dir")

    # Try to extract description from SKILL.md frontmatter
    local desc=""
    if [ -f "$skill_dir/SKILL.md" ]; then
      desc=$(awk '/^---/{c++} c==1 && /^description:/{sub(/^description: */,""); print; exit}' "$skill_dir/SKILL.md" | cut -c1-80)
    fi

    echo -e "  ${GREEN}${skill_name}${RESET}"
    [ -n "$desc" ] && echo -e "    ${desc}"
    (( count++ )) || true
  done

  echo "────────────────────────────────"
  echo -e "  Total: ${count} skill(s)"
  echo ""
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
  local cmd="${1:-install}"

  echo ""
  echo -e "${CYAN}Claude Code Skills Manager${RESET}"
  echo "──────────────────────────"

  case "$cmd" in
    install) cmd_install ;;
    update)  cmd_update  ;;
    list)    cmd_list    ;;
    *)
      echo "Usage: $0 {install|update|list}"
      echo ""
      echo "  install   Copy skills from repo to ~/.claude/skills/"
      echo "  update    Pull latest from GitHub and re-sync"
      echo "  list      Show installed skills"
      exit 1
      ;;
  esac
}

main "$@"
