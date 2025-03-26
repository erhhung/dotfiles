#!/usr/bin/env bash
#
# Copy files & directories listed in the inventory file "files.txt"
# (absolute paths will be copied under the root/ subdirectory). The
# current host name (`hostname` plus alternates in "hosts.txt") and
# user name (`whoami`) will be compared against the current branch
# name (`git branch --show-current`) to prevent unintended copying
#
# USAGE: ./copy.sh [-d|--dry-run]
#
# Author: Erhhung Yuan
#  github.com/erhhung

# shellcheck disable=SC2034 # Verify/export unused variable
# shellcheck disable=SC2155 # Declare and assign separately
# shellcheck disable=SC2207 # Prefer mapfile to split output
# shellcheck disable=SC2164 # Use cd || exit in case cd fails
# shellcheck disable=SC2086 # Double quote to prevent globbing
# shellcheck disable=SC2291 # Quote to avoid collapsing spaces

cd "$(dirname "$0")"
GIT_DIR=$(builtin pwd)

# explicitly define shell options  concerning file matching
# behavior of paths in "files.txt" containing glob patterns
# https://www.gnu.org/software/bash/manual/bash.html#The-Shopt-Builtin
shopt -s extglob globstar globskipdots nullglob
shopt -u dotglob failglob nocaseglob

  NOCLR='\033[0m'
    RED='\033[0;31m'
  GREEN='\033[0;32m' # symlinks        shown in this color
  OCHRE='\033[0;33m' # encrypted files shown in this color
  WHITE='\033[1;37m' # regular   files shown in this color
LTGREEN='\033[1;32m'
 LTBLUE='\033[1;34m'
 LTCYAN='\033[1;36m'

THUMBUP='\U1F44D'
THUMBDN='\U1F44E'
WARNING='\U26A0\UFE0F '

exit_help() {
  echo -e "\n${WHITE}USAGE:${LTGREEN} $0 ${LTCYAN}[-d|--dry-run]${NOCLR}"
  exit ${1:-0}
}

# parse script options
while [ $# -gt 0 ]; do
  case "$1" in
    -d|--dry-run) DRY_RUN=1 ;;
    -h|--help)  exit_help 0 ;;
            *)  exit_help 1 ;;
  esac
  shift
done

# suppress color if not outputing to terminal
[ -t 1 ] || unset NOCLR WHITE RED GREEN OCHRE \
  LTGREEN LTBLUE LTCYAN THUMBUP THUMBDN WARNING

verify_branch() {
  local branch host hosts user=$(whoami)
  branch=$(git branch --show-current)

  # check if default name: <hostname>-<username>
  [[ "${branch,,}" == *"-${user,,}" ]] || return

  host=$(hostname)
  hosts=("${host%%.*}")
  [ -f hosts.txt ] && \
    hosts+=($(< hosts.txt))

  for host in "${hosts[@]}"; do
    [ "${branch,,}" == "${host,,}-${user,,}" ] && return
  done
  return 1
}

# perform sanity check to make sure we are on the
# correct branch before overwriting project files
[ "$DRY_RUN" ] || verify_branch || {
  echo >&2 -e "\n${THUMBDN}${RED}Copying is not allowed on the current branch!${NOCLR}"
  echo >&2 -e         "${WHITE}Did you forget to switch to the correct branch?${NOCLR}"
  exit 1
}

[ -f files.txt ] || {
  echo >&2 -e "\n${THUMBDN}${RED}Inventory file not found!${NOCLR}"
  exit 1
}
# read inventory into array
mapfile -t paths < files.txt

  matches=()
unmatched=()
  regular=()
encrypted=()

