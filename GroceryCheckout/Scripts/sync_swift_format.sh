#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Copy the swift-format file at the root
cp "$ROOT_DIR"/Swift-Format/swift-format "$ROOT_DIR/../.swift-format"
