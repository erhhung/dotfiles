#!/usr/bin/env bash

# -*- mode: shell-script -*-

# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/bashrc.pre.bash" ]] && \
    . "${HOME}/Library/Application Support/amazon-q/shell/bashrc.pre.bash"

# https://code.visualstudio.com/docs/terminal/shell-integration#_manual-installation
# (ignore error from SecCodeCheckValidity issue: https://github.com/microsoft/vscode/issues/204085)
#[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path bash 2> /dev/null)"

# suppress zsh message in Catalina
BASH_SILENCE_DEPRECATION_WARNING=1

# disable C-s/C-q flow control!
stty -ixon

export LC_COLLATE=C

# https://wiki.archlinux.org/title/XDG_Base_Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# general purpose command-line finder
# https://github.com/junegunn/fzf
#[ -f $HOME/.fzf.bash ] && \
#   . $HOME/.fzf.bash

#export FZF_DEFAULT_OPTS="
#  --pointer ▶
#  --height 33%
#  --layout=reverse
#  --border=rounded
#  --info=inline-right
#  --color prompt:bright-cyan:bold,header:bright-green,pointer:bright-red:bold
#"
#export FZF_CTRL_R_OPTS="
#  --header 'Ctrl-/ to toggle PREVIEW | Ctrl-y to copy to CLIPBOARD'
#  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
#  --preview 'echo {}'
#  --preview-window up:3:hidden:wrap
#  --bind 'ctrl-/:toggle-preview'
#"
# tab completion using fzf
# https://github.com/lincheney/fzf-tab-completion
#[ -f $HOME/.fzf.bash_completion ] && \
#   . $HOME/.fzf.bash_completion
#bind -x '"\t": fzf_bash_completion'

#export FZF_COMPLETION_AUTO_COMMON_PREFIX=true
#export FZF_COMPLETION_AUTO_COMMON_PREFIX_PART=true

#_fzf_bash_completion_loading_msg() {
#  echo -en "\033[38;5;42m╍╍╍╍╍ LOADING MATCHES ╍╍╍╍╍${NOCLR}"
#}

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/bashrc.post.bash" ]] && \
    . "${HOME}/Library/Application Support/amazon-q/shell/bashrc.post.bash"
