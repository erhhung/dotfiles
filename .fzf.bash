# Setup fzf
# ---------
FZF_HOME=$(brew --prefix)/opt/fzf

if [[ ! "$PATH" == *$FZF_HOME/bin* ]]; then
  PATH="${PATH:+$PATH:}$FZF_HOME/bin"
fi

# Auto-completion
# ---------------
. "$FZF_HOME/shell/completion.bash"

# Key bindings
# ------------
. "$FZF_HOME/shell/key-bindings.bash"