#!/usr/bin/env zsh
# Minimal env for all zsh invocations
# Keep this file fast; avoid heavy work here.

# Ensure HOMEBREW_PREFIX is available to non-login shells
export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

# VS Code terminal integration support
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    export VSCODE_SHELL_INTEGRATION=1
fi

# uv
export PATH="/Users/nicholasdunham/.local/bin:$PATH"
