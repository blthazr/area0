set default-script
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

[private]
default:
    just -l talos

[confirm('Apply Talos config to ' + node + ' [y|N] ?')]
[doc('Apply Talos config to a node')]
apply-node node *args:
    just log info "Applying Talos machineconfig" "node" "{{ node }}";
    just talos render-config "{{ node }}" | talosctl -n "{{ node }}" apply-config -f /dev/stdin {{ args }}

[doc('Render Talos config for a node')]
render-config node:
    export CONTROLPLANE="$(just talos machine-controller {{ node }})"
    export SCHEMATIC="$(just talos schematic-id {{ node }})"
    talosctl machineconfig patch <(just template "{{ source_directory() }}/machineconfig.yaml.j2") \
        -p @<(just template "{{ source_directory() }}/nodes/{{ node }}.yaml.j2")

[private]
machine-controller node:
    just template "{{ source_directory() }}/nodes/{{ node }}.yaml.j2" | yq -e -r 'select(.machine) | (.machine.type == "controlplane") // ""'

[private]
schematic-id node:
    curl -sX POST --data-binary @<(just template "{{ source_directory() }}/schematics/{{ node }}.yaml.j2") "https://factory.talos.dev/schematics" | jq -r '.id'
