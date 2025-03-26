# https://cheatography.com/linux-china/cheat-sheets/justfile/
# https://just.systems/man/en/chapter_23.html

set shell := ["bash", "-uc"]

WHITE := `printf $WHITE`
NOCLR := `printf $NOCLR`

_default:
  @just --justfile {{justfile()}} --list --unsorted --list-heading $'{{WHITE}}Recipes:{{NOCLR}}\n'
