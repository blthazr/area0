# VolSync Template

## Flux Kustomization

This requires `postBuild` configured on the Flux Kustomization

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: &app __APP_NAME
  namespace: flux-system
spec:
  # ...
  postBuild:
    substitute:
      APP: *app
      VOLSYNC_CAPACITY: 5Gi
```

and then call the template in your applications `kustomization.yaml`

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  # ...
  - ../../../../templates/volsync
```

## Required `postBuild` vars:
- `APP`: The application name

## Optional `postBuild` vars:
- `APP_GID`: default-> 568
- `APP_UID`: default-> 568
- `VOLSYNC_ACCESSMODES`: default-> ReadWriteOnce
- `VOLSYNC_CACHE_CAPACITY`: default-> 1Gi
- `VOLSYNC_CACHE_SNAPSHOTCLASS`: default-> democratic-csi-local-hostpath
- `VOLSYNC_CAPACITY`: default-> 1Gi
- `VOLSYNC_CLAIM`: default -> ${APP}
- `VOLSYNC_COPYMETHOD`: default-> Snapshot
- `VOLSYNC_SNAPSHOTCLASS`:-democratic-csi-local-hostpath
- `VOLSYNC_STORAGECLASS`: default-> democratic-csi-local-hostpath
