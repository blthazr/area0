set default-script
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

[private]
default:
    just -l kube

[arg("force", long, value="true")]
[arg('namespace', long)]
[arg('type', long, pattern='app-template|standard')]
[doc('Create app deployment')]
create-app app_name namespace="default" type="app-template" force="false":
    kubernetes_dir="{{ justfile_dir() }}/kubernetes"
    just log debug "kubernetes_dir:     $kubernetes_dir"

    namespace_dir="$kubernetes_dir/apps/{{ namespace }}"
    just log debug "namespace_dir:      $namespace_dir"

    app_dir="$kubernetes_dir/apps/{{ namespace }}/{{ app_name }}"
    just log debug "app_dir:            $app_dir"

    templates_dir="$kubernetes_dir/templates/namespace"
    just log debug "templates_dir:      $templates_dir"

    just log debug "app type:           {{ type }}"

    if [[ -d "$app_dir" ]] && [[ -n "$(ls -A "$app_dir")" ]] && [[ "{{ force }}" != "true" ]]; then
        just log error "App directory already exists (use --force to override): $app_dir"
        exit 1
    fi

    export APP="{{ app_name }}"
    export NS="{{ namespace }}"

    if [ ! -d "$namespace_dir" ]; then
        just log warn "Namespace directory does not exist."
        just log info "Creating namespace: {{ namespace }}"
        mkdir -p "$namespace_dir"
        minijinja-cli "$templates_dir/namespace.yaml.j2" -o "$namespace_dir/namespace.yaml"
        minijinja-cli "$templates_dir/kustomization.yaml.j2" -o "$namespace_dir/kustomization.yaml"
    fi

    just log info "Creating app '{{ app_name }}' in namespace '{{ namespace }}'."
    mkdir -p "$app_dir/app"
    minijinja-cli "$templates_dir/app_name/ks.yaml.j2" -o "$app_dir/ks.yaml"
    minijinja-cli "$templates_dir/app_name/README.md.j2" -o "$app_dir/README.md"

    case "{{ type }}" in
        app-template)
            minijinja-cli "$templates_dir/app_name/app-template/helm-release.yaml.j2" -o "$app_dir/app/helm-release.yaml"
            minijinja-cli "$templates_dir/app_name/app-template/oci-repository.yaml.j2" -o "$app_dir/app/oci-repository.yaml"
            ;;
        standard)
            minijinja-cli "$templates_dir/app_name/app/helm-release.yaml.j2" -o "$app_dir/app/helm-release.yaml"
            minijinja-cli "$templates_dir/app_name/common/oci-repository.yaml.j2" -o "$app_dir/app/oci-repository.yaml"
            ;;
        *)
            just log error "Unknown app type"
            ;;
    esac

    minijinja-cli "$templates_dir/app_name/common/external-secret.yaml.j2" -o "$app_dir/app/external-secret.yaml"
    minijinja-cli "$templates_dir/app_name/common/kustomization.yaml.j2" -o "$app_dir/app/kustomization.yaml"
    minijinja-cli "$templates_dir/app_name/common/persistent-volume-claim.yaml.j2" -o "$app_dir/app/persistent-volume-claim.yaml"

    # add app to kustomization.yaml
    yq -i '.resources |= ((. // []) + ["./{{ app_name }}/ks.yaml"])' "$namespace_dir/kustomization.yaml"

    just log info "Created app deployment at $app_dir"
