#!/bin/sh
exec yq -i '.repositories|=sort_by(.name)' repositories.yaml
