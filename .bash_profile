#!/usr/bin/env bash

# -*- mode: shell-script -*-

#===================================#
# Erhhung's .bash_profile for macOS #
#-----------------------------------#
# 100% hand-crafted for my personal #
# workflows. Settings and functions #
# often have external dependencies! #
#===================================#

# Amazon Q pre block. Keep at the top of this file.
[ -f "$HOME/Library/Application Support/amazon-q/shell/bash_profile.pre.bash" ] && \
   . "$HOME/Library/Application Support/amazon-q/shell/bash_profile.pre.bash" &> /dev/null

# https://code.visualstudio.com/docs/terminal/shell-integration#_manual-installation
# (ignore error from SecCodeCheckValidity issue: https://github.com/microsoft/vscode/issues/204085)
[[ "$TERM_PROGRAM" == "vscode" ]] && \
   . "$(code --locate-shell-integration-path bash 2> /dev/null)" &> /dev/null

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

# Bash Line Editor replaces Readline
# https://github.com/akinomyoga/ble.sh
# == conflicts with CodeWhisperer! ==
#. "$XDG_DATA_HOME/blesh/ble.sh"

# Atuin stores shell history in DB
# https://github.com/atuinsh/atuin
#. <(atuin init bash --disable-up-arrow)

# general purpose command-line finder
# https://github.com/junegunn/fzf
[ -f $HOME/.fzf.bash ] && \
   . $HOME/.fzf.bash

# https://vitormv.github.io/fzf-themes/
export FZF_DEFAULT_OPTS="
  --multi
  --pointer=▶
  --marker=•
  --height=33%
  --layout=reverse
  --border=rounded
  --info=inline-right
  --color=prompt:bright-cyan:bold,header:bright-green,pointer:bright-red:bold,marker:yellow:bold
"
export FZF_CTRL_R_OPTS="
  --header 'Ctrl-/ to toggle PREVIEW | Ctrl-y to copy to CLIPBOARD'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --preview 'echo {}'
  --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
"
# tab completion using fzf
# https://github.com/lincheney/fzf-tab-completion
# DISABLED: using CodeWhisperer instead
# curl -sSo ~/.fzf.bash_completion https://raw.githubusercontent.com/lincheney/fzf-tab-completion/master/bash/fzf-bash-completion.sh
[ -f $HOME/.fzf.bash_completion ] && \
   . $HOME/.fzf.bash_completion
bind -x '"\t": fzf_bash_completion'

export FZF_COMPLETION_AUTO_COMMON_PREFIX=true
# https://github.com/lincheney/fzf-tab-completion/issues/91
export FZF_COMPLETION_AUTO_COMMON_PREFIX_PART=true

_fzf_bash_completion_loading_msg() {
  echo -en "\033[38;5;42m╍╍╍╍╍ LOADING MATCHES ╍╍╍╍╍${NOCLR}"
}

# https://github.com/ajeetdsouza/zoxide
export _ZO_DATA_DIR="$XDG_DATA_HOME/zoxide"
# disable possible config issue warning
export _ZO_DOCTOR=0
. <(zoxide init --cmd cd bash)

# https://github.com/jandedobbeleer/oh-my-posh
# https://ohmyposh.dev/docs/installation/macos
[ "$POSH_SESSION_ID" ] || {
  # See available On-My-Posh themes:
  # https://ohmyposh.dev/docs/themes
  OMP_THEME="$XDG_CONFIG_HOME/oh-my-posh/erhhung.omp.yaml"
  . <(oh-my-posh init bash --config $OMP_THEME)
  alias omp='oh-my-posh'
}

# https://github.com/b-ryan/powerline-shell
# activate powerline prompt
#_update_ps1() {
#  PS1=$(powerline-shell $?)
#}
#PS1='\[\033[1;32m\]\h:\[\033[1;36m\]\w\[\033[1;31m\]\$\[\033[0m\] '
#if [[ "$PROMPT_COMMAND" != *_update_ps1* ]]; then
# this will likely break Amazon Q functionality!
#  PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
#fi

# iTerm2 shell integration
# must come after powerline
export ITERM2_SQUELCH_MARK=1
. "$XDG_CONFIG_HOME/iterm2/.iterm2_shell_integration.bash"

HISTSIZE=10000
HISTFILESIZE=$HISTSIZE
HISTTIMEFORMAT='%F %T '
HISTCONTROL=ignorespace:ignoredups
HISTIGNORE='?:??:???:exit:clear*'

shopt -s histappend # append to ~/.bash_history
shopt -s histreedit # reedit failed substitution
shopt -s histverify # review substitution first

_bash_history_sync() {
  builtin history -a
  HISTFILESIZE=$HISTSIZE
}
_bash_history_reload() {
  builtin history -c
  builtin history -r
}
if [[ "$PROMPT_COMMAND" != *_bash_history_sync* ]]; then
  PROMPT_COMMAND="_bash_history_sync; $PROMPT_COMMAND"
fi

history() {
  _bash_history_sync
  _bash_history_reload
  builtin history "$@"
}
alias h1='history 10'
alias h2='history 20'
alias h3='history 30'
alias lh='LESSLEXER=properties less +G ~/.bash_history'

_sudo() {
  security find-generic-password -l sudo -w | \
    $(which sudo) -Sp "" "$@"
}
alias sudo='sudo -E '
alias   ss='sudo su'

# show images inline
alias icat='imgcat'
alias  ils='imgls'

export   ZED='/usr/local/bin/zed'
export EMACS='/usr/local/bin/emacs'
export EDITOR="$ZED -nw"

export CLICOLOR=1
export CLICOLOR_FORCE=1
# export LSCOLORS='ExFxBxDxCxegedabagacad'
. <(gdircolors -b "$HOME/.dircolors")
export GREP_OPTIONS='--color=auto'

# https://min.io/docs/minio/linux/reference/minio-mc-admin.html
export MC_CONFIG_DIR="$XDG_CONFIG_HOME/minio"
export MC_DISABLE_PAGER=1

# https://github.com/dbcli/pgcli
# brew install pgcli
export PSQLRC="$XDG_CONFIG_HOME/pg/config"
export PSQL_HISTORY="$XDG_DATA_HOME/pg/history"
export PGCLIRC="$XDG_CONFIG_HOME/pgcli/config"

# https://www.topbug.net/blog/2016/09/27/make-gnu-less-more-powerful/
# https://www.tutorialspoint.com/unix_commands/less.htm
export LESS='-RFKLMi -x4 -z-4'
export LESSQUIET=1
export LESSCHARSET='utf-8'
export LESS_ADVANCED_PREPROCESSOR=1
export LESSOPEN='|-$XDG_CONFIG_HOME/less/filter %s'
export LESSHISTFILE="$XDG_DATA_HOME/less/history"
export LESSCOLORIZER='pygmentize'

# Pygments style galleries: https://dt.iki.fi/pygments-gallery
# also: https://stylishthemes.github.io/Syntax-Themes/pygments
# more styles: https://github.com/mohd-akram/base16-pygments
#
# === SEE EXAMPLES ===
# while read style; do
#   echo -e "-----\nSTYLE: $style\n-----"
#   PYGMENTSTYLE=$style less -F index.js
#   sleep 1
# done < <(
#   pygmentize -L styles | sed -En 's/^\* +([^:]+):.*/\1/p'
# )
# modified /usr/local/bin/code2color (search "PYGMENTSTYLE")
export PYGMENTSTYLE='base16-materia'

export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

# https://github.com/sharkdp/bat#customization
export BAT_THEME='Visual Studio Dark+'
export BAT_STYLE='grid,numbers'
export BAT_PAGER='less -RFKLMin'

export PAGER='less'
# https://github.com/dandavison/delta
export DELTA_PAGER='less -RFKLMin'

# clear terminal buffer and screen
# https://apple.stackexchange.com/a/318217/209970
c() { printf '\e[2J\e[3J\e[H'; }

# e(dit), l(ess), and r(eload) aliases
alias ebp='z ~/.bash_profile'
alias lbp='l ~/.bash_profile'
alias rbp='. ~/.bash_profile; \
           . ~/.bash_completion'
alias egc='z ~/.config/git/config'
alias esc='z ~/.ssh/config'
alias eac='z ~/.aws/{config,credentials}'

z() {
  local opts=()
  # use the same window if in Zed terminal
  [ "$TERM_PROGRAM" == zed ] || opts+=(-n)
  # fall back to using Emacs if SSH session
  [ "$SSH_CONNECTION" ] && $EMACS "$@" || \
    $ZED "${opts[@]}" "$@"
}
alias e="$EMACS "
alias vim='lvim'
alias vi='lvim'
alias v='lvim '

# attach session if exists
alias tm='tmux new -As main'

# cd $OLDPWD only works in Bash
alias cdd='cd ~-'
# print cwd in shell escaped form
alias pwd='printf "%q\n" "$(builtin pwd)/"'

# suppress stack output
pushd() { command pushd "$@" > /dev/null; }
 popd() { command popd  "$@" > /dev/null; }

# https://www.gnu.org/software/coreutils/manual/html_node/Formatting-file-timestamps.html
export TIME_STYLE='long-iso'

alias ll='gls -alFG --color=always'
alias lt='gls -altr --color=always'

# docs: see nnn man pages
export NNN_OPTS="acdeoAEHQR"
# use original temp file location to cd on quit only on ^G
NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
export NNN_BATTHEME="$BAT_THEME"
export NNN_BATSTYLE='numbers'
# https://user-images.githubusercontent.com/1482942/93023823-46a6ba80-f5e1-11ea-9ea3-6a3c757704f4.png
export NNN_COLORS="#451d64d2;ca3d"
_NNN_ORDER=(
  t:/tmp
  t:$HOME/Downloads
  t:$HOME/Screenshots
)
printf -v NNN_ORDER "%s;" "${_NNN_ORDER[@]}"
   export NNN_ORDER="${NNN_ORDER/%;/}"
# https://github.com/jarun/nnn/tree/master/plugins#list-of-plugins
export NNN_PLUG="v:-preview-tui;y:-cbcopy-mac"
export NNN_OPENER="$XDG_CONFIG_HOME/nnn/plugins/nuke"
# https://github.com/jarun/nnn/blob/master/plugins/preview-tui#L99-L116
export NNN_PAGER='less -rLMin+g'
export NNN_SPLIT='h'

# launch the nnn file manager
# https://github.com/jarun/nnn
n() {
  [ "${NNNLVL:-0}" -eq 0 ] || {
    echo "nnn is already running"
    return
  }
  stty lnext undef
  stty start undef
  stty stop  undef

  # nuke plugin uses $VISUAL to show file;
  # when in nnn UI, disable less -F option
  # that auto quits if less than screenful
  VISUAL='bat' \
  BAT_PAGER="$NNN_PAGER" \
  LESS="${NNN_PAGER/* /}" \
    command nnn "$@"

  [ !  -f "$NNN_TMPFILE" ] || {
    .     "$NNN_TMPFILE"
    rm -f "$NNN_TMPFILE" > /dev/null
  }
}

# Homebrew shortcuts
alias b='brew '
alias bi='b install'
alias bu='b upgrade'
alias bo='b outdated'

# sets HOMEBREW_* vars like HOMEBREW_PREFIX
. <(brew shellenv)

# default max age is 120 days
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=90

# print formula path
# brewpath <formula>
brewpath() {
  local paths
  paths=$(find "$HOMEBREW_CELLAR/${1:-_NA_}" \
           -depth 1 2> /dev/null) || return
  sort -V <<< "$paths" | tail -1
}

