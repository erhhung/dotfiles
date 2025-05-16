# Q pre block. Keep at the top of this file.
[ -f "$HOME/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ] && \
   . "$HOME/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

[ -f "$XDG_CONFIG_HOME/iterm2/.iterm2_shell_integration.zsh" ] && \
   . "$XDG_CONFIG_HOME/iterm2/.iterm2_shell_integration.zsh"

autoload -U +X bashcompinit && bashcompinit

[ -f ~/.fzf.zsh ] && \
   . ~/.fzf.zsh

# complete -o nospace -C /usr/local/bin/odo odo
# complete -o nospace -C /usr/local/bin/mc  mc

# Q post block. Keep at the bottom of this file.
[ -f "$HOME/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ] && \
   . "$HOME/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
