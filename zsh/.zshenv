#!/usr/bin/env zsh
# Minimal env for all zsh invocations
# Keep this file fast; avoid heavy work here.

# Keep PATH and fpath free of duplicate entries
typeset -U PATH path FPATH fpath

# Single source of truth for HOMEBREW_PREFIX (login and non-login shells)
export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

# VS Code terminal integration support
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    export VSCODE_SHELL_INTEGRATION=1
fi

# uv
export PATH="$HOME/.local/bin:$PATH"
