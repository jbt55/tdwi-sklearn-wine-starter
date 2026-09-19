#!/usr/bin/env bash
# Deterministic pre-commit / pre-push checks (Recipe 1).
# Run from repo root: bash scripts/check.sh

set -euo pipefail
cd "$(dirname "$0")/.."

# Optional extension points (uncomment as you adopt):
# echo "==> ruff check"
# ruff check .

# pytest exits with code 5 when it finds no test files yet (OK before students add test_model.py).
# Bash: `A || B` means "run B only if A failed (non-zero exit)."
# `$?` is the exit code of the last command (here, pytest).
# `test $? -eq 5` is true when that code is 5, so the whole line succeeds instead of failing check.sh.
echo "==> pytest"
python -m pytest . || test $? -eq 5  # allow "no tests collected" (exit 5) only
