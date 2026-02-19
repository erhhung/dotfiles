#!/usr/bin/env bash

BASE_URL="https://raw.githubusercontent.com/kamiyaa/joshuto/refs/heads/main/config"

CONFIGS=(
  joshuto
  keymap
  mimetype
  theme
  icons
  bookmarks
  preview_file.sh
)

for config in ${CONFIGS[@]}; do
  [[ "$config" == *.* ]] && \
    file="$config"       || \
    file="$config.toml"

  [ -f "$file" ] && {
    echo >&2 "SKIPPING: $file"
    continue
  }
  echo >&2 "DOWNLOADING: $file"
  wget -q "$BASE_URL/$file"
done
