# Bootstrap

## Flux

### Install Flux

```sh
kubectl apply --server-side --kustomize ./kubernetes/bootstrap/flux
```

### Apply Cluster Configuration

_These cannot be applied with `kubectl` in the regular fashion due to be encrypted with sops_

```sh
cat ~/.config/sops/age/keys.txt | kubectl -n flux-system create secret generic sops-age --from-file=age.agekey=/dev/stdin
sops --decrypt kubernetes/bootstrap/flux/github-deploy-key.sops.yaml | kubectl apply -f -
sops --decrypt kubernetes/flux/vars/cluster-secrets.sops.yaml | kubectl apply -f -
kubectl apply -f kubernetes/flux/vars/cluster-settings.yaml
```

### Apply CRD's

This avoids the dependency loop with many helmreleases requiring Prometheus CRD's. When Prometheus reconciles, it will take these over.

```sh
kubectl apply  -k ./bootstrap/crds/
```

### Apply the Flux resources to finish bootstrapping the cluster

```sh
kubectl apply --server-side --kustomize ./kubernetes/flux/config
```
