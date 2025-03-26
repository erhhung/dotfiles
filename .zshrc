# Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
[ -f "${HOME}/.iterm2_shell_integration.zsh" ] && \
   . "${HOME}/.iterm2_shell_integration.zsh"

autoload -U +X bashcompinit && bashcompinit

[ -f ~/.fzf.zsh ] && \
   . ~/.fzf.zsh

complete -o nospace -C /usr/local/bin/odo odo

# Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
