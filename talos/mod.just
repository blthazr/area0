set default-list
set default-script
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

secrets_file := './secrets.yaml'

[arg("force", long, value="true")]
[doc('Generate new Talos secrets')]
[group('setup')]
generate-talos-secrets vault="area0" item="talos" force="false":
    op_item=$(op item get '{{ item }}' --vault '{{ vault }}' 2>/dev/null) || true

    if [[ -n "$op_item" ]] && [[ "{{ force }}" != "true" ]]; then
        just log error "1Password item already exists" vault "{{ vault }}" item "{{ item }}"
        echo "Use --force to overwrite" >&2
        exit 1
    elif [[ -n "$op_item" ]] && [[ "{{ force }}" == "true" ]]; then
        just log info "Overwriting 1Password item" vault "{{ vault }}" item "{{ item }}"
    else
        just log info "Creating 1Password item" vault "{{ vault }}" item "{{ item }}"
        op item create --category="API Credential" --title="{{ item }}" --vault="{{ vault }}"
    fi

    just log info "Generating new Talos secrets"
    talosctl gen secrets --force -o '{{ secrets_file }}'
    op item edit --vault {{ vault }} {{ item }} "machineconfig.MACHINE_TOKEN[text]=$(cat {{ secrets_file }} | yq .trustdinfo.token)" > /dev/null
    op item edit --vault {{ vault }} {{ item }} "machineconfig.MACHINE_CA_CRT[text]=$(cat {{ secrets_file }} | yq .certs.os.crt)" > /dev/null
    op item edit --vault {{ vault }} {{ item }} "machineconfig.MACHINE_CA_KEY[text]=$(cat {{ secrets_file }} | yq .certs.os.key)" > /dev/null
    op item edit --vault {{ vault }} {{ item }} "machineconfig.CLUSTER_ID[text]=$(cat {{ secrets_file }} | yq .cluster.id)" > /dev/null
    op item edit --vault {{ vault }} {{ item }} "machineconfig.CLUSTER_SECRET[text]=$(cat {{ secrets_file }} | yq .cluster.secret)" > /dev/null
    op item edit --vault {{ vault }} {{ item }} "machineconfig.CLUSTER_TOKEN[text]=$(cat {{ secrets_file }} | yq .secrets.bootstraptoken)" > /dev/null
    op item edit --vault {{ vault }} {{ item }} "machineconfig.CLUSTER_SECRETBOXENCRYPTIONSECRET[text]=$(cat {{ secrets_file }} | yq .secrets.secretboxencryptionsecret)" > /dev/null
    op item edit --vault {{ vault }} {{ item }} "machineconfig.CLUSTER_ETCD_CA_CRT[text]=$(cat {{ secrets_file }} | yq .certs.etcd.crt)" > /dev/null
    op item edit --vault {{ vault }} {{ item }} "machineconfig.CLUSTER_ETCD_CA_KEY[text]=$(cat {{ secrets_file }} | yq .certs.etcd.key)" > /dev/null
    op item edit --vault {{ vault }} {{ item }} "machineconfig.CLUSTER_CA_CRT[text]=$(cat {{ secrets_file }} | yq .certs.k8s.crt)" > /dev/null
    op item edit --vault {{ vault }} {{ item }} "machineconfig.CLUSTER_CA_KEY[text]=$(cat {{ secrets_file }} | yq .certs.k8s.key)" > /dev/null
    op item edit --vault {{ vault }} {{ item }} "machineconfig.CLUSTER_AGGREGATORCA_CRT[text]=$(cat {{ secrets_file }} | yq .certs.k8saggregator.crt)" > /dev/null
    op item edit --vault {{ vault }} {{ item }} "machineconfig.CLUSTER_AGGREGATORCA_KEY[text]=$(cat {{ secrets_file }} | yq .certs.k8saggregator.key)" > /dev/null
    op item edit --vault {{ vault }} {{ item }} "machineconfig.CLUSTER_SERVICEACCOUNT_KEY[text]=$(cat {{ secrets_file }} | yq .certs.k8sserviceaccount.key)" > /dev/null
    rm {{ secrets_file }}

