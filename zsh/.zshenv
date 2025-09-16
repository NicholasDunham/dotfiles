#!/usr/bin/env zsh
# Minimal env for all zsh invocations
# Keep this file fast; avoid heavy work here.

# Ensure HOMEBREW_PREFIX is available to non-login shells
export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

