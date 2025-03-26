#!/usr/bin/env bash

# run the script after manually deleting outdated extension directories
# to sync the extensions.json file with remaining extension directories

cd "$(dirname "$0")"

mapfile -t paths < <(jq -r '.[].location.path' extensions.json | sort -V)

for path in "${paths[@]}"; do
  [ -d "$path" ] && continue

  echo "Deleting: $(basename "$path")"
  # delete extension from extensions.json
  jq --arg path "$path" 'map(select(.location.path != $path)) |
                            sort_by(.location.path)' extensions.json | \
     sponge extensions.json
done