# upgrade specified (or all) outdated Homebrew
# formulae and casks, and record upgrade stats
bup() (
  # ensure helper tools available
  _reqcmds brew jo jq yq || return

  # static list of formulae to
  # not upgrade by this script
  SKIP=(
    aws-c-auth   # long cleanup
    aws-crt-cpp  # long deps check
    aws-sdk-cpp  # takes >2 hours!
    apache-arrow # dep aws-sdk-cpp
  )
  color_ltcyan "Checking for outdated formulae and casks..."
  args=(--json) # args=(--greedy --json)
  json=$(brew outdated "${args[@]}" "$@")
  date=$(_altcmd gdate date)

  # must invoke `jo -a <<< "$@"` in case SKIP/"$@" is empty
  formulae=($(jq -r --argjson skip "$(jo -a <<< "${SKIP[@]}")" \
                    --argjson only "$(jo -a <<<       "$@")" \
    '.formulae[] | select( (.pinned | not) and
        ([.name] | inside($skip)    | not) and
       (([.name] | inside($only)) or ($only == []))
      ) | .name' <<< "$json"))
  casks=($(jq -r --argjson only "$(jo -a <<< "" "$@")" \
    '.casks[] | select(
       (([.name] | inside($only)) or ($only == []))
      ) | .name' <<< "$json"))

  # don't start an upgrade unless minute is < 50
  # and mod 10 < 5 (don't ask--it's an OCD thing)
  delay() {
    local  min ts msg=""
    while  min=$($date +%M) && \
      (( ${min#0} % 10 > 4  || \
         ${min#0} > 44 ));  do

      if [ ! "$msg" ]; then
         ts=$($date +%s);  ts=$(bc <<< "($ts + 300) / 600 * 600")
        min=$($date +%M -d @$ts); [ $min == 50 ] && ((ts += 600))
        msg="Pausing until $($date +"%m/%d/%Y %H:%M" -d @$ts)..."
        color_pink "\n$msg"
      fi
      sleep 1
    done
  }
  # record upgrade stats into
  # $XDG_CONFIG_HOME/homebrew/upgrades.yaml
  # record <name> <ts-start> <duration-sec>
  record() {
    local  file="$XDG_CONFIG_HOME/homebrew/upgrades.yaml"
    [ -f "$file" ] || printf "[]" > "$file"

    # export stats for yq
    export stats=$(jq -cM \
      --arg     name "$1" \
      --arg     date "$($date +"%Y-%m-%d %H:%M:%S" -d @$2)" \
      --argjson dur  "$3" \
      '.formulae[]?, .casks[]? |
        select(.name == $name) |
      { name,
        version: .current_version,
        date:     $date,
        duration: $dur,
      }' <<< "$json")

    yq -i 'env(stats) as $stats | [$stats] +
      [.[] |  select(.name != $stats.name)]
           | sort_by(.name)' "$file"
  }
  args=() # upgrade all formulae first, then casks
  upgrades=("${formulae[@]}" --cask "${casks[@]}")

  for name in "${upgrades[@]}"; do
    [ "$name" == --cask ] && {
      args+=($name); continue
    }
    delay
    ts0=$($date +%s);  ts=$($date +"%m/%d/%y %H:%M:%S" -d @$ts0)
    echo -e "$WHITE\n[$ts]$LTBLUE Upgrading \"$name\"...$NOCLR"

    # HINT: add sudo privilege for "brew upgrade --cask *"
    # to sudoers.d to suppress interactive password prompt
    brew upgrade "${args[@]}" $name

    ts1=$($date +%s)
    dur=$((ts1-ts0))
    record $name $ts0 $dur
  done
)

# allow running "bat" on stdin
# and also specifying language
l() {
  # https://github.com/sharkdp/bat
  # BAT_PAGER should be configured
  local bat="bat $BAT_OPTS" opt
  [ -t 0 ] || { [ "$1" ] && opt='--language'; }
  { [ ! -t 0 ] || [ "$1" ]; } && $bat $opt "$@"
}
r() {
  # https://github.com/Textualize/rich-cli
  if [ "$1" ]; then
    rich --theme $PYGMENTSTYLE \
         --force-terminal \
         --pager "$@"
  else
    rich --help
  fi
}

# w shadows /usr/bin/w
alias w='watch --color '

# show pretty system information
# https://github.com/fastfetch-cli/fastfetch
alias ff='fastfetch'

# csvlens is a CSV viewer
# https://github.com/YS-L/csvlens
alias csv='csvlens'

# Frogmouth is a terminal Markdown viewer
# https://github.com/Textualize/frogmouth
alias fm='frogmouth'

alias m='most'
alias o='open'

# go to local port in browser
# usage: ol [-s] <port> [path]
#        -s use https instead
ol() {
  local proto='http'
  [ "$1" == -s ] && {
    proto+='s'; shift
  }
  local port=$1 path=$2
  [ "$port" ] || {
    echo "Go to local port in browser"
    echo "Usage: ol [-s] <port> [path]"
    echo "       -s use https instead"
    return
  }
  [[ "$port" =~ ^[0-9]+$ ]] || {
    echo >&2 "Invalid port: $port"
    return 1
  }
  local url="$proto://localhost:$port/"
  url+=$(sed -E 's|^/+||' <<< "$path")
  echo "Opening $url"
  open "$url"
}

# dt is visual difftool just like "git dt"
alias dt='code --new-window --wait --diff'

# run chatgpt command with leading space so
# the command isn't saved into Bash history
alias ai=' chatgpt'

rsync() {
  local opts=(
    # -vrultO
    --verbose        # increase verbosity
    --recursive      # recurse into directories
    --update         # skip files that are newer on receiver
    --links          # copy symlinks as symlinks
    --times          # preserve times
    --omit-dir-times # omit directories when preserving times
    --progress       # show progress during transfer
  )
  # use "sudo rsync" on "cosmos" in order to
  # set timestamps of files not owned by the
  # SSH user (requires /etc/sudoers setting)
  [[ "$*" =~ (^|\s)(cosmos|home): ]] && \
    opts+=(--rsync-path="sudo rsync")

  "$(which rsync)" "${opts[@]}" "$@"
}

alias rc='rclone'
alias f='fabric'

# brew install gnu-time
alias time='gtime -f "\n Total time: %E\n  User mode: %Us\nKernel mode: %Ss\nPercent CPU: %P" '

# npm i -g http-server
alias web='http-server'

# change title of terminal window/tab
_title() {
  [ "$1" ] || set -- ${1:-`basename $SHELL`}
  echo -en "\033]0;$*\007"
}
alias tt='_title'

alias pbc='pbcopy'
alias pbp='pbpaste'

# move cursor up n lines while
# optionally erasing each line
# _uplns [-k] <n>
#   -k: do NOT erase each line
_uplns() {
  local s="\x1B[1A" # move up
  [ "$1" == -k ] && shift || \
    s+="\x1B[0K" # erase line

  local n=${1:-0}
  while [ $n -gt 0 ]; do
    echo -ne "$s"; ((n--))
  done
}

hidecursor() { echo -en "\e[?25l"; }
showcursor() { echo -en "\e[?25h"; }

# Black        0;30     Dark Gray     1;30
# Blue         0;34     Light Blue    1;34
# Green        0;32     Light Green   1;32
# Cyan         0;36     Light Cyan    1;36
# Red          0;31     Light Red     1;31
# Magenta      0;35     Light Magenta 1;35
# Brown/Orange 0;33     Yellow        1;33
# Light Gray   0;37     White         1;37

# do not use ANSI-C quoting ($'\033['), or else the "title"
# function will not be able to strip these escape sequences
export   NOCLR='\x1B[0m'
export   BLACK='\x1B[0;30m'; color_black()   { echo -e   "${BLACK}$*${NOCLR}"; }; export -f color_black
export    GRAY='\x1B[1;30m'; color_gray()    { echo -e    "${GRAY}$*${NOCLR}"; }; export -f color_gray
export  LTGRAY='\x1B[0;37m'; color_ltgray()  { echo -e  "${LTGRAY}$*${NOCLR}"; }; export -f color_ltgray
export   WHITE='\x1B[1;37m'; color_white()   { echo -e   "${WHITE}$*${NOCLR}"; }; export -f color_white
export     RED='\x1B[0;31m'; color_red()     { echo -e     "${RED}$*${NOCLR}"; }; export -f color_red
export  ORANGE='\x1B[1;31m'; color_orange()  { echo -e  "${ORANGE}$*${NOCLR}"; }; export -f color_orange
export   GREEN='\x1B[0;32m'; color_green()   { echo -e   "${GREEN}$*${NOCLR}"; }; export -f color_green
export LTGREEN='\x1B[1;32m'; color_ltgreen() { echo -e "${LTGREEN}$*${NOCLR}"; }; export -f color_ltgreen
export   OCHRE='\x1B[0;33m'; color_ochre()   { echo -e   "${OCHRE}$*${NOCLR}"; }; export -f color_ochre
export  YELLOW='\x1B[1;33m'; color_yellow()  { echo -e  "${YELLOW}$*${NOCLR}"; }; export -f color_yellow
export    BLUE='\x1B[0;34m'; color_blue()    { echo -e    "${BLUE}$*${NOCLR}"; }; export -f color_blue
export  LTBLUE='\x1B[1;34m'; color_ltblue()  { echo -e  "${LTBLUE}$*${NOCLR}"; }; export -f color_ltblue
export MAGENTA='\x1B[0;35m'; color_magenta() { echo -e "${MAGENTA}$*${NOCLR}"; }; export -f color_magenta
export    PINK='\x1B[1;35m'; color_pink()    { echo -e    "${PINK}$*${NOCLR}"; }; export -f color_pink
export    CYAN='\x1B[0;36m'; color_cyan()    { echo -e    "${CYAN}$*${NOCLR}"; }; export -f color_cyan
export  LTCYAN='\x1B[1;36m'; color_ltcyan()  { echo -e  "${LTCYAN}$*${NOCLR}"; }; export -f color_ltcyan

export   THUMBUP=$'\U1F44D'
export THUMBDOWN=$'\U1F44E'
export CHECKMARK=$'\u2714'

# strip ANSI color codes
noclrs() {
  sed -E 's/(\x1B|\\x1B|\033|\\033)\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g'
}

# echo RGB color sequence
# without text (echo -en)
rgb_fg() { _rgb $1 $2 $3 fg; }
rgb_bg() { _rgb $1 $2 $3 bg; }

# _rgb R G B [bg]
_rgb() {
  local r g b bg=38
  [ "$4" == bg ] && bg=48
  isDigit() { [ "$1" ] && [ ${1-0} -eq ${1-1} 2> /dev/null ]; }
  isDigit $1 && r=$1 || return
  isDigit $2 && g=$2 || return
  isDigit $3 && b=$3 || return
  echo -en "\033[${bg};2;${r};${g};${b}m"
}

# show 256-color table
# https://stackoverflow.com/a/69648792/347685
colors256() {
  local row col blkrow blkcol r g b
  local color=_color256_${1:-bg}

  echo
  echo -e "Set foreground color: \\\\033[38;5;${WHITE}NNN${NOCLR}m"
  echo -e "Set background color: \\\\033[48;5;${WHITE}NNN${NOCLR}m"
  echo -e "Reset  color & style: \\\\033[0m"
  echo

  echo 16 standard color codes:
  for row in {0..1}; do
    for col in {0..7}; do
      $color $(( row*8 + col )) $row
    done
    echo
  done
  echo

  echo 6·6·6 RGB color codes:
  for blkrow in {0..2}; do
    for r in {0..5}; do
      for blkcol in {0..1}; do
        g=$(( blkrow*2 + blkcol ))
        for b in {0..5}; do
          $color $(( r*36 + g*6 + b + 16 )) $g
        done
        echo -n "  "
      done
      echo
    done
    echo
  done

  echo 24 grayscale color codes:
  for row in {0..1}; do
    for col in {0..11}; do
      $color $(( row*12 + col + 232 )) $row
    done
    echo
  done
  echo
}

_color256_fg() {
  local code=$(printf %03d $1)
  echo -ne "\033[38;5;${code}m"
  echo -nE " $code "
  echo -ne "\033[0m"
}

_color256_bg() {
  if (( $2 % 2 == 0 )); then
    echo -ne "\033[1;37m"
  else
    echo -ne "\033[0;30m"
  fi
  local code=$(printf %03d $1)
  echo -ne "\033[48;5;${code}m"
  echo -nE " $code "
  echo -ne "\033[0m"
}

# show 16-color table
colors16() {
  echo
  _color16 "\033[0;30m" "\033[1;30m" "\033[40m" "\033[100m"
  _color16 "\033[0;31m" "\033[1;31m" "\033[41m" "\033[101m"
  _color16 "\033[0;32m" "\033[1;32m" "\033[42m" "\033[102m"
  _color16 "\033[0;33m" "\033[1;33m" "\033[43m" "\033[103m"
  _color16 "\033[0;34m" "\033[1;34m" "\033[44m" "\033[104m"
  _color16 "\033[0;35m" "\033[1;35m" "\033[45m" "\033[105m"
  _color16 "\033[0;36m" "\033[1;36m" "\033[46m" "\033[106m"
  _color16 "\033[0;37m" "\033[1;37m" "\033[47m" "\033[107m"
  echo
}

_color16() {
  for code in $@; do
    echo -ne "$code"
    echo -nE "  $code"
    echo -ne "  \033[0m  "
  done
  echo
}

# get first command
# available in $PATH
# example: _altcmd gsort sort
# this is primarily so that GNU gFOO commands
# (from coreutils) can be used on macOS while
# on Linux the standard GNU command gets used
_altcmd() {
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" &> /dev/null || continue
    printf $cmd
    return 0
  done
  return 1
}

# require given commands
# to be $PATH accessible
# example: _reqcmds aws jq || return
_reqcmds() {
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" &> /dev/null && continue
    echo >&2 "Please install \"$cmd\" first!"
    return 1
  done
}

# require given functions
# to be defined in shell
# example: _reqfuncs title || return
_reqfuncs() {
  local func
  for func in "$@"; do
    if [ `type -t "$func"` != function ]; then
      echo >&2 "Function $func() not defined!"
      return 1
    fi
  done
}

# require given environment
# variables to be non-empty
# example: _reqvars PGPASSWORD || return
_reqvars() {
  local var
  for var in "$@"; do
    if [ ! "${!var}" ]; then
      echo >&2 "Variable \"$var\" not defined!"
      return 1
    fi
  done
}

# require given files to exist
# example: _reqfiles foo.sh bar.jq || return
_reqfiles() {
  local file
  for file in "$@"; do
    if [ ! -f "$file" ]; then
      echo >&2 "File not found: ${file/#$HOME/\~}"
      return 1
    fi
  done
}

# prompt user to press a single key
# prompt1 <message> <choices> [default]
# case of <choices> & <default> ignored
# returns a char in <choices> in lower
# allow Enter only if default provided
# example: prompt1 "\nContinue?" yn N
#          prompt1 "\nPress any key:"
prompt1() {
  local msg keys def key
  msg="${1%%+([[:space:]])}"
  keys="${2,,}" def="${3^^}"

  [[ "$keys" || ${#def} -eq 1 ]] || \
  [[ "$keys" ==  *"${def,,}"* ]] || return

  [ "$msg"  ] && echo >&2 -en "$msg " # output choices: use upper + color to highlight default response
  [ "$keys" ] && echo >&2 -en "$WHITE[${LTCYAN}${keys/${def,,}/${LTGREEN}${def}${LTCYAN}}$WHITE]$NOCLR "

  while true; do
    read -rsn 1 key
    # return nothing if allow any key
    [ "$keys" ] || return 0

    # ignore key press if not a choice
    [[ "$key" || "$def" ]] || continue
    key="${key:-$def}"; key="${key,,}"
    [[ "$keys" == *"$key"* ]] || continue

    # response accepted! output response in color
    # to stderr, but return single char on stdout
    echo >&2 -en "$YELLOW"
    echo      -n "$key"
    echo >&2 -e  "$NOCLR"
    return
  done
}

# print given title with
# another line of dashes
title() {
  local s="$*" d l t
  echo -e "$s"

  # use PCRE (*SKIP)(*F) trick to preserve ANSI
  # color codes while replacing all other chars
  d="$(perl -pe 's/(?:\\(033|x1B)\[[0-9;]*[mGKHF])(*SKIP)(*F)|./-/g' <<< "$s")"

  #  remove  leading and trailing dashes
  # matching leading and trailing spaces
  l="${s%%[^[:space:]]*}" #  leading spaces
  t="${s##*[^[:space:]]}" # trailing spaces
  echo -e "$l${d:${#l}:${#d}-${#l}-${#t}}$t"
}

# right-justify lines
_rjust() {
  local line max_w list=$(cat -)
  max_w=$(awk '{if (length>L) {L=length} } END {print L}' <<< "$list")
  while read line; do printf "%${max_w}s\n" "$line"; done <<< "$list"
}

# get max width of args
_maxwidth() {
  local str len max=0
  for str in "$@"; do
    len=${#str}
    ((max=len>max?len:max))
  done
  echo $max
}

# get max widths of
# one-word  columns
_colwidths() {
  noclrs | \
     awk '{for (i=1; i<=NF; i++) {l=length($i); if (l>L[i]) L[i]=l;}} END \
          {for (i=1; i<=length(L); i++) {printf L[i] "\n";}}'
}

# format one-word columns
# with each left-justified
cols() {
  local w seq tbl=$(cat)
  [ "$tbl" ] || return 0

  w=($(_colwidths <<< "$tbl"))
  ((seq = ${#w[@]} - 2))
  seq=($(seq 0 $seq))

  local vals
  while read -ra vals; do
    local i val pad out=""
    for i in ${seq[@]}; do

      val="$(noclrs <<< "${vals[$i]}")"
      ((pad = ${w[i]} - ${#val}))
      printf -v pad "%${pad}s" ""
      out+="${vals[$i]}$pad  "
    done
    echo -e "$out${vals[-1]}"
  done  <<< "$tbl"
}

# convert x.y.z version to 9-digit number for comparison
# _ver2num 3.14.159 = 003014159
_ver2num() {
  printf "%03d%03d%03d" $(tr . ' ' <<< "$1") 2> /dev/null
}

# toggle visibility of hidden files in Finder
# (please use showhidden/hidehidden aliases)
_hiddenfiles() {
  defaults write com.apple.finder AppleShowAllFiles "$1"
  killall Finder /System/Library/CoreServices/Finder.app
}
alias showhidden='_hiddenfiles YES'
alias hidehidden='_hiddenfiles NO'

# helper for _touch and touchall
__touch_date() {
  local d=$(date '+%Y%m%d%H%M.00')
  if [ "$1" != -t ]; then
    echo "$d"
    return
  fi
  local t=${2// /}; t=${t//-/} t=${t//:/}
  if [[ ! "$t" =~ ^[0-9]{0,12}$ ]]; then
    echo >&2 'Custom time must be all digits!'
    return 1
  fi
  if [ $((${#t} % 2)) -eq 1 ]; then
    echo >&2 'Even number of digits required!'
    return 1
  fi
  local n=$((12 - ${#t}))
  echo "${d:0:$n}$t.00"
}

# usage: _touch [-t time] <files...>
# -t: digits in multiples of 2 replacing right-most
#     digits of current time in yyyyMMddHHmm format
_touch() {
  local d=$(__touch_date "$@") || return
  [ "$1" == -t ] && shift 2
  touch -cht "$d" "$@"
}
alias t='_touch '
alias t0='t -t 00'

# recursively touch files & directories
# usage: touchall [-d] [-t time] [path]
# -d: touch directories only
# -t: digits in multiples of 2 replacing right-most
#     digits of current time in yyyyMMddHHmm format
touchall() {
  local d fargs=()
  if [ "$1" == -d ]; then
    fargs=(-type d); shift
  fi
  d=$(__touch_date "$@") || return
  [ "$d" ] && shift 2
  find "${@:-.}" "${fargs[@]}" -exec touch -cht "$d" "{}" \;
}
alias ta='touchall '
alias ta0='ta -t 00'
alias tad='ta -d '
alias tad0='tad -t 00'

# chmod 755 on dirs and 644 on files in
# current dir, then clear extended attrs
fixperms() (
  find . -maxdepth 1 \( -type d -or -type l \) -exec chmod 755 "{}" \;
  find . -maxdepth 1    -type f                -exec chmod 644 "{}" \;
  # use nullglob to silent 0 matches
  shopt -s nullglob; xattr -c . .* *
)

# helper func for fixdates
# _fixdates <count> [cols]
# count: files updated (return value)
#  cols: current terminal column width
_fixdates() {
  # ensure  _touch() defined
  _reqfuncs _touch || return

  local _count_ orig fixed
  # _count is pass-by-ref arg
  local -n _count=${1:-_count_}
  _count=0

  local ls d t f cols=$2
  [ "$cols" ] || cols=$(tput cols)
  local date=$(_altcmd gdate date)

  while read ls; do
    ls="${ls/->*/}"     # discard symlinks
    ls="${ls//\`/\\\`}" # escape backticks
    eval "ls=(${ls})"
    d="${ls[5]}"
    t="${ls[6]}"
    f="${ls[7]}"
    # skip if parent dir or minutes ends in [0-6]
    [[ "$f" != .. && "$t" =~ [7-9]$ ]] || continue

    # use cached fixed date/time if
    # file date/time same as before
    if [ "$d $t" != "$orig" ]; then
      orig="$d $t"
      # convert to Unix time
      t=$($date +%s -d "$orig")
      # round to nearest 10-min
      t=$(bc <<< "scale=3; t=${t}/600+0.5; scale=0;t/=1; t*600")
      # back to original form
      fixed=$($date +"%Y-%m-%d %H:%M" -d @$t)
    fi
    echo -e "${GRAY}${orig}${CYAN} => ${WHITE}${fixed}${CYAN} | ${NOCLR}${f::$cols-40}"
    _touch -t "$fixed" "$f" && ((_count++))
  done < <(`_altcmd gls ls` -latrQ)
}

# because I have OCD!
# fixdates [-r [max-depth]] [dirs...]
# dirs: specific dirs only; default .
fixdates() (
  # ensure  title() defined
  _reqfuncs title || exit

  # avoid cursor jumping up & down
  hidecursor; trap showcursor EXIT

  [ "$1" == -r ] && {
    # -mindepth and -maxdepth
    #  must come before -type
    find_args=(. -mindepth 1)

    [[ "$2" =~ ^[[:digit:]]+$ ]] && {
      find_args+=(-maxdepth $2)
      shift
    }
    find_args+=(-type d)
    shift
  }
  dirs=("${1:-.}" "${@:2}")
  for dir in "${dirs[@]}"; do (
    builtin cd "$dir" || exit
    [ "$1" ] && {
      echo; title "${LTCYAN}${dir%/}${NOCLR}"
    }
    if [ "$find_args" ]; then
      while read subdir; do
        cols=$(tput cols)
        # mask contains all spaces
        printf -v mask '%*s' $cols

        text="${subdir:2:$cols}"
        blank="${mask:${#text}}"
        echo; title "${LTGREEN}$text${NOCLR}$blank"
        (
           local countA
           builtin  cd "$subdir"
          _fixdates countA $cols
          ((countA)) || _uplns -k 3
        )
      done < <(find "${find_args[@]}")
      echo; title "${LTGREEN}./${NOCLR}"
    fi
    local countB
    _fixdates countB
    [ "$find_args" ] && ! ((countB)) && _uplns 3
  ); done
)

# set current date/time according to google.com
syncdate() {
  # ensure htpdate installed
  _reqcmds htpdate || return

  local proxy
  [ "$http_proxy" ] && proxy="-P $(
    cut -d/ -f3- <<< "$http_proxy")"
  _sudo htpdate -s $proxy google.com
}

alias p8='ping 8.8.8.8'
alias pg='ping google.com'

# generate configured TOTP codes
totp() {
  # ensure totp-cli/secure-pbcopy installed
  _reqcmds totp-cli secure-pbcopy || return

  [ "$1" ] || return
  local ns=$1 acct=$2 pass
  [ "$acct" ] || { acct=$ns ns=personal; }
  pass=$(security find-generic-password -l totp-cli -w)
  pass=$(TOTP_PASS="$pass" totp-cli g "$ns" "$acct") && \
    # https://github.com/alyssais/secure-pbcopy
    { echo $pass; printf $pass | secure-pbcopy; }
}

alias wifioff='networksetup -setnetworkserviceenabled "Wi-Fi" off'
alias  wifion='networksetup -setnetworkserviceenabled "Wi-Fi" on'
alias  ethoff='networksetup -setnetworkserviceenabled "Display Ethernet" off'
alias   ethon='networksetup -setnetworkserviceenabled "Display Ethernet" on'

# change location
# chloc <location>
chloc() {
  local loc
  if loc="$(networksetup -listlocations | grep -i -m 1 "$1")"; then
    networksetup -switchtolocation "$loc" > /dev/null
  else
    return 1
  fi
}

# clear local DNS cache
flushdns() {
  _sudo dscacheutil -flushcache
  _sudo killall -HUP mDNSResponder
}

# get IPs from the specified nslookup host
dnsips() {
  nslookup "$1" | \
    grep 'Address: ' | \
    colrm 1 9 | sort -V
}
alias ns='nslookup'

# show TCP ports currently in LISTEN state
listening() {
  _sudo lsof -nP -iTCP -sTCP:LISTEN +c0 | \
    awk 'NR>1 { # skip header line
           i = split($9, p, ":");
           printf  "%u %s\n", p[i], $1
        }' | sort -n | uniq | cols
}

# check TCP port connectivity
# usage: port <port> [host]
# default host is localhost
port() {
  [ "$1" ] || {
    cat <<EOT

Check TCP port connectivity
Usage: port <port> [host]
Default host is localhost

EOT
    return 0
  }
  local port=$1 host=${2:-localhost}
  if [ "${port-0}" -eq "${port-1}" ] 2> /dev/null; then
    # on Linux: head -n2 | tail -n1 | colrm 1 6
    nc -zv -w1 "$host" "$port" 2>&1 | head -n1
  else
    echo >&2 "Invalid port!"
    return 1
  fi
}

# create TCP tunnel using ncat between localhost and remote
# usage: tcptunnel <remote_host> <remote_port> [local_port]
tcptunnel() {
  # ensure ncat installed
  _reqcmds ncat || return

  local host=$1 port=$2
  local listen=${3-$port}

  if [[ -z "$host" || ! "$port$listen" =~ ^[0-9]+$ ]]; then
    echo >&2 'Usage: tcptunnel <remote_host> <remote_port> [local_port]'
    return 1
  fi

  echo "Creating TCP tunnel: localhost:$listen <==> $host:$port"
  local proxy=$([ "$http_proxy" ] && echo \
      "-proxy $(cut -d/ -f3- <<< $http_proxy | cut -d: -f1):1080 --proxy-type socks5")
  ncat --listen localhost $listen --keep-open --sh-exec "ncat $proxy $host $port"
}

# tunnel whois over SOCKS proxy if necessary
whois() {
  if [ -z "$http_proxy" ]; then
    # forward to whois executable
    local whois=$(which whois) && $whois "$@"
    return $?
  fi
  # ensure ncat installed
  _reqcmds ncat || return

  local domain host port
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h)   host=$2; shift ;;
      -p)   port=$2; shift ;;
       *) domain=$1;       ;;
    esac
    shift
  done
  host=${host:-whois.internic.net}
  port=${port:-43}

  if ! [ ${port-0} -eq ${port-1}] 2> /dev/null; then
    echo >&2 "Invalid port!"
    return 1
  fi
  if [ -z "$domain" ]; then
    echo >&2 "Missing domain!"
    return 1
  fi

  ncat $host $port \
    --proxy-type socks5 \
    --proxy $(cut -d/ -f3- <<< $http_proxy | cut -d: -f1):1080 \
    <<< "domain $domain"
}

# functions like traceroute and ping
# https://github.com/fujiapple852/trippy
alias trip='trip -uc $XDG_CONFIG_HOME/trippy/config.toml'

# show details of certificate chain from
# stdin, PEM file, website or K8s secret
cert() {
  _reqcmds openssl || return
  local stdin host port args

  if [ -p /dev/stdin ]; then
    stdin=$(cat)
  else
    [ "$1" ] || {
      cat <<EOT

Show details of certificate chain from
stdin, PEM file, website or K8s secret

Usage: cert [file | host=. [port=443]]
       cert -k [namespace/]<tls-secret>
All args ignored if stdin is available

cert < website.pem       # standard input
cert   website.pem       # local PEM file
cert   website.com       # website.com:443
cert   website.com:8443  # website.com:8443
cert   8443              # localhost:8443
cert   .                 # localhost:443
cert -k namespace/secret # K8s "tls.crt"
EOT
      return 0
    }
    # certs from K8s secret
    if [ "$1" == -k ]; then
      _reqcmds kubectl || return
      local secret=$2

      [[ "$secret" == */* ]] && {
        args+=(-n ${secret%/*})
        secret=${secret#*/}
      }
      stdin=$(kubectl get secret $secret "${args[@]}" \
        -o jsonpath='{ .data.tls\.crt }' | base64 -d)
    else
      host=${1:-localhost}
      [ "$host" == . ] && host=localhost
      # strip scheme & path if is an URL
      host=${host#*://}; host=${host%%/*}
      port=${2:-443}

      # handle host:port syntax
      [[ "$host" == *:* ]] && {
        port=${host#*:}
        host=${host%%:*}
      }
      # handle if only port number given
      if [ "${host-0}" -eq "${host-1}" ] 2> /dev/null; then
        port=$host
        host=localhost
      fi
      # use proxy for s_client if needed
      [ "$http_proxy" ] && args+=(-proxy
        $(cut -d/ -f3- <<< "$http_proxy")
      )
    fi
  fi

  local cert="" line out
  while read -r line; do
    # concatenate lines in each cert block
    # until ";" delimiter from awk command
    if [ "$line" == ';' ]; then
      out=$(openssl x509 -text -inform pem -noout <<< "$cert")
      [ "$out" ] && echo -e "\n$out"
      cert=""
    else
      cert+="$line"$'\n'
    fi
  done < <(
    if [ "$stdin" ]; then
      # certs from stdin
      echo "$stdin"
    elif [ -f "$host" ]; then
      # certs from file
      cat "$host"
    else
      # certs from host
      args=(
        s_client "${args[@]}"
        -connect "$host:$port"
        -showcerts
      )
      openssl "${args[@]}" <<< ""
    fi 2> /dev/null | \
      awk '
      /-----BEGIN CERTIFICATE-----/,
        /-----END CERTIFICATE-----/
      ' | \
      awk 'BEGIN {
        cert=""
        }
        /-----BEGIN CERTIFICATE-----/ {
          cert=$0
          next
        }
        /-----END CERTIFICATE-----/ {
          # output ";" as delimiter
          # between each cert block
          cert=cert"\n"$0"\n;"
          print cert
          cert=""
          next
        } {
          cert=cert"\n"$0
        }'
  )
  [ "$POSH_THEME" ] || [ "out" ] && echo
}

# show disk usage (use du0/du1 aliases)
_diskusage() {
  local depth=${1:-1} path=${2:-.}
  local sort=$(_altcmd gsort sort)
  du -d $depth -x -h "${path/%\//}"     \
    2> >(grep -v 'Permission denied') | \
    $sort -h
}
alias du0='_diskusage 0'
alias du1='_diskusage 1'

# interactive disk usage explorer
# brew install gdu
alias gdu='gdu-go'

# delete files and/or dirs older than x days
# rmold [--confirm] <days> [path] [findopts]
# if days < 0, find files newer than x days
rmold() {
  if [ -z "$1" ]; then
    echo 'rmold [--confirm] <days> [path] [find_opts]'
    echo 'Performs dry run unless --confirm specified'
    return
  fi

  local conf=$1
  [[ "$conf" == '--confirm' ]] && shift

  local days=$1; shift
  if ! [ ${days-0} -eq ${days-1} 2> /dev/null ]; then
    echo >&2 'Days must be an integer!'
    return 1
  fi
  [[ $days -lt 0 ]] || days="+$days"

  local find=$(_altcmd gfind find)
  if [[ "$conf" == '--confirm' ]]; then
    $find -maxdepth 1 ! -path . -mtime "$days" "$@" -exec rm -rf "{}" \;
  else
    $find -maxdepth 1 ! -path . -mtime "$days" "$@" -printf "%T@ [%TD %TH:%TM] %s %p\n" 2> /dev/null \
      | sort -n | awk '{ hum[1]=" B";
      hum[1024^4]="TB"; hum[1024^3]="GB";
      hum[1024^2]="MB"; hum[1024  ]="KB";
      for (x = 1024^4; x > 0; x /= 1024) {
        if ($4 >= x) {
          printf $2" "$3"  %3.f %s  ", $4/x, hum[x];
          s=""; for (i=5; i<=NF; i++) {
            printf "%s%s", s, $i; s=OFS;
          }
          printf "\n"; break;
        }
      }}';
  fi
}

# delete macOS-specific files and/or dirs
# (._*, .DS_Store, .Trashes, .Spotlight*,
# and .fseventsd) under current directory
# rmmac [--confirm]
rmmac() {
  # ensure fd installed
  _reqcmds fd || return

  local conf=$1 j=$((`nproc`*4))
  local name names=(
    '._*        ,-tf;-v'
    '.DS_Store  ,-tf;-v'
    '.Trashes   ,-td;-rf'
    '.Spotlight*,-td;-rf'
    '.fseventsd ,-td;-rf'
  )
  { for name in "${names[@]}"; do
      local opts fdopts rmopts cmd
        opts="${name/*,/}"
        name="${name/,*/}"
        name="${name%%*( )}"
      fdopts="${opts/;*/}"
      rmopts="${opts/*;/}"

      [ "$conf" == --confirm ] && \
        cmd='-x rm '$rmopts' "{}"'
      eval "fd -gu $fdopts -j $j '$name' $cmd"
    done
  } | sort
}

# just print a reminder to use the
# qmv/qcp/imv/icp from renameutils
rename() {
  echo "Use qmv/qcp/imv/icp from renameutils."
  echo " https://www.nongnu.org/renameutils/"
}

# get file system type of a mounted directory
fstype() {
  local mounted
  if mounted="$(mount | grep -E "\son\s+$(realpath "$1")\s")"; then
    echo "$mounted" | sed -En 's/.*[(]([a-z]+),.*/\1/p'
  else
    return 1
  fi
}
# _sshfs <host> <mtpt> [opts]
_sshfs() {
  local host="$1" mount="$2"
  local opts=(
    # set volname or else mount folder will
    # appear as "OSXFUSE Volume 0" in Finder
    volname="$(basename "$mount")"
    transform_symlinks
    follow_symlinks
    disable_hardlink
    # suppress ._*
    noappledouble
  )
  opts="${opts[*]}" opts="${opts// /,}"
  # append more options if provided
  [ "$3" ] && opts+=",${3// /,}"

  if ! fstype "$mount" > /dev/null; then
    # create mount folder if missing
    [ -d "$mount" ] || mkdir "$mount"

    local msg="${WHITE}Mounting ${LTBLUE}${host}${WHITE}"
    msg+=" on ${LTBLUE}${mount}${WHITE} with options"
    echo -e "$msg \"${CYAN}${opts}${NOCLR}\"...${NOCLR}"
    sshfs $host:. "$mount" -o "$opts"
  else
    echo >&2 -e "${RED}Already mounted: ${LTBLUE}${mount}${NOCLR}"
  fi
}
cosmosfs() {
  # ensure myip installed
  _reqcmds myip || return

  local host="home" mount="$HOME/cosmos"
  local opts=(
    uid=$(id -u)
    gid=$(id -g)
    # idmap=file
    # nomap=ignore
    # uidfile="$HOME/.ssh/cosmos-uids"
    # gidfile="$HOME/.ssh/cosmos-gids"
  )
  [[ `myip` == 192.168.* ]] && host="cosmos"
  _sshfs $host "$mount" "${opts[*]}" && cd "$mount"
}

dismount() {
  local TM_VOLS=(/Volumes/Time?Machine /Volumes/*TMBackup*)
  local HD_VOLS=(Personal Erhhung Backups)
  local SMB_VOLS=(erhhungy Downloads)

  if [[ $(tmutil currentphase) != BackupNotRunning ]]; then
    echo 'Stopping   Time Machine'
    tmutil stopbackup
  fi

  for v in "${TM_VOLS[@]}"; do
    if [ -d "$v" ]; then
      echo "Unmounting $(basename "$v")"
      diskutil unmount "$v"
    fi
  done
  for v in "${HD_VOLS[@]}"; do
    if [ -d "/Volumes/$v" ]; then
      echo "Unmounting $v"
      diskutil unmount "$v"
    fi
  done
  for v in "${SMB_VOLS[@]}"; do
    if [ -d "/Volumes/$v" ]; then
      echo "Unmounting $v"
      umount "/Volumes/$v"
    fi
  done

  # unmount sshfs mounts
  local mounts=("$HOME/cosmos")
  for m in "${mounts[@]}"; do
    if [[ -d "$m" && "$(fstype "$m")" == osxfuse ]]; then
      echo "Unmounting $(basename "$m")"
      umount "$m"
    fi
  done
}

# jless: interactive JSON viewer
# https://jless.io/
alias j='jless --json'
alias y='jless --yaml'

# https://github.com/jmespath/jp
export JP_UNQUOTED=true

# show JSON from stdin in color
lj() {
  # ensure jq installed
  _reqcmds jq || return

  __lj() { jq -C . | l; }
  (($#)) && { cat "$@" | __lj; } || __lj
}

# show YAML from stdin in color
ly() {
  (($#)) && l "$@" || cat "$@" | l yaml
}

# show XML from stdin in color
_lx() {
  # ensure xmllint installed
  _reqcmds xmllint || return

  local style=${1:-1}; shift
  __lx() {
    xmllint --pretty $style - | l xml
  }
  (($#)) && { cat "$@" | __lx; } || __lx
}

alias lx=' _lx 1'
alias lx0='_lx 0'
alias lx1='_lx 1'
alias lx2='_lx 2'

urlencode() {
  local url
  (($#)) && url="$@" || url=$(cat)

  python3 -c "import sys,urllib.parse as ul;
print(ul.quote_plus(sys.stdin.read().strip()))" <<< "$url"
}
#   python3 -c "import sys,urllib.parse as ul;
# print(ul.unquote_plus(sys.stdin.read().strip()))"

# urldecode [-v var] URL
#  -v assign decoded URL to variable
#     var instead of output to stdout
urldecode() {
  local var url
  if [[ "$1" == '-v' && $# -ge 2 ]]; then
    var="$2"
    shift 2
  fi
  (($#)) && url="$@" || url=$(cat)

  url="${url//+/ }"
  url="${url//%/\\x}"
  [ "$var" ] && printf -v "$var" %b "$url" \
             || printf       "%b\n" "$url"
}

# decode URL + prettify
_urldecode() {
  local url path query param
  (($#)) && url="$@" || url=$(cat)

  if [[ "$url" == *\?* ]]; then
    read path query < <(tr \? ' ' <<< "$url")
    printf "$LTGREEN%s$NOCLR\n" "$path"
  fi
  while read param value; do
    printf "$LTBLUE%s$WHITE = $NOCLR%s\n" \
           "$(urldecode "$param")" \
           "$(urldecode "$value")"
  done < <(
    tr \& $'\n' <<< "${query:-$url}" | tr = ' '
  )
}

alias ue='urlencode '
alias ud='_urldecode'

# convert between yaml and json
alias yaml2json='python3 -c "import sys,yaml,json; json.dump(yaml.full_load(sys.stdin),sys.stdout,indent=2)"'
alias json2yaml='python3 -c "import sys,yaml,json; yaml.dump(     json.load(sys.stdin),sys.stdout,indent=2,sort_keys=False)"'

alias uuid="uuidgen | tr '[:upper:]' '[:lower:]'"

# append (or prepend) arguments
# to named environment variable
# _addargs [--pre] [--sep :] <var> <arg> [arg...]
# --pre: prepend instead of append
# --sep: separator (default space)
# e.g. _addargs --pre --sep : PATH /dir1
_addargs() {
  local args=() pre sep=' '
  while [[ "$1" == -* ]]; do
    case "$1" in
      --pre) pre=true  ;;
      --sep) sep="$2"; shift
        [ ${#sep} == 1 ] || {
          echo >&2 "Separator must be single char!"
          return 1
        } ;;
    esac
    shift
  done

  local var val v
  var="$1"; shift
  [ "$var" ] || {
    echo >&2 "Environment variable name required!"
    return 1
  }
  val="${!var}"
  for v in "$@"; do
    # add to env var only if arg hasn't already been added
    [[ "$sep$val$sep" == *"$sep$v$sep"* ]] || args+=("$v")
  done

  args="$(IFS="$sep"; echo "${args[*]}")"
  [ "$args" ] || return 0
  [ "$val" ]  || unset sep
  [ "$pre" ]  && val="$args$sep$val" \
              || val="$val$sep$args"
  eval "export $var=\"$val\""
}

alias addpaths="_addargs --sep ':'"
alias addflags="_addargs --sep ' '"

# compilation environment
addpaths    INCLUDE_PATH $HOMEBREW_PREFIX/include
addpaths    LIBRARY_PATH $HOMEBREW_PREFIX/lib
addpaths PKG_CONFIG_PATH $HOMEBREW_PREFIX/lib/pkgconfig
export    CPATH="$INCLUDE_PATH"
export  CPPPATH="$INCLUDE_PATH"

# Perl environment
#export PERL5HOME="$HOME/.perl5"
#export PERL5LIB="$PERL5HOME/lib/perl5"
#export PERL_MB_OPT="--install_base $PERL5HOME"
#export PERL_MM_OPT="INSTALL_BASE=$PERL5HOME"
#addpaths PATH "$PERL5HOME/bin"

# Ruby environment
# use Homebrew Ruby instead of macOS default
export RUBY_HOME="$HOMEBREW_PREFIX/opt/ruby"
export  GEM_HOME="$HOME/.gem"
addpaths --pre      PATH $RUBY_HOME/bin $GEM_HOME/bin
addpaths PKG_CONFIG_PATH $RUBY_HOME/lib/pkgconfig
addflags CPPFLAGS      -I$RUBY_HOME/include
addflags  LDFLAGS      -L$RUBY_HOME/lib

# Java environment
export   JAVA_VER=$(v=$(basename `realpath $HOMEBREW_PREFIX/opt/openjdk`); echo ${v%%.*})
export   JAVA_HOME="$HOMEBREW_PREFIX/opt/openjdk${JAVA_VER:+@$JAVA_VER}/libexec/openjdk.jdk/Contents/Home"
export GROOVY_HOME="$HOMEBREW_PREFIX/opt/groovy/libexec"
export   CLASSPATH="$JAVA_HOME/lib/*"
addpaths PATH       $JAVA_HOME/bin
addflags CPPFLAGS -I$JAVA_HOME/include

# Python environment
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
addpaths PATH $HOMEBREW_PREFIX/opt/tcl-tk/bin
# brew install pyenv
. <(pyenv init -)
# venv [dir]
venv() {
  local dir="${1:-.venv}"
  { [ -f ./"$dir"/bin/activate ] || python3 -m venv "$dir"; } \
    && . ./"$dir"/bin/activate
}
alias python='python3'
alias p3='python3'

# https://requests.readthedocs.io/en/latest/user/advanced/#ssl-cert-verification
export REQUESTS_CA_BUNDLE="$HOME/certs/fourteeners_ca_chain.pem"

# Node.js environment
export NODE_OPTIONS="--experimental-repl-await"
export NODE_PATH=$HOMEBREW_PREFIX/lib/node_modules
export NODE_ENV="development"
export JSII_SILENCE_WARNING_UNTESTED_NODE_VERSION=1
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
addpaths PATH $PNPM_HOME
# n runs nnn instead
alias nn='command n'
alias tsn='ts-node'

# Golang environment
export GOPATH="$HOME/.go"
addpaths PATH $GOPATH/bin

# Rust environment
export CARGO_HOME="$XDG_CACHE_HOME/cargo"
# . "$XDG_CONFIG_HOME/cargo/env"

# OpenMP: brew install llvm libomp
addflags CPPFLAGS -I$HOMEBREW_PREFIX/opt/libomp/include
addflags  LDFLAGS -L$HOMEBREW_PREFIX/opt/libomp/lib

# icu4c (Unicode lib): brew install icu4c
export ICU_HOME="$HOMEBREW_PREFIX/opt/icu4c"
addpaths --pre PATH $ICU_HOME/bin $ICU_HOME/sbin
addflags CPPFLAGS -I$ICU_HOME/include
addflags  LDFLAGS -L$ICU_HOME/lib

# MacTeX toolset
#addpaths PATH /Library/TeX/texbin

# additional paths
addpaths --pre PATH $HOMEBREW_PREFIX/opt/curl/bin
addpaths --pre PATH $HOME/.local/bin /usr/local/sbin
# https://krew.sigs.k8s.io/docs/user-guide/setup/install/
addpaths       PATH $HOME/.krew/bin

# suppress git-filter-branch warning
export FILTER_BRANCH_SQUELCH_WARNING=1

export STEPPATH="$XDG_CONFIG_HOME/step"

# keep ANSIBLE_CONFIG override on reload
export ANSIBLE_CONFIG="${ANSIBLE_CONFIG:-$XDG_CONFIG_HOME/ansible/ansible.cfg}"
# make ansible-playbook output YAML
export ANSIBLE_STDOUT_CALLBACK=yaml

# terraform CLI settings
export TF_CLI_ARGS_init="-compact-warnings -upgrade"
export TF_CLI_ARGS_plan="-compact-warnings"
export TF_CLI_ARGS_apply="-compact-warnings"

export OPENSSL_ROOT_DIR=`find $HOMEBREW_CELLAR/openssl* -type d -depth 1 | tail -1`
# enable GPG to prompt passphrase on console
export GPG_TTY=`tty`

# AGE_SECRET_KEY is defined in .bash_private
export AGE_KEY_FILE="$XDG_CONFIG_HOME/age/key.txt"

# export private environ vars like API keys
[ -f ~/.bash_private ] && . ~/.bash_private

# use the macOS version of ssh-add to add passphrase to Keychain
/usr/bin/ssh-add --apple-use-keychain ~/.ssh/erhhung &> /dev/null

# exit SSH control session
alias sshx='ssh -O exit'

# source ./.env if exists
# Usage: dotenv [-u]
dotenv() {
  [ -f ./.env ] || return
  if [ "$1" == -u ]; then
    unset $(sed -En 's/^ *([^#][^=]*) *=.*$/\1/p' ./.env)
  else # -a = "-o allexport"
    set -a; . ./.env; set +a
  fi
}

# show image EXIF metadata
meta() {
  # ensure exiftool installed
  _reqcmds exiftool || return

  exiftool "$@" \
    -ImageWidth -ImageHeight -Orientation# \
    -GPSLatitude# -GPSLongitude# -GPSAltitude# \
    -FocalLength# -Flash# -exif:all -json | jq
}

# shrink PNG file size
# shrinkpng <png_file>
shrinkpng() {
  # ensure pngquant installed
  _reqcmds pngquant || return

  if [[ "$1" != *.png ]]; then
    echo >&2 "File is not .png"
    return 1
  fi
  pngquant --speed 1 --skip-if-larger -fo "$1~" "$1"
  [ -f "$1~" ] && mv -f "$1~" "$1"
}

# convert .mov to .mp4
# shrinkmov <mov_file>
shrinkmov() {
  # ensure ffmpeg installed
  _reqcmds ffmpeg || return

  if [[ "$1" != *.mov ]]; then
    echo >&2 "File is not .mov"
    return 1
  fi
  ffmpeg -i "$1" -vcodec h264 -acodec mp3 -stats \
    -hide_banner -loglevel error -y "${1/%mov/mp4}"
}

# run latest curl installed by Homebrew,
# but since curl is keg-only (shadowing
# /usr/bin/curl is bad), use a function
curl() {
  local curl=$(find "$HOMEBREW_CELLAR/curl" -type f -name curl 2> /dev/null)
  [ -f "$curl" ] || curl=$(which curl)
  $curl "$@"
}

# run git command in all git
# directories: gitall <args>
gitall() {
  cmd='[[ -d "{}/.git" ]] && echo -e "$WHITE==>$BLUE" $(basename "{}")"$NOCLR" && cd "{}" && git '"$@"
  find -s . -mindepth 1 -maxdepth 1 -type d -exec bash -c "$cmd" ignored \;
}

# list dependencies in "package.json"
# usage: deps [-v] [key:dependencies]
#    -v  include package sem ver
#   e.g. deps -v devDependencies
deps() {
  # ensure jq installed
  _reqcmds jq || return

  # ensure "./package.json"
  [ -f "package.json" ] || {
    echo >&2 '"package.json" not found!'
    return 1
  }
  local semVer key query
  [ "$1" == -v ] && {
    semVer=1; shift
  }
  key=${1:-dependencies}
  [[ "$key" =~ ^((dev|peer|bundled|optional)D|d)ependencies$ ]] || {
    echo >&2 "Invalid dependencies key!"
    return 1
  }
  query='.[$key] // {} | (keys | sort)[]'
  [ "$semVer" ] && query+=' as $k | "\($k):\(.[$k])"'
  jq -r --arg key "$key" "$query" package.json
}
devdeps() {
  deps "$@" devDependencies
}

# remove exited docker containers
drmc() {
  docker rm $(docker ps -qa --no-trunc --filter "status=exited") 2> /dev/null
}
# remove old/unused docker images
drmi() {
  docker rmi $(docker images --filter "dangling=true" -q --no-trunc) 2> /dev/null
  docker rmi $(docker images | grep "none" | awk '/ / { print $3 }') 2> /dev/null
}

# list local docker images ordered descending
# by size (default) or by date: dlsi [-s|-d]
dlsi() {
  [[ "$1" = "-d" ]] && local opts=-rk2 || local opts=-rh
  # 1. get output of relevant fields from docker command
  # 2. align size column by left-padding values and units
  # 3. sort by size column with SI units or by date column
  # 4. add new column at beginning containing line numbers
  # 5. align line number column by left-padding values
  docker images --format '{{.Size}} {{.CreatedAt}} {{.ID}} {{.Repository}}:{{.Tag}}' \
    | awk '{k[NR]=$1; v[NR]=$2"  "$6"  "$7; n=length($1); if(n>N) N=n; next} END {for(i=1; i<=NR; i++) {printf " %" N "s  %s\n", k[i], v[i]}}' \
    | sort $opts \
    | sed = | paste -s -d ' \n' - \
    | awk '{s[NR]=$0; n=length($1); l[NR]=n; if(n>N) N=n; next} END {for(i=1; i<=NR; i++) {printf "%" N-l[i] "s%s\n", "", s[i]}}'
}

# show the Dockerfile commands used in an image
dcmds() {
  docker history $1 --format '{{.CreatedBy}}' --no-trunc | \
    tail -r | \
    sed -E 's/#\(nop\) +//; s/ +# buildkit.*$//; s|^(RUN )?/bin/(ba)?sh -c +||; s/^([^A-Z])/RUN \1/; s/ ( +)/ \\\n\1/g' | \
    pygmentize -l docker
}

# get container name like <adjective>_<surname>
# requires docker-names: npm i -g docker-names
dname() {
  node -e 'console.log(
    require("docker-names")
      .getRandomName(process.argv[1])
    )'
}

# explore image layers: https://github.com/wagoodman/dive
dive() {
  export DOCKER_HOST=$(docker context inspect -f '{{ .Endpoints.docker.Host }}')
  $(which dive) "$@"
}

alias d='docker'
alias di='d images'
alias dc='d compose'
alias p='podman'
alias pi='p images'
alias pc='p compose'
alias ld='lazydocker'
alias lg='lazygit'
alias tf='terraform'
alias ap='ansible-playbook'
alias mk='minikube'
alias k='kubecolor'
alias h='helm'
alias kg='kubectl-grep'
alias ar='kubectl-argo-rollouts'
alias a='argocd'

# https://github.com/kubecolor/kubecolor
export KUBECOLOR_FORCE_COLORS=true
export KUBECOLOR_OBJ_FRESH=1h
# https://github.com/ahmetb/kubectx
# brew install kubectx
alias kcx='kubectx'
alias kns='kubens'

# docker stats in JSON
dsj() {
  docker stats --no-stream \
    --format '{"id":"{{.ID}}",
               "name":"{{.Name}}",
               "cpu":"{{.CPUPerc}}",
               "mem":{"raw":"{{.MemUsage}}",
                      "per":"{{.MemPerc}}"},
               "net":"{{.NetIO}}",
               "blk":"{{.BlockIO}}"}' | \
    jq -sS 'def split_unit(field):
              . | split("(?<=[0-9.-])(?=[a-z%])";"i")
                | map(select(length > 0))
                | {"\(field)":.[0],"\(field)_unit":.[1]};
            def split_pair(fieldL;fieldR):
              . | split(" / ")
                | (.[0]|split_unit(fieldL))
                * (.[1]|split_unit(fieldR));
            [.[] | .     * (.cpu | split_unit("cpu"))
                 | .mem |= (.raw | split_pair("usage";"limit"))
                         * (.per | split_unit("percent"))
                 | .net |= split_pair("sent";"received")
                 | .blk |= split_pair("read";"written")]'
}

# get/set Docker context
# (completion is defined
# in ~/.bash_completion)
dcx() {
  # ensure minikube installed
  _reqcmds minikube || return

  if [[ -z ${1+x} ]]; then
    # invoked without args
    echo ${MINIKUBE_ACTIVE_DOCKERD:-host}
  elif [[ "$1" == "minikube" ]]; then
    eval $(minikube docker-env)
  elif [[ "$1" == "host" ]]; then
    eval $(minikube docker-env -u)
  else
    echo "Usage: dcx [minikube|host]"
  fi
}

# drun <image> ['command'] [opts...]
# command, if more than one word,
# must be quoted as a single arg
# (completion is defined
# in ~/.bash_completion)
drun() {
  local opts img="$1" cmd="$2"
  shift
  if [ ! "$img" ]; then
    echo >&2 "Usage: drun <image> ['command'] [opts...]"
    return 1
  fi
  if [[ "$cmd" == -* ]]; then
    cmd=''; opts=("$@")
  else
    shift; opts=("$@")
  fi

  local cont name=()
  cont="${img/*\//}"
  cont="${cont/:*/}"

  # use image name as container name unless taken
  local id=$(docker ps -aq --filter name="$cont")
  [ "$id" ] || name=(--name "$cont")

  eval "cmd=($cmd)" # separate command into executable & args
  if [ "$cmd" ]; then
    # use executable as entrypoint
    # and the rest as command args
    opts+=(--entrypoint "$cmd")
    cmd=("${cmd[@]:1}")
  fi
  docker run -it "${opts[@]}" "${name[@]}" "$img" "${cmd[@]}"
}

__container_shell_init_script() {
  # do NOT use any single quotes!
  cat <<"EOT"
# use /tmp if $HOME is read-only
[ -w $HOME ] || export HOME=/tmp
cd $HOME
touch .hushlogin
cat <<"EOF" > .profile
# get user name via "id" in case uid has no name
PS1="\[\033[1;36m\]\$(id -un 2> /dev/null)\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] "
alias cdd="cd \$OLDPWD"
alias ls="ls --color=auto"
alias ll="ls -alF"
alias lt="ll -tr"
alias l=less
# load Bash dot files if provided by container
[ -f $HOME/.bash_profile ] && . $HOME/.bash_profile
[ -f $HOME/.bash_aliases ] && . $HOME/.bash_aliases
EOF
EOT
  cat <<EOT
$@ # run any additional commands
(hash bash 2> /dev/null) && exec bash --rcfile ~/.profile || exec sh -l
EOT
}

# docker run -it --rm bash/sh
# dsh <image> [opts...]
dsh() {
  local host image="${1:-busybox}"
  host="${image##*/}"
  host="${host%:*}"

  # must pass $cmd to drun() as a single argument!
  local cmd="sh -c '`__container_shell_init_script`'"
  drun "$image" "$cmd" --rm --hostname $host "${@:2}"
}

# kubectl run -it --rm bash/sh
# ksh [image] [@host] [opts...]
# image: use Harbor if prefixed ./
#  host: use nodeSelector hostname
# default image is ./al2023-devops
ksh() {
  local args=() opts=() image pod

  image=${1:-.}   # use default DevOps image on Harbor
  [[ "$image" =~ ^\.$|^@.+ ]] && image=./al2023-devops
  [[ "$image" == ./*       ]] && \
    image="harbor.fourteeners.local/library/${image:2}"

  [[ "$2" == @* ]] && shift
  [[ "$1" == @* ]] && {
    opts+=( # run pod on host
      --overrides="$(cat <<EOT
{
  "apiVersion": "v1",
  "spec": {
    "nodeSelector": {
      "kubernetes.io/hostname": "${1:1}"
    }
  }
}
EOT
      )"
    )
    shift
  }

  # decorate pod name with random chars
  # to avoid collision with similar pod
  printf -v pod "%s-temp-admin-%04d" $USER $((RANDOM % 10000))
  args=(
    --namespace=default
    --labels="app=temp-admin"
    --pod-running-timeout=5m
    --rm -it "${@:2}"
    --restart=Never
    --image=$image
    "${opts[@]}"
    --command
    --quiet
  )
  kubectl run $pod "${args[@]}" -- \
    sh -c "$(__container_shell_init_script)"
}

# dexec <container> [opts] [-- command]
# (completion is defined
# in ~/.bash_completion)
dexec() {
  local cont=$1; shift

  local o opts=()
  while [ "$1" ]; do
    o=$1; shift
    # extra args for docker command
    [ "$o" != -- ] && opts+=($o) || break
  done

  # start container if not running
  local id=$(docker ps -q --filter name=$cont)
  [ -z "$id" ] && docker start "$cont" > /dev/null 2>&1

  if [[ -z ${1+x} ]]; then # run shell if no command
    set -- sh -c "$(__container_shell_init_script)"
  fi
  docker exec -it "${opts[@]}" "$cont" "$@"
}

# kexec <pod>[:container] [opts] [-- command]
# (completion is defined
# in ~/.bash_completion)
kexec() {
  # ensure kubectl installed
  _reqcmds kubectl || return

  local pod=$1; shift

  local o opts=()
  while [ "$1" ]; do
    o=$1; shift
    # extra args for docker command
    [ "$o" != -- ] && opts+=($o) || break
  done

  if [[ "$pod" =~ ^[^:]+:[^:]+$ ]]; then
    # pod:container => pod -c container
    opts=(-c "${pod/*:/}" "${opts[@]}")
    pod=${pod/:*/}
  else
    # if there's more than 1 container, choose first one to avoid warning
    o=($(kubectl get pod "$pod" -o jsonpath='{.spec.containers[*].name}'))
    opts=(-c $o "${opts[@]}")
  fi

  if [[ -z ${1+x} ]]; then # run shell if no command
    set -- sh -c "$(__container_shell_init_script)"
  fi
  kubectl exec -it "${opts[@]}" "$pod" -- "$@"
}

# list nodes in current K8s cluster
knodes() {
  # ensure kubectl installed
  _reqcmds kubectl || return
  {
    echo "${WHITE}NAME${NOCLR} ${WHITE}IP${NOCLR} ${WHITE}STATUS${NOCLR} ${WHITE}AGE${NOCLR} ${WHITE}VERSION${NOCLR}"
    kubectl get nodes -o json | jq -r '.items[] | {
      name:    .metadata.name,
      ip:     (.status.addresses[]  | select(.type=="InternalIP").address),
      status: (.status.conditions[] | select(.type=="Ready").type),
      age:     .metadata.creationTimestamp,
      version: .status.nodeInfo.kubeletVersion
    } | [
      .name,
      .ip,
      .status,
      (.age | fromdateiso8601 | now - . | floor | . / 86400 | floor | tostring + "d"),
      .version
    ] | @tsv'
  }   | cols
}

# list pods running on a K8s node
# usage: kpods <node_internal_ip>
#   tip: run `knodes` to list IPs
kpods() {
  # ensure kubectl/jq installed
  _reqcmds kubectl jq || return

  if [[ ! "$1" =~ ^([0-9]{1,3}\.){1,3}[0-9]{1,3}$ ]]; then
    echo "Usage: kpods <node_internal_ip>"
    echo '  Tip: run "knodes" to list IPs'
    return
  fi

  local name table w words
  # get node name from internal IP
  name=$(kubectl get nodes -o json \
    | jq --arg ip "$1" -r '.items[] |
         select(.status.addresses[] |
         select(.type=="InternalIP" and
         (.address | endswith($ip)))) |
          .metadata.name')

  # table will already be sorted by namespace and pod name
  table="$(kubectl get pods --all-namespaces --no-headers \
    --field-selector spec.nodeName="$name" 2> /dev/null)"

  [ -z "$table" ] && return
  w=($(_colwidths <<< "$table"))

  while read -a words; do
    # show namespace, name, status, and age fields only
    printf "%-${w[0]}s  %-${w[1]}s  %-${w[3]}s  %s\n" \
           "${words[0]}" "${words[1]}" \
           "${words[3]}" "${words[5]}"
  done <<< "$table"
}

# Helm "touch": apply manifest
# generated for a Helm release
# usage: htouch <helm-get-args>
# provide args to `helm get manifest`
# e.g. "-n app-namespace app-release"
htouch() {
  # ensure helm/kubectl installed
  _reqcmds helm kubectl || return

  local manifest namespace
  manifest="$(helm get manifest "$@")" || return
  namespace=$(helm get metadata "$@" | \
    grep NAMESPACE | awk '{print $2}')
  # suppress `kubectl apply` warnings about
  # missing last-applied-config annotations
  kubectl apply -f - <<< "$manifest" -n "$namespace" 2> /dev/null
}

# list tags of a repo on DockerHub
# dhubtags <repo>
dhubtags() {
  local repo=$1
  if [[ ! "$repo" =~ ^[^/]+\/[^/]+$ ]]; then
    repo="library/$repo" # use default user
  fi
  curl -s 'https://registry.hub.docker.com/v2/repositories/'"$repo"'/tags' \
    | jq -r '.results[].name'
}

# log in to Docker registry
# dlogin [registry]
# harbor|[docker]|ghcr|ecr
# (completion is defined
# in ~/.bash_completion)
dlogin() {
  local host user="erhhung" pass # from ~/.bash_private
  case "$1" in
    harbor)
      host="harbor.fourteeners.local"
      pass="$HARBOR_ADMIN_PASS"
      ;;
    docker|'')
      host="docker.io"
      pass="$DOCKER_ACCESS_TOKEN"
      ;;
    ghcr)
      host="ghcr.io"
      pass="$GITHUB_ACCESS_TOKEN"
      ;;
    ecr)
      # delegate to separate function
      ecrlogin "${@:2}"
      return
      ;;
    *)
      echo >&2 "Usage: dlogin [registry]"
      echo >&2 "       harbor|[docker]|ghcr|ecr"
      return 1
  esac
  echo -n "$pass" | docker login "https://$host" \
                    -u "$user" --password-stdin
}

# push local image to Docker registry
# dpush <image> [registry] [pushopts]
#  registry: harbor|[docker]|ghcr|ecr
#  pushopts: docker push options (-q)
# NOTE: must be logged in to registry
# (completion is defined
# in ~/.bash_completion)
dpush() (
  set -e

  help() {
    echo "Usage: dpush <image> [registry]"
    echo "       harbor|[docker]|ghcr|ecr"
    exit ${1:-0}
  }
  [ "$1" ] || help
  [ "$(docker image ls -q "$1")" ] || {
    echo >&2 "Image not found: $1"
    exit 1
  }
  case "$2" in
    harbor)
      tag="harbor.fourteeners.local/library/$(basename "$1")"
      ;;
    docker|'')
      tag="docker.io/erhhung/$(basename "$1")"
      ;;
    ghcr)
      tag="ghcr.io/erhhung/$(basename "$1")"
      ;;
    ecr)
      # delegate to separate script
      ecrpush "$1"
      exit $?
      ;;
    *)
      help 1
  esac
  docker tag  "$1" "$tag"
  trap "docker rmi  $tag" EXIT
  docker push "${@:3}" "$tag"
)

export AWS_PAGER="" # disable paging
export AWS_CONFIG_FILE="$HOME/.aws/config"
export AWS_SHARED_CREDENTIALS_FILE="$HOME/.aws/credentials"
export AWS_CA_BUNDLE="$HOMEBREW_PREFIX/etc/ca-certificates/cert.pem"

alias awscfg='aws configure list'

# usage: assumerole [--debug] <role_arn> [external_id] [duration_secs]
assumerole() {
  # ensure aws/node installed
  _reqcmds aws node || return

  if [[ -z ${1+x} ]]; then
    # invoked without args
    echo "Usage: assumerole [--debug] <role_arn> [external_id] [duration_secs]"
    echo "Exports AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN"
    return
  fi

  local debug args name json cmds
  if [[ "$1" == "--debug" ]]; then
    debug=1; shift # dump raw JSON
  fi
  args=(--role-arn "$1")
  [ "$2" ] && args+=(--external-id "$2")

  # generate a random role session name
  name=$(n=10000; printf "temp-%04d" $((RANDOM % n)))
  args+=(--role-session-name "$name")

  # set duration only if $3 is an integer
  [ ${3-0} -eq ${3-1} 2> /dev/null ] && \
    args+=(--duration-seconds "$3")

  json=$(aws sts assume-role "${args[@]}") || return
  [ "$debug" ] && echo "$json"

  # use Node.js to parse JSON output and
  # to reformat ISO 8601 expiration date
  cmds="$(node <(cat <<'EOF'

const {Credentials:c, AssumedRoleUser:u} =
  JSON.parse(require('fs').readFileSync(0,'utf-8'));
const exportEnvs = (kv) => console.log('export %s;',
  kv.map(([k,v]) => `${k}="${v}"`).join(' '));
exportEnvs([
  ['AWS_ACCESS_KEY_ID',     c.AccessKeyId],
  ['AWS_SECRET_ACCESS_KEY', c.SecretAccessKey],
  ['AWS_SESSION_TOKEN',     c.SessionToken]
]);
const exp = new Date(c.Expiration).toLocaleString();
console.log(`echo 'Role session %s will expire at %s.'`,
  u.AssumedRoleId, exp.replace(/,/,''));
EOF
  ) <<< "$json")"

  if [ -z "$debug" ]; then
    eval "$cmds" 2> /dev/null
  else
    echo "$cmds"
  fi
}

# set AWS credentials to
# a user in ~/.aws/users
# usage: awsuser <user> [account]
# run awsprf to unset credentials
awsuser() {
  # ensure aws installed
  _reqcmds aws || return

  local user=$1 acct=$2
  if [ "$acct" ]; then
    acct=$(aws --profile "$acct" sts get-caller-identity \
               --query 'Account' --output text 2> /dev/null)
    if [[ $? -ne 0 ]]; then
      echo >&2 "Invalid account!"
      return 1
    fi
  fi

  # this function expects ~/.aws/users to contain groups of these 3
  # consecutive lines (additional comments and empty lines ignored):
  #
  # # arn:aws:iam::437640264121:user/sample1
  # aws_access_key_id = foo
  # aws_secret_access_key = bar

  local regex="arn:aws:iam::(${acct:-[0-9]+}):user\/(.*${user}.*)"
  local users=($(sed -En "s/^# *${regex}$/\1:\2/p" ~/.aws/users | sort))

  if [[ -z ${1+x} ]]; then
    # invoked without args
    echo "Usage: awsuser <user> [account]"
    if [[ ${#users[@]} -gt 0 ]]; then
      echo # show all available users
      printf '%s\n' "${users[@]/:/ }" | sort -k2
    fi
    return
  fi

  # users is array containing
  # "<account_id>:<username>"
  if [[ ${#users[@]} -eq 0 ]]; then
    echo >&2 "User not found!"
    return 1
  fi
  if [[ ${#users[@]} -gt 1 ]]; then
    echo >&2 -e "Ambiguous selection!\n"
    printf '%s\n' "${users[@]/:/ }" >&2
    return 1
  fi
  user=${users[0]}

  # first select lines in section with matching "# arn:"
  regex="/^# *arn:aws:iam::${user/:/:user\\/}/,/^# *arn:/"
  # then grab key ID and secret key pair not commented out
  regex+="{/^#/! s/([a-z_]*access_key[a-z_]*) *= *(.+)$/\1=\2/p;}"
  local key val var vars=($(sed -En "$regex" ~/.aws/users))

  # vars is an array containing
  # "aws_access_key_id=xxx" and
  # "aws_secret_access_key=yyy"
  if [[ ${#vars[@]} -ne 2 ]]; then
    echo >&2 "Credentials not found!"
    return 1
  fi
  for var in "${vars[@]}"; do
     key="${var/=*/}"
     val="${var/*=/}"
     # export key in uppercase
     export "${key^^}"="$val"
  done
  echo "$user (${vars[0]/*=/})"
  echo "AWS credentials exported."

  # set AWS_PROFILE to match new user
  # credentials to inherit AWS_REGION
  acct=${2:-${acct:-${user/:*/}}}
  if grep -Eq "^\[profile +${acct}\]$" ~/.aws/config; then
    export AWS_PROFILE="$acct"
  else
    export AWS_PROFILE=user
  fi
}

# <grep-term>
awsacct() {
  local table w words
  table=$(grep -i "$1" "$HOME/.aws/accounts")
  # table has 3 1-word columns + description
  w=($(_colwidths <<< "$table"))
  (
  while read -a words; do
    printf "%s  %-${w[1]}s  %-${w[2]}s  %s\n" \
           "${words[@]:0:3}" "${words[*]:3}"
  done <<< "$table"
  # highlight term
  ) | grep -i "$1"
}

awsurl() {
  grep -i "$1" "$HOME/.aws/loginurls"
}

# get/set $AWS_PROFILE in this shell
# (completion is defined in ~/.bash_completion
# using profiles defined in ~/.aws/config)
awsprf() {
  if [[ -z ${1+x} ]]; then
    # invoked without args
    [ "$AWS_PROFILE" ] && echo $AWS_PROFILE
    return
  elif [ -z "$1" ]; then
    # passed empty string
    unset AWS_PROFILE
  elif grep -Eq '^\[profile +'"$1"'\]$' ~/.aws/config; then
    export AWS_PROFILE="$1"
  else
    # grep for unique match
    local matches=($(sed -En 's/^\[profile +(.+)\]$/\1/p' \
      "$HOME/.aws/config" | grep "$1"))

    case ${#matches[@]} in
      0) echo >&2 "Invalid profile!"
         return 1 ;;
      1) export AWS_PROFILE="$matches"
        ;;
      *) echo >&2 "Ambiguous selection!"
         printf '%s\n' "${matches[@]}" | grep "$1" >&2
         return 1 ;;
    esac
  fi
  unset AWS_ACCESS_KEY_ID \
        AWS_SECRET_ACCESS_KEY \
        AWS_SESSION_TOKEN \
        AWS_REGION
}

# set auth profile for s4cmd
# usage: s3profile [profile]
s3profile() {
  # function requires "crudini" utility
  # (install via "pip install -e git+https://github.com/pixelb/crudini.git\#egg=crudini")
  _reqcmds crudini || return

  local profile=${1:-${AWS_PROFILE:-default}}
  local CRUDINI="crudini --get $AWS_CREDENTIAL_FILE $profile"
  $CRUDINI > /dev/null 2>&1 || return # ensure section exists

  export S3_ACCESS_KEY=$($CRUDINI aws_access_key_id)
  export S3_SECRET_KEY=$($CRUDINI aws_secret_access_key)

  echo "S3_ACCESS_KEY = $S3_ACCESS_KEY"
  echo "S3_SECRET_KEY = $S3_SECRET_KEY"
}

# get "effective" AWS region or set
# AWS_REGION override in this shell
# (completion is defined in ~/.bash_completion
# using profiles defined in ~/.aws/config)
awsrgn() {
  # ensure aws installed
  _reqcmds aws || return

  if [[ -z ${1+x} ]]; then
    # invoked without args
    if [ "$AWS_REGION" ]; then
      echo $AWS_REGION
    else
      aws configure list | \
        sed -En 's/.* +region +([-a-z0-9]+) +.*/\1/p'
    fi
  elif [ -z "$1" ]; then
    # passed empty string
    unset AWS_REGION
  elif [[ "$1" =~ ^[a-z]{2}-[a-z]{4,}-[1-3] ]] && \
       grep -Eq '^'"$1"' ' "$HOME/.aws/regions"; then
    export AWS_REGION="$1"
  elif [[ "$1" =~ ^(af|ap|ca|eu|me|sa|us)(-|$) ]]; then
    grep -E '^'"$1" "$HOME/.aws/regions" || \
      echo >&2 "No region found."
  else
    echo >&2 "Invalid region!"
    return 1
  fi
}

# list Parameter Store values
# usage: params <path_only>/  (get all values)
#        params <path>/<name> (get one value)
params() {
  # ensure aws installed
  _reqcmds aws || return

  if [ -z "$1" ]; then
    echo "Usage: params <path_only>/  (get all values)"
    echo "       params <path>/<name> (get one value)"
    return
  fi

  if [[ ! "$1" =~ /$ ]]; then
    # output one value only
    aws ssm get-parameter \
      --name "$1" \
      --query 'Parameter.Value' \
      --with-decryption \
      --output text
    return $?
  fi

  local table w words
  # results automatically sorted by name
  table=$(aws ssm get-parameters-by-path \
    --path "$1" \
    --recursive \
    --query "Parameters[].[Name,Value]" \
    --with-decryption \
    --output text)

  [ -z "$table" ] && return
  w=($(_colwidths <<< "$table"))

  while read -a words; do
    printf "%-${w[0]}s  %s\n" \
           "${words[@]:0:1}" "${words[*]:1}"
  done < <(sort <<< "$table")
}

# list Secrets Manager values
# usage: secrets [-v] <prefix>
#     -v: show value only
# prefix: '.' to list all
secrets() {
  # ensure aws installed
  _reqcmds aws || return

  local opt=$1
  [ "$opt" == "-v" ] && shift

  if [ -z "$1" ]; then
    echo "Usage: secrets [-v] <prefix>"
    echo "    -v: show value only"
    echo "prefix: '.' to list all"
    return
  fi

  local regex names w values=() prefix=$1
  # escape regex literal if not "list all"
  [ "$prefix" != '.' ] && prefix=$(sed 's/[.^$*+?()[{\|]/\\&/g' <<< "$prefix")

  regex="^${prefix}"
  # perform exact match only if -v (show one value only)
  [[ "$prefix" != '.' && "$opt" == "-v" ]] && regex+='$'

  names=$(aws secretsmanager list-secrets \
      --query 'SecretList[].[Name]' \
      --output text | \
    grep -Ei "$regex" | \
    sort -f)

  [ -z "$names" ] && return
  w=($(_colwidths <<< "$names"))
  names=($names)

  local name value n i
  for name in "${names[@]}"; do
    # get all values first, then show all at once
    value="$(aws secretsmanager get-secret-value \
      --secret-id "$name" \
      --query SecretString \
      --output text)"
    values+=("$value")
  done

  n=$((${#names[@]}-1))
  if [[ $n -eq 0 && "$opt" == "-v" ]]; then
    # output value only
    echo "${values[@]}"
    return
  fi
  for i in $(seq 0 $n); do
    printf "%-${w[0]}s  %s\n" \
            "${names[$i]}" \
           "${values[$i]}"
  done
}

# list Route53 subdomains
# usage: domains <domain>
domains() {
  # ensure aws installed
  _reqcmds aws || return

  local zone table w words
  zone=$(aws route53 list-hosted-zones-by-name \
      --query 'HostedZones[].[Id,Name]' \
      --profile ${AWS_PROFILE:-drempre} \
      --output text)
  zone=($(grep "${1:-preprod}" <<< "$zone")) || return

  table=$(aws route53 list-resource-record-sets \
      --hosted-zone-id $zone \
      --query 'ResourceRecordSets[*].[Name,Type,
        join(`, `,ResourceRecords[*].Value ||
                      [AliasTarget.DNSName || ``])]' \
      --profile ${AWS_PROFILE:-drempre} \
      --output text)
  w=($(_colwidths <<< "$table"))

  while read -a words; do
    printf "%${w[0]}s  %-${w[1]}s  %s\n" \
           "${words[@]:0:2}" "${words[*]:2}"
  done <<< "$table"
}

# show ECR domain name
# usage: ecrdomain [profile]
ecrdomain() {
  local region profile account
  region=$(awsrgn) || return

  profile="${1:-${AWS_PROFILE:-default}}"
  account=$(aws sts get-caller-identity \
    --profile $profile \
    --query   Account \
    --output  text) || return

  echo "$account.dkr.ecr.$region.amazonaws.com"
}

# docker login to either
# account or public ECR
# ecrlogin [public]
ecrlogin() {
  # ensure docker available
  _reqcmds docker || return

  local registry args result
  if [ "$1" == public ]; then
     registry="public.ecr.aws"
     args=(ecr-public --profile personal --region us-east-1)
  else
     registry=$(ecrdomain) || return
     args=(ecr)
  fi
  result=$(aws "${args[@]}" get-login-password | \
    docker login --username AWS --password-stdin \
    "$registry") || return

  [[ "$result" =~ Succeeded ]] || return
  echo "Successfully logged into $registry"
}

# list repositories in ECR
# usage: ecrrepos [contains]
ecrrepos() {
  # ensure aws installed
  _reqcmds aws || return

  aws ecr describe-repositories \
    --query "repositories[?contains(repositoryName,\`$1\`)].[repositoryName]" \
    --output text | sort
}

# list tags on ECR repo
# usage: ecrtags <repo>
ecrtags() {
  # ensure aws/numfmt installed
  _reqcmds aws numfmt || return

  if [ ! "$1" ]; then
    echo >&2 "Repository name required!"
    return 1
  fi

  local table w words
  table=$(
    while read tag0 tag1 size date; do
      size=$(numfmt --to iec-i $size)
      date=$(date -jf "%Y-%m-%dT%T%z" "${date%:*}${date##*:}" +"%x %r")
                             echo $tag0 $size $date
      [ "$tag1" != None ] && echo $tag1 $size $date
    done < <(
      aws ecr describe-images \
        --repository-name "$1" \
        --query 'imageDetails[].[
                   imageTags[0],
                   imageTags[1],
                   imageSizeInBytes,
                   imagePushedAt]' \
        --output text | sort -k4r
    ))
  w=($(_colwidths <<< "$table"))

  while read -a words; do
    printf "%-${w[0]}s  %${w[1]}s  %s\n" \
           "${words[@]:0:2}" "${words[*]:2}"
  done <<< "$table"
}

# show latest images in ECR
# usage: ecrlatest [contains]
ecrlatest() {
  local hash repo repos=($(ecrrepos "$1"))

  for repo in "${repos[@]}"; do
    hash=$(aws ecr describe-images \
      --repository-name "$repo" \
      --query 'imageDetails[?imageTags &&
                    contains(imageTags,`latest`)].imageTags[] |
                                  [?@!=`latest`] | [0] || ``' \
      --output text)
    [ -z "$hash" ] && echo $repo \
                   || echo $repo:$hash
  done
}

# sum (size) values (with units) from stdin (values
# are separated by white space, including newlines)
# usage: sum [unit|1]
#        show total without unit if given 1;
#        otherwise show with auto iec-i unit
#  e.g.: sum Gi <<< "250Mi 50Gi 1.5Ti 1024"
#        sum  1 <<< "$10 $24.99 $125.44"
sum() {
  # ensure numfmt installed
  _reqcmds numfmt || return

  local tot cur val vals=(`cat`)
  local u1 u2 unit usys args

  for val in ${vals[@]}; do
    # separate value & unit
    [[ $val =~ ^([$]?)([-0-9.]+)([A-Za-z]*)$ ]]

    # below handles spaces surrounding size and unit, but each value must be on one line
    # [[ $val =~ ^[[:blank:]]*([-[:digit:].]+)[[:blank:]]*([[:alpha:]]*)[[:blank:]]*$ ]]
     cur=${BASH_REMATCH[1]} # currency symbol
     val=${BASH_REMATCH[2]} # numeric  value
    unit=${BASH_REMATCH[3]}

    [ "$cur"  ] && set -- 1 # show total without unit
    [ "$val"  ] || continue
    [ "$unit" ] || {
      tot=$(bc <<< "0$tot + 0$val")
      continue
    }
    case ${unit,,} in
       k|m|g|t|p|e|1|'') usys=si    ;;
      ki|mi|gi|ti|pi|ei) usys=iec-i ;;
      *) echo >&2 "Invalid unit: $unit"
         return 1
    esac

    u1=${unit:0:1} u2=${unit:1:1} unit=${u1^^}${u2,,}
    args=(--from  $usys --to-unit 1  ${val}${unit})
    tot=$(bc <<< "0$tot + 0$(numfmt "${args[@]}")")
  done

  if [ "$1" ]; then
    # show value only in specified unit
    u1=${1:0:1} u2=${1:1:1} unit=${u1^^}${u2,,}
    args=(--to-unit $unit)
  else
    # show size and unit based on value
    args=(--to iec-i)
  fi
  numfmt "${args[@]}" --round nearest $tot
}

# see also "blist" command in /usr/local/bin:
# list all S3 buckets including their regions
# COLUMNS: <cdate> <ctime> <region> <bucket>

# show S3 bucket size/count
# usage: bsize <bucket>
bsize() (
  bucket=$1
  [ "$bucket" ] || {
    echo 'Show S3 bucket size/count'
    echo 'Usage: bsize <bucket>'
    exit
  }
  # ensure aws/jq/numfmt installed
  _reqcmds aws jq numfmt || exit 1

  # get bucket region
  region=$(aws s3api get-bucket-location \
             --bucket $bucket 2> /dev/null | \
    jq -r '.LocationConstraint // "us-east-1"')
  [ "$region" ] || {
    echo >&2 "Cannot determine bucket location!"
    exit 1
  }

  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/metrics-dimensions.html
  stypes=(
    StandardStorage
    IntelligentTieringFAStorage
    IntelligentTieringIAStorage
    IntelligentTieringAAStorage
    IntelligentTieringAIAStorage
    IntelligentTieringDAAStorage
    StandardIAStorage
    StandardIASizeOverhead
    StandardIAObjectOverhead
    OneZoneIAStorage
    OneZoneIASizeOverhead
    ReducedRedundancyStorage
    GlacierInstantRetrievalStorage
    GlacierStorage
    GlacierStagingStorage
    GlacierObjectOverhead
    GlacierS3ObjectOverhead
    DeepArchiveStorage
    DeepArchiveObjectOverhead
    DeepArchiveS3ObjectOverhead
    DeepArchiveStagingStorage)

  # _bsize <metric> <stype>
  _bsize() {
    local metric=$1 stype=$2
    local period=$((60*60*24*2))
    local utnow=$(date +%s)

    aws cloudwatch get-metric-statistics  \
      --start-time  $(($utnow - $period)) \
      --end-time    $utnow  \
      --period      $period \
      --region      $region \
      --namespace   AWS/S3  \
      --metric-name $metric \
      --dimensions  Name=BucketName,Value=$bucket \
                    Name=StorageType,Value=$stype \
      --statistics  Average 2> /dev/null | \
      jq -r '.Datapoints[].Average // 0'
  }

  total=$(
    (for stype in ${stypes[@]}; do
       _bsize BucketSizeBytes $stype
     done; echo 0) | \
      paste -sd+ - | bc
  )
  count=$(_bsize NumberOfObjects AllStorageTypes)
  count=$(printf "%.0f\n" $count) # round to int

  # _print <label> <number> <units> <format> [suffix]
  _print() {
    local  label number units format suffix
    read   label number units format suffix <<< "$@"
    echo "$label"

    numfmt $number \
      --to="$units" \
      --suffix="$suffix" \
      --format="$format" | \
      sed -En 's/([^0-9]+)$/ \1/p'
  }

  cols=($(
    _print Size "0${total}" iec-i "%.2f" B
    [ "0${count}" -lt 1000 ] && echo Count $count || \
      _print Count "0${count}" si "%.2f"
  ))
  printf "%5s: %6s %s\n" "${cols[@]}"
)

# empty entire S3 bucket
# usage: emptyb <bucket>
emptyb() (
  bucket=$1
  [ "$bucket" ] || {
    echo 'Empty entire S3 bucket'
    echo 'Usage: emptyb <bucket>'
    exit
  }
  # ensure aws/jq installed
  _reqcmds aws jq || exit 1

  PAGER="" PAGE_SIZE=500

  # _delobjs <type> <label>
  _delobjs() {
    local type=$1 label=$2  token
    local opts=() page objs count

    while [ "$token" != null ]; do
      page="$(aws s3api list-object-versions \
                --bucket $bucket "${opts[@]}" \
                --query="[{Objects: ${type}[].{Key:Key,VersionId:VersionId}}, NextToken]" \
                --page-size $PAGE_SIZE \
                --max-items $PAGE_SIZE \
                --output json)" || exit $?

       objs="$(jq '.[0] | .+={Quiet:true}' <<< "$page")"
      count="$(jq '.Objects | length' <<< "$objs")"
      token="$(jq -r '.[1]' <<< "$page")"
       opts=(--starting-token "$token")

      if [ $count -gt 0 ]; then
        aws s3api delete-objects \
          --bucket $bucket \
          --delete "$objs"
        jq -r '.Objects[].Key | "['$label'] "+.' <<< "$objs"
      fi
    done
  }
  _delobjs Versions      VER
  _delobjs DeleteMarkers DEL
)

# https://iredis.xbin.io/
alias redis='iredis --iredisrc $XDG_CONFIG_HOME/iredis/iredisrc'
export IREDIS_DSN="homelab"

export OLLAMA_HOST="https://ollama.fourteeners.local"

# brew install qalculate-qt
qc() {
  (qalculate-qt "$@" &) 2> /dev/null
}

_qalc_exrates() {
  # \e[s =    save cursor position
  # \e[u = restore cursor position
  # \e[K =  delete to  end-of-line
  printf "\e[sUpdating exchange rates..."
  qalc -e 1 > /dev/null
  printf "\e[u\e[K"
  qalc -c 1 $*
}

# <default_to> <from> [amount:1] <to>
_qalc_currency() {
  # ensure qalc installed
  _reqcmds qalc || return

  local def=$1 from=$2 amt=$3 to=$4 exp
  if [[ "${amt,,}" =~ ^[a-z]+$ ]]; then
    to=$amt amt=
  fi
  exp="$from to ${to:-$def}"
  [ "$amt" ] &&  qalc -c -t $amt $exp \
             || _qalc_exrates    $exp
}

# convert US$ to TW$ or another currency
# usd <amount> [currency_if_not_twd]
usd() { _qalc_currency TWD ${FUNCNAME^^} "$@"; }

# convert CA$ to US$ or another currency
# twd <amount> [currency_if_not_usd]
cad() { _qalc_currency USD ${FUNCNAME^^} "$@"; }

# convert MX$ to US$ or another currency
# twd <amount> [currency_if_not_usd]
mxn() { _qalc_currency USD ${FUNCNAME^^} "$@"; }

# convert TW$ to US$ or another currency
# twd <amount> [currency_if_not_usd]
twd() { _qalc_currency USD ${FUNCNAME^^} "$@"; }

#==================#
# Bash Completions #
#==================#

# brew install bash-completion@2
[ -f $HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh ] && \
   . $HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh

# https://github.com/youal/jid
for cmd in lj jid; do
  # complete only .*json files and dir names
  complete -o dirnames -f -X '!*.*json' $cmd
done
for cmd in ly; do
  # complete only .ya?ml files and dir names
  complete -o dirnames -f -X '!*.@(yaml|yml)' $cmd
done
for cmd in lx lx0 lx1 lx2; do
  # complete only .xml files and dir names
  complete -o dirnames -f -X '!*.xml' $cmd
done

# mc: MinIO client
[ -f /usr/local/bin/mc ] && \
  complete -C /usr/local/bin/mc mc

# odo: quick K8s deploy
[ -f /usr/local/bin/odo ] && \
  complete -C /usr/local/bin/odo odo

[ -f /usr/local/bin/aws_completer ] && \
  complete -C /usr/local/bin/aws_completer aws

[ -f /usr/local/bin/terraform ] && \
  complete -C /usr/local/bin/terraform terraform tf

[ -f /usr/local/bin/vagrant ] && \
[ -f /opt/vagrant/embedded/gems/gems/vagrant-*/contrib/bash/completion.sh ] && \
   . /opt/vagrant/embedded/gems/gems/vagrant-*/contrib/bash/completion.sh

. <(register-python-argcomplete ansible)
. <(register-python-argcomplete ansible-config)
. <(register-python-argcomplete ansible-console)
. <(register-python-argcomplete ansible-doc)
. <(register-python-argcomplete ansible-galaxy)
. <(register-python-argcomplete ansible-inventory)
. <(register-python-argcomplete ansible-playbook)
. <(register-python-argcomplete ansible-pull)
. <(register-python-argcomplete ansible-vault)

# https://docs.docker.com/docker-for-mac/#bash
(
  comp_d=$HOMEBREW_PREFIX/etc/bash_completion.d
  dk_etc=/Applications/Docker.app/Contents/Resources/etc

  [ ! -L $comp_d/docker ] && \
    ln -sf $dk_etc/docker.bash-completion \
           $comp_d/docker
  [ ! -L $comp_d/docker-compose ] && \
    ln -sf $dk_etc/docker-compose.bash-completion \
           $comp_d/docker-compose
)

# https://github.com/hidetatz/kubecolor#bash
complete -o default -F __start_kubectl kubecolor
complete -o default -F __start_kubectl k

# commented out commands means that completion scripts are
# already installed in [/usr/local]/etc/bash_completion.d/

#. <(yq  shell-completion bash)
#. <(minikube  completion bash)
#. <(kubectl   completion bash)
#. <(eksctl    completion bash)
 . <(doctl     completion bash)
#. <(helm      completion bash)
 . <(kubectl-grep          completion bash)
 . <(kubectl-argo-rollouts completion bash)
 . <(argocd    completion bash)
#. <(argo      completion bash)
 . <(node    --completion-bash)
 . <(harbor    completion bash)
#. <(confluent completion bash)
 . <(nsc       completion bash)
 . <(nats    --completion-script-bash)
 . <(just    --completions     bash)
 . <(pip3      completion    --bash)
 . <(chatgpt --set-completions bash)

# see ~/.bash_completion
# for alias completions

# Amazon Q post block. Keep at the bottom of this file.
[ -f "$HOME/Library/Application Support/amazon-q/shell/bash_profile.post.bash" ] && \
   . "$HOME/Library/Application Support/amazon-q/shell/bash_profile.post.bash" &> /dev/null

#================================#
# End of .bash_profile for macOS #
#================================#
