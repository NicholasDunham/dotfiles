# Homebrew and PATH (HOMEBREW_PREFIX is set in .zshenv)
if [ -x "$HOMEBREW_PREFIX/bin/brew" ]; then
	eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"
fi

# User bin
export PATH="$HOME/bin:$PATH"

# Prefer GNU tools installed via Homebrew
# MAN pages for GNU coreutils (preserve defaults if MANPATH was empty)
if command -v manpath >/dev/null 2>&1; then
	export MANPATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnuman:${MANPATH:-$(manpath)}"
else
	export MANPATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnuman:${MANPATH:-}"
fi
