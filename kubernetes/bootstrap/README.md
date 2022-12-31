# Bootstrap Flux

## Install Flux manifests

```sh
kubectl apply --server-side --kustomize ./kubernetes/bootstrap/flux
```

## Apply Cluster Configuration

_These cannot be applied with `kubectl` in the regular fashion due to be encrypted with sops_

```sh
sops --decrypt kubernetes/bootstrap/flux/age-key.sops.yaml | kubectl apply -f -
sops --decrypt kubernetes/bootstrap/flux/github-deploy-key.sops.yaml | kubectl apply -f -
sops --decrypt kubernetes/flux/vars/cluster-secrets.sops.yaml | kubectl apply -f -
kubectl apply -f kubernetes/flux/vars/cluster-settings.yaml
```

## 3. Apply the Flux resources to bootstrap the cluster

```sh
kubectl apply --server-side --kustomize ./kubernetes/flux/config
```
