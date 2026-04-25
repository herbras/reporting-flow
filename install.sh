#!/usr/bin/env bash
# install.sh — symlink skills/commands/agents from this repo into ~/.claude/
#
# Usage:
#   ./install.sh              # install (create symlinks)
#   ./install.sh --uninstall  # remove symlinks
#   ./install.sh --check      # report current state, do nothing

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_HOME:-$HOME/.claude}"

# pairs: <repo relative path>::<~/.claude relative path>
declare -a LINKS=(
  "skills/founderplus-cycle::skills/founderplus-cycle"
  "commands/cycle-start.md::commands/cycle-start.md"
  "commands/cycle-ship.md::commands/cycle-ship.md"
  "agents/cycle-coordinator.md::agents/cycle-coordinator.md"
)

mode="install"
case "${1:-}" in
  --uninstall|-u) mode="uninstall" ;;
  --check|-c)     mode="check" ;;
  --help|-h)
    sed -n '2,8p' "$0"
    exit 0
    ;;
  "") ;;
  *) echo "unknown flag: $1"; exit 2 ;;
esac

color_ok="\033[32m"
color_warn="\033[33m"
color_err="\033[31m"
color_off="\033[0m"

ok()   { printf "${color_ok}OK${color_off}    %s\n" "$1"; }
warn() { printf "${color_warn}WARN${color_off}  %s\n" "$1"; }
err()  { printf "${color_err}ERR${color_off}   %s\n" "$1"; }

ensure_parent() {
  local path="$1"
  mkdir -p "$(dirname "$path")"
}

do_install() {
  for pair in "${LINKS[@]}"; do
    src="$REPO_DIR/${pair%%::*}"
    dst="$CLAUDE_DIR/${pair##*::}"

    if [[ ! -e "$src" ]]; then
      err "source missing: $src"
      continue
    fi

    ensure_parent "$dst"

    if [[ -L "$dst" ]]; then
      current="$(readlink "$dst")"
      if [[ "$current" == "$src" ]]; then
        ok "already linked: $dst"
        continue
      else
        warn "replacing existing symlink: $dst → $current"
        rm "$dst"
      fi
    elif [[ -e "$dst" ]]; then
      err "destination exists and is not a symlink: $dst — refusing to overwrite. Move or delete it first."
      continue
    fi

    ln -s "$src" "$dst"
    ok "linked: $dst → $src"
  done

  echo
  echo "Done. Restart Claude Code to pick up the new skill/commands/agent."
}

do_uninstall() {
  for pair in "${LINKS[@]}"; do
    src="$REPO_DIR/${pair%%::*}"
    dst="$CLAUDE_DIR/${pair##*::}"

    if [[ -L "$dst" ]]; then
      current="$(readlink "$dst")"
      if [[ "$current" == "$src" ]]; then
        rm "$dst"
        ok "removed symlink: $dst"
      else
        warn "skipping — symlink points elsewhere: $dst → $current"
      fi
    elif [[ -e "$dst" ]]; then
      warn "skipping — not a symlink (manual file): $dst"
    else
      ok "already absent: $dst"
    fi
  done
}

do_check() {
  for pair in "${LINKS[@]}"; do
    src="$REPO_DIR/${pair%%::*}"
    dst="$CLAUDE_DIR/${pair##*::}"

    if [[ ! -e "$src" ]]; then
      err "source missing in repo: $src"
      continue
    fi

    if [[ -L "$dst" ]]; then
      current="$(readlink "$dst")"
      if [[ "$current" == "$src" ]]; then
        ok "linked correctly: $dst"
      else
        warn "linked elsewhere: $dst → $current"
      fi
    elif [[ -e "$dst" ]]; then
      warn "not a symlink (manual file): $dst"
    else
      err "missing: $dst"
    fi
  done
}

case "$mode" in
  install)   do_install ;;
  uninstall) do_uninstall ;;
  check)     do_check ;;
esac
