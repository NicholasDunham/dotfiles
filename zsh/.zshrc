# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Ensure HOMEBREW_PREFIX exists in non-login shells
: "${HOMEBREW_PREFIX:=$(command -v brew >/dev/null 2>&1 && brew --prefix || echo /opt/homebrew)}"
# Initialize Homebrew environment if this is a non-login shell and brew isn't on PATH
if ! command -v brew >/dev/null 2>&1; then
	if [ -x "$HOMEBREW_PREFIX/bin/brew" ]; then
		eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"
	fi
fi

# Shell options and history
setopt prompt_subst
setopt auto_cd auto_pushd
setopt hist_ignore_dups hist_ignore_all_dups share_history inc_append_history extended_history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

# Editor
export EDITOR="emacsclient -c -a ''"
export VISUAL="$EDITOR"

# Completions
if [ -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]; then
	fpath+=("$HOMEBREW_PREFIX/share/zsh/site-functions")
fi
autoload -Uz compinit
mkdir -p "$HOME/.cache/zsh"
# -i: ignore insecure directories instead of erroring/prompting
compinit -i -d "$HOME/.cache/zsh/zcompdump"

# FZF integration (installed via Homebrew)
if [ -r "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh" ]; then
	source "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh"
fi
if [ -r "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]; then
	source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
fi

# Optional: plugins (install: brew install zsh-autosuggestions zsh-syntax-highlighting)
if [ -r "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
	source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Powerlevel10k prompt (Homebrew)
if [ -r "$HOMEBREW_PREFIX/opt/powerlevel10k/share/powerlevel10k/powerlevel10k.zsh-theme" ]; then
	source "$HOMEBREW_PREFIX/opt/powerlevel10k/share/powerlevel10k/powerlevel10k.zsh-theme"
	# If you've configured p10k, load your settings
	if [ -r "$HOME/.p10k.zsh" ]; then
		source "$HOME/.p10k.zsh"
	fi
else
	# Fallback lightweight prompt with Git branch
	autoload -Uz colors vcs_info
	colors
	zstyle ':vcs_info:git:*' formats '%F{green}(%b)%f'
	precmd() { vcs_info }
	PROMPT='%F{cyan}%n@%m%f %F{yellow}%~%f ${vcs_info_msg_0_} %# '
fi

# Aliases
alias ll='ls -lah'
alias grep='grep --color=auto'
if command -v podman >/dev/null 2>&1; then
	alias docker='podman'
fi

# Keep zsh-syntax-highlighting last for performance/correctness
if [ -r "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
	source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Local overrides
if [ -r "$HOME/.aliases" ]; then
	source "$HOME/.aliases"
fi

# Ensure we end startup in a success state to avoid error marker in first prompt
:

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
