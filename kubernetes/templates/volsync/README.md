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
- `APP_UID`: [ default | 568 ]
- `APP_GID`: [ default | 568 ]
- `APP_PVC`: [ default | ${APP} ]
- `APP_PVC_ACCESSMODES`: [ default | ReadWriteOnce ]
- `APP_PVC_CAPACITY`: The PVC size. [ default | 1Gi ]
- `APP_PVC_STORAGECLASS`: [ default | ceph-block ]
- `VOLSYNC_CACHE_ACCESSMODES`: [ default | ReadWriteOnce ]
- `VOLSYNC_CACHE_CAPACITY`: [default | (ReplicationSource - 4Gi) (ReplicationDestination - 8Gi) ]
- `VOLSYNC_CACHE_SNAPSHOTCLASS`: [ default | democratic-csi-local-hostpath ]
- `VOLSYNC_COPYMETHOD`: [ default | Snapshot ]
- `VOLSYNC_S3_ADDRESS`:
- `VOLSYNC_S3_BUCKET_NAME`: [ default | volsync ]
- `VOLSYNC_SCHEDULE`: [ default | 0 * * * * ]
- `VOLSYNC_SNAPSHOTCLASS`: [ default | csi-ceph-blockpool ]