for path in "${paths[@]}"; do
  path="${path##+([[:space:]])}" # trim leading  whitespace
  path="${path%%+([[:space:]])}" # trim trailing whitespace

  # skip comments and empty lines
  [[ "$path" =~ ^# ]] && continue
  [[ "$path" =~ ^$ ]] && continue

  [[ "$path" =~ ^\~/ ]] && path="${path:2}" # ~/ redundant
  [[ "$path" =~  /$  ]] && path+='**' # copy recursively

  if [[ "$path" =~ ^\| ]]; then # encrypt files
    path="${path:1}"
    # allow whitespace before path
    path="${path##+([[:space:]])}"
    encrypt=1
  else
    unset encrypt
  fi
  if [[ "$path" =~ ^/ ]]; then # absolute path
    cd /
  else
    cd "$HOME"
  fi

  # escape special characters: space, $ and &
  path=$(sed -E 's/([$ &])/\\\1/g' <<< "$path")
  echo -e "\n${LTBLUE}FINDING: ${LTCYAN}$path${NOCLR}"
  eval "matches=($path)"
  count=0

  for match in "${matches[@]}"; do
    # copy files and symlinks only
    is_file=$(test -f "$match" && echo 1)
    is_link=$(test -h "$match" && echo 1)
    if [[ "$is_file" || "$is_link" ]]; then

      if [ "$encrypt" ]; then
        encrypted+=("$match")
        color="OCHRE"
      else
        regular+=("$match")
        color="WHITE"
      fi
      # symlinks likely not encrypted
      [ "$is_link" ] && color="GREEN"

      # show relative paths with ~/ for clarity
      # shellcheck disable=SC2088 # Tilde does not expand in quotes
      [[ "$match" =~ ^/ ]] || match="~/$match"
      echo -e "${!color}$match${NOCLR}"
      (( count++ ))
    fi
  done
  [ $count -eq 0 ] && {
    unmatched+=("$path")
    echo -e "${WARNING}${RED}NO FILES FOUND!${NOCLR}"
  }
done

require_age() {
  command -v age &> /dev/null || {
    echo -e "\n${THUMBDN}${RED}Cannot encrypt requested files!${NOCLR}"
    echo -e "${WHITE}Please install the \"age\" utility"
    echo -e "and export ${LTCYAN}AGE_KEY_FILE${WHITE} variable.${NOCLR}"
    return 1
  }
  if [[ ! -f "$AGE_KEY_FILE"   || \
        "$(< "$AGE_KEY_FILE")" != AGE-SECRET-KEY-* ]]; then
    echo -e "\n${THUMBDN}${RED}Cannot encrypt requested files!${NOCLR}"
    echo -e "${WHITE}Please export ${LTCYAN}AGE_KEY_FILE${WHITE} variable"
    echo -e "to path of ${LTGREEN}age-keygen${WHITE} generated key.${NOCLR}"
    return 1
  fi
}

# make sure the "age" utility is available and
# the identity (private key) file is available
[ "$DRY_RUN" ] || ! (( ${#encrypted[@]} )) || \
  require_age 1>&2 || exit

#(IFS='|'; echo -e   "\n${LTBLUE}REGULAR: ${WHITE}${regular[*]}${NOCLR}")
#(IFS='|'; echo -e "\n${LTBLUE}ENCRYPTED: ${WHITE}${encrypted[*]}${NOCLR}")

# destination paths will be relative
# to the Git project root directory
cd "$GIT_DIR"

# usage: prepare_dest <src-path>
# outputs: <abs-src>|<dest-path>
prepare_dest() {
  local dir dest src="$1"
  dir=$(dirname "$src")

  if [[ "$src" =~ ^/ ]]; then
    # copy absolute path
    # under root/ subdir
    dest="root"
    [ "$dir" != / ] && \
      dest+="$dir"
    [ "$DRY_RUN"  ] || \
      mkdir -p "$dest"
    dest="root$src"
  else
    [ "$DRY_RUN"  ] || {
    [ "$dir" != . ] && \
      mkdir -p "$dir"
    }
    dest="$src"
    src="$HOME/$src"
  fi
  echo "$src|$dest"
}

# show appropriate actions taken based on DRY_RUN option
[ "$DRY_RUN" ] && writing="DRY-RUN" || writing="WRITING"
[ "$DRY_RUN" ] && copied="Would copy" || copied="Copied"

(( ${#regular[@]} )) && echo
for path in "${regular[@]}"; do
  IFS='|' read -r src dest < <(prepare_dest "$path")
  echo -e "${LTBLUE}$writing: ${WHITE}$dest${NOCLR}"
  [ "$DRY_RUN" ] || cp -Pp "$src" "$dest" || exit
done

(( ${#encrypted[@]} )) && echo
for path in "${encrypted[@]}"; do
  IFS='|' read -r src dest < <(prepare_dest "$path")
  # encrypt to PEM-encoded format with .age extension
  dest+=".age"
  echo -e "${LTBLUE}$writing: ${WHITE}$dest${NOCLR}"
  args=(--identity "$AGE_KEY_FILE" --armor -o "$dest")
  [ "$DRY_RUN" ] || age -e "${args[@]}" < "$src" || exit
done

# ALL DONE! show total file counts
printf "\n${THUMBUP}${LTGREEN}$copied %d regular file(s) and %d encrypted file(s).${NOCLR}\n" \
  ${#regular[@]} ${#encrypted[@]}
