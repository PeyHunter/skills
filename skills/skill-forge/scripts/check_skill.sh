#!/usr/bin/env bash
set -euo pipefail

skill_dir="${1:?usage: check_skill.sh <skill-directory>}"
skill_file="$skill_dir/SKILL.md"

[ -f "$skill_file" ] || { echo "ERROR: missing $skill_file" >&2; exit 1; }

name_line="$(sed -n 's/^name: *//p' "$skill_file" | head -n 1)"
description_line="$(sed -n 's/^description: *//p' "$skill_file" | head -n 1)"

[ -n "$name_line" ] || { echo "ERROR: missing name in frontmatter" >&2; exit 1; }
[ -n "$description_line" ] || { echo "ERROR: missing description in frontmatter" >&2; exit 1; }

if [[ ! "$name_line" =~ ^[a-z0-9-]+$ ]]; then
  echo "ERROR: name must contain only lowercase letters, digits, and hyphens" >&2
  exit 1
fi

if (( ${#name_line} > 64 )); then
  echo "ERROR: name exceeds 64 characters" >&2
  exit 1
fi

if rg -n '\[TODO|<skill-name>|\[placeholder\]' "$skill_file"; then
  echo "ERROR: unfinished placeholder found" >&2
  exit 1
fi

echo "OK: $skill_file"
