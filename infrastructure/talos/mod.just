set default-list
set default-script
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

nodes := `find ./nodes -maxdepth 1 -name '*.yaml.j2' -exec basename {} .yaml.j2 \; | tr '\n' ' '`

[confirm('Reboot node ' + node + ' [y|N] ?')]
[doc('Reboot a node')]
[group('lifecycle')]
reboot-node node:
    talosctl -n {{ node }} reboot -m powercycle

[confirm('Shutdown node ' + node + ' [y|N] ?')]
[doc('Shutdown a node')]
[group('lifecycle')]
shutdown-node node *args:
    talosctl -n "{{ node }}" shutdown --force {{ args }}

[confirm('Upgrade node ' + node + ' [y|N] ?')]
[doc('Upgrade Talos version on a node')]
[group('lifecycle')]
upgrade-node node *args:
    echo talosctl upgrade \
        -n "{{ node }}" \
        -i "$(just talos machine-image {{ node }})" \
        -m powercycle \
        --timeout=10m \
        {{ args }}

[confirm('Upgrade Kubernetes to ' + version + ' [y|N] ?')]
[doc('Upgrade Kubernetes version on the cluster')]
[group('lifecycle')]
upgrade-k8s version:
    talosctl -n "$(talosctl config info -o yaml | yq -e -r '.endpoints[0]')" upgrade-k8s --to {{ version }}

[confirm('Apply Talos config to ' + node + ' [y|N] ?')]
[doc('Apply Talos config to a node')]
[group('config')]
apply-node node *args:
    just log info "Applying Talos machineconfig" "node" "{{ node }}";
    just talos render-config "{{ node }}" | talosctl -n "{{ node }}" apply-config -f /dev/stdin {{ args }}

[confirm('Apply Talos config to all nodes in the cluster [y|N] ?')]
[doc('Apply Talos config to all nodes defined in nodes/*.yaml.j2')]
[group('config')]
apply-cluster *args:
    for n in {{ nodes }}; do
        just --yes talos apply-node "$n" {{ args }}
    done

[doc('View the diff before applying Talos config to a node')]
[group('config')]
diff-node node *args:
    just talos render-config "{{ node }}" | talosctl -n "{{ node }}" apply-config -f /dev/stdin --dry-run {{ args }}

[confirm('Reset node ' + node + ' [y|N] ?')]
[doc('Reset a Talos node')]
[group('recovery')]
reset-node node mode="reboot" *args:
    talosctl reset \
        --graceful=false \
        -n "{{ node }}" \
        {{ if mode == "reboot" { "--reboot" } else { "" } }} \
        --system-labels-to-wipe STATE \
        --system-labels-to-wipe EPHEMERAL \
        {{ args }}

[doc('Reset all nodes defined in nodes/*.yaml.j2')]
[group('recovery')]
reset-cluster *args:
    for n in {{ nodes }}; do
        just --yes talos reset-node "$n" {{ args }}
    done

[private]
machine-controller node:
    just template "{{ source_directory() }}/nodes/{{ node }}.yaml.j2" | yq -e -r 'select(.machine) | (.machine.type == "controlplane") // ""'

[private]
machine-image node:
    export SCHEMATIC="$(just talos schematic-id {{ node }})"
    just template "{{ source_directory() }}/machineconfig.yaml.j2" | yq -e -r 'select(.machine) | .machine.install.image'

[private]
render-config node:
    export CONTROLPLANE="$(just talos machine-controller {{ node }})"
    export SCHEMATIC="$(just talos schematic-id {{ node }})"
    talosctl machineconfig patch <(just template "{{ source_directory() }}/machineconfig.yaml.j2") \
        -p @<(just template "{{ source_directory() }}/nodes/{{ node }}.yaml.j2")

[private]
schematic-id node:
    curl -sX POST --data-binary @<(yq -e -r '. *+ load("{{ source_directory() }}/schematics/{{ node }}.yaml.j2")' "{{ source_directory() }}/schematics/schematic.yaml.j2" | just template -) "https://factory.talos.dev/schematics" | jq -r '.id'
