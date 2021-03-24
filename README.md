# NFS Ganesha server and external provisioner

`nfs-ganesha-server-and-external-provisioner` is an out-of-tree dynamic provisioner for Kubernetes 1.14+. You can use it to quickly & easily deploy shared storage that works almost anywhere. Or it can help you write your own out-of-tree dynamic provisioner by serving as an example implementation of the requirements detailed in [the proposal](https://github.com/kubernetes/kubernetes/pull/30285). 

It works just like in-tree dynamic provisioners: a `StorageClass` object can specify an instance of `nfs-ganesha-server-and-external-provisioner` to be its `provisioner` like it specifies in-tree provisioners such as GCE or AWS. Then, the instance of nfs-ganesha-server-and-external-provisioner will watch for `PersistentVolumeClaims` that ask for the `StorageClass` and automatically create NFS-backed `PersistentVolumes` for them. For more information on how dynamic provisioning works, see [the docs](http://kubernetes.io/docs/user-guide/persistent-volumes/) or [this blog post](http://blog.kubernetes.io/2016/10/dynamic-provisioning-and-storage-in-kubernetes.html).

Note: This repository was migrated from https://github.com/kubernetes-incubator/external-storage/tree/master/nfs. Some of the following instructions will be updated once the build and release automtion is setup. To test container image built from this repository, you will have to build and push the nfs-provisioner image using the following instructions.

```sh
make build
make container
# `nfs-provisioner:latest` will be created. 
# To upload this to your customer registry, say `gcr.io/myorg`, you can use
# docker tag nfs-provisioner:latest gcr.io/myorg/nfs-provisioner:latest
# docker push gcr.io/myorg/nfs-provisioner:latest
```

## Quickstart

Choose some volume for your `nfs-ganesha-server-and-external-provisioner` instance to store its state & data in and mount the volume at `/export` in [deploy/kubernetes/deployment.yaml](./deploy/kubernetes/deployment.yaml). It doesn't have to be a `hostPath` volume, it can e.g. be a PVC. Note that the volume must have a [supported file system](https://github.com/nfs-ganesha/nfs-ganesha/wiki/Fsalsupport#vfs) on it: any local filesystem on Linux is supported & NFS is not supported.

```yaml
...
  volumeMounts:
    - name: export-volume
      mountPath: /export
volumes:
  - name: export-volume
    hostPath:
      path: /tmp/nfs-provisioner
...
```

Choose a `provisioner` name for a `StorageClass` to specify and set it in `deploy/kubernetes/deployment.yaml`
```yaml
...
args:
  - "-provisioner=example.com/nfs"
...
```

Create the deployment.
```console
$ kubectl create -f deploy/kubernetes/deployment.yaml
serviceaccount/nfs-provisioner created
service "nfs-provisioner" created
deployment "nfs-provisioner" created
```

Create `ClusterRole`, `ClusterRoleBinding`, `Role` and `RoleBinding` (this is necessary if you use RBAC authorization on your cluster, which is the default for newer kubernetes versions).
```console
$ kubectl create -f deploy/kubernetes/rbac.yaml
clusterrole.rbac.authorization.k8s.io/nfs-provisioner-runner created
clusterrolebinding.rbac.authorization.k8s.io/run-nfs-provisioner created
role.rbac.authorization.k8s.io/leader-locking-nfs-provisioner created
rolebinding.rbac.authorization.k8s.io/leader-locking-nfs-provisioner created
```

Create a `StorageClass` named "example-nfs" with `provisioner: example.com/nfs`.
```console
$ kubectl create -f deploy/kubernetes/class.yaml
storageclass "example-nfs" created
```

Create a `PersistentVolumeClaim` with `storageClassName: example-nfs`.
```console
$ kubectl create -f deploy/kubernetes/claim.yaml
persistentvolumeclaim "nfs" created
```

A `PersistentVolume` is provisioned for the `PersistentVolumeClaim`. Now the claim can be consumed by some pod(s) and the backing NFS storage read from or written to.
```console
$ kubectl get pv
NAME                                       CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS      CLAIM         REASON    AGE
pvc-dce84888-7a9d-11e6-b1ee-5254001e0c1b   1Mi        RWX           Delete          Bound       default/nfs             23s
```

Deleting the `PersistentVolumeClaim` will cause the provisioner to delete the `PersistentVolume` and its data.

Deleting the provisioner deployment will cause any outstanding `PersistentVolumes` to become unusable for as long as the provisioner is gone.

## Running

To deploy `nfs-ganesha-server-and-external-provisioner` on a Kubernetes cluster see [Deployment](docs/deployment.md).

To use `nfs-ganesha-server-and-external-provisioner` once it is deployed see [Usage](docs/usage.md).

## [Changelog](CHANGELOG.md)

Releases done here in external-storage will not have corresponding git tags (external-storage's git tags are reserved for versioning the library), so to keep track of releases check this README, the [changelog](CHANGELOG.md), or [GCR](https://gcr.io/k8s-staging-sig-storage/nfs-provisioner)

## Writing your own

Go [here](https://github.com/kubernetes-sigs/sig-storage-lib-external-provisioner/tree/master/examples/hostpath-provisioner) for an example of how to write your own out-of-tree dynamic provisioner.

## Roadmap

The source code in this repository was migrated from [kubernetes-incubator/external-storage](https://github.com/kubernetes-incubator/external-storage/tree/master/nfs). We are yet to complete the following migration tasks. 
- Update e2e tests
- Automate building container images to the new registry
- Update helm chart

This is still alpha/experimental and will change to reflect the [out-of-tree dynamic provisioner proposal](https://github.com/kubernetes/kubernetes/pull/30285)

## Community, discussion, contribution, and support

Learn how to engage with the Kubernetes community on the [community page](http://kubernetes.io/community/).

You can reach the maintainers of this project at:

- [Slack](https://kubernetes.slack.com/messages/sig-storage)
- [Mailing List](https://groups.google.com/forum/#!forum/kubernetes-sig-storage)

### Code of conduct

Participation in the Kubernetes community is governed by the [Kubernetes Code of Conduct](code-of-conduct.md).