[doc('Generate talosconfig')]
[group('setup')]
generate-talosconfig context="area0" vault="area0" item="talos":
    op_item=$(op item get '{{ item }}' --vault '{{ vault }}' 2>/dev/null) || true

    if ! [[ -n "$op_item" ]]; then
        just log error "1Password item does not exist" vault "{{ vault }}" item "{{ item }}"
        exit 1
    fi

    just log info "Generating talosconfig"
    op read op://{{ vault }}/{{ item }}/MACHINE_CA_CRT | base64 -d > ca.crt
    op read op://{{ vault }}/{{ item }}/MACHINE_CA_KEY | base64 -d > ca.key
    talosctl gen key --name admin
    talosctl gen csr --key admin.key --ip 127.0.0.1
    talosctl gen crt --ca ca --csr admin.csr --name admin --hours 87600
    op item edit --vault {{ vault }} {{ item }} "talosconfig.ADMIN_CRT[text]=$(cat admin.crt | base64 -w 0)" > /dev/null
    op item edit --vault {{ vault }} {{ item }} "talosconfig.ADMIN_KEY[text]=$(cat admin.key | base64 -w 0)" > /dev/null
    rm admin.crt admin.csr admin.key ca.crt ca.key
    just template "{{ source_directory() }}/talosconfig.j2" \
        -D "talos_context={{ context }}" \
        -D "op_vault={{ vault }}" \
        -D "op_item={{ item }}" \
        > $TALOSCONFIG
    op item edit --vault {{ vault }} {{ item }} "talosconfig.talosconfig[text]=$(cat $TALOSCONFIG)" > /dev/null

[confirm('Apply Talos config to ' + node + ' [y|N] ?')]
[doc('Apply Talos config to a node')]
[group('config')]
apply-node node *args:
    just log info "Applying Talos machineconfig" "node" "{{ node }}";
    just talos render-config "{{ node }}" | talosctl -n "{{ node }}" apply-config -f /dev/stdin {{ args }}

[confirm('Apply Talos config to all nodes in the cluster [y|N] ?')]
[doc('Apply Talos config to all nodes in the cluster')]
[group('config')]
apply-cluster *args:
    kubectl get nodes --no-headers | while read -r node _; do
        just --yes talos apply-node ${node} {{ args }}
    done

[doc('Render Talos config for a node')]
[group('config')]
render-config node:
    schematic="$(just talos schematic-id "{{ node }}")"
    role="controlplane"
    if [[ -f "{{ source_directory() }}/nodes/worker/{{ node }}.yaml.j2" ]]; then
        role="worker"
    fi
    talosctl machineconfig patch <(just template "{{ source_directory() }}/cluster.yaml.j2" -D "schematic=${schematic}") \
        -p @<(just template "{{ source_directory() }}/${role}.yaml.j2") \
        -p @<(just template "{{ source_directory() }}/nodes/${role}/{{ node }}.yaml.j2")

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

[confirm('Shutdown all nodes in the cluster [y|N] ?')]
[doc('Shutdown all nodes in the cluster')]
[group('lifecycle')]
shutdown-cluster *args:
    kubectl get nodes --no-headers | while read -r node _; do
        just --yes talos shutdown-node ${node} {{ args }}
    done

[confirm('Reset node ' + node + ' [y|N] ?')]
[doc('Reset a node')]
[group('recovery')]
reset-node node *args:
    talosctl -n "{{ node }}" reset --system-labels-to-wipe STATE --system-labels-to-wipe EPHEMERAL --system-labels-to-wipe u-local-hostpath --graceful=false --reboot{{ args }}

[confirm('Reset all nodes in the cluster [y|N] ?')]
[doc('Reset all nodes in the cluster')]
[group('recovery')]
reset-cluster *args:
    kubectl get nodes --no-headers | while read -r node _; do
        just --yes talos reset-node ${node} {{ args }}
    done

[private]
schematic-file node="":
    file="{{ source_directory() }}/schematic.yaml.j2"
    if [[ -n "{{ node }}" ]]; then
        for f in "{{ source_directory() }}"/nodes/*/"{{ node }}".schematic.yaml.j2; do
            [[ -f "$f" ]] && file="$f"
        done
    fi
    echo "$file"

[private]
schematic-id node="":
    curl -sX POST --data-binary @<(just template "$(just talos schematic-file "{{ node }}")") "https://factory.talos.dev/schematics" | jq -r '.id'
