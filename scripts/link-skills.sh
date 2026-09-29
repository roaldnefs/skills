#!/usr/bin/env bash
# Symlink all skills in this repo into ~/.claude/skills and ~/.agents/skills.
set -euo pipefail

cd "$(dirname "$0")/.."
repo="$PWD"
skills="$(scripts/list-skills.sh)"
[ -n "$skills" ] || exit 0

for target in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
  mkdir -p "$target"
  while read -r skill; do
    link="$target/$(basename "$skill")"
    if [ -L "$link" ]; then
      case "$(readlink "$link")" in
        "$repo"/*) ;;
        *)
          echo "skip: $link is a symlink to outside this repo" >&2
          continue
          ;;
      esac
    elif [ -e "$link" ]; then
      echo "skip: $link exists and is not a symlink" >&2
      continue
    fi
    ln -sfn "$repo/$skill" "$link"
    echo "$link -> $repo/$skill"
  done <<< "$skills"
done
