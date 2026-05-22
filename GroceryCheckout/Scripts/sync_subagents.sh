#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Copy all markdown subagents
cp "$ROOT_DIR"/Claude/SubAgents/*.md "$ROOT_DIR/../.claude/agents/"
