#!/usr/bin/env -S just --justfile

set default-script
set lazy
set quiet
set shell := ['bash', '-euo', 'pipefail', '-c']

# Bootstrap Recipes
[group: 'bootstrap']
mod bootstrap "bootstrap"

# Kube Recipes
[group: 'kubernetes']
mod kube "kubernetes"

# Talos Recipes
[group: 'talos']
mod talos "infrastructure/talos"

[private]
default:
    just -l

[private]
log lvl msg *args:
    gum log -t rfc3339 -s -l "{{ lvl }}" "{{ msg }}" {{ args }}

[private]
template file *args:
    minijinja-cli "{{ file }}" {{ args }} | vals eval -f -
