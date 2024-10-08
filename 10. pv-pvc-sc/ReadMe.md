# Kubernetes Persistent Volume (PV) and Persistent Volume Claim (PVC)

**a) Persistent Volume (pv)**
- Volumes are a way to attach storage to a kubernetes object.
- There are two main storage types within Kubernetes:
  - **ephemeral**
  - **persistent**
Persistent volumes preserve their contents between pod, service and container restarts.

**1) Provisioning and usage:**
We provision persistent volumes in two ways
- **static**: **PV** is an object, PVC finds and uses a specific PV
- **dynamic:** PVC attempts to dynamically create a volume during runtime

Either way, a `PVC` is Bound to a `PV`. 

**2) Reclaim Policy** 
After a volume has served its purpose via an associated claim, Kubernetes can perform one of three actions:

**Retain**: consider PV Released, but prevent further claims, enabling manual intervention to inspect, free data, or make available
**Delete**: delete and wipe the PV
**Recycle**: wipe the PV and enable new claims

Effectively, `Retain` blocks further claims on the Released volume, instead forcing a new PV to be created for a particular storage medium. 
In fact, we can later change the status to Available.

**3) Status**
In general, a `PV` can be in one of several phases:
  - **Available**: free, not bound to PVC
  - **Bound**: bound to PVC
  - **Released**: PVC deleted, PV expects manual intervention
  - **Failed**: failed automatic reclamation
  Usually, it’s easy to check the current state via the get subcommand of kubectl.

**4) Access Modes**
Volumes provide different access modes according to the way they can be mounted:

- **ReadWriteOnce (RWO)**: read-write by a single node
- **ReadOnlyMany (ROX)**: read-only by many nodes
- **ReadWriteMany (RWX)**: read-write by many nodes
- **ReadWriteOncePod (RWOP)**: read-write by a single pod

Still, we can only use one mode per mount and PVC.

**b) Creating a PV:**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: hostpath-vol0
  namespace: default
spec:
  storageClassName: xclass
  capacity:
    storage: 6Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/hostpath-vol0"
    type: DirectoryOrCreate
```

In this case, we create a `hostPath` volume from the `/mnt/hostpath-vol0/` path, which gets created if it doesn’t exist. Its storage class is `xclass`.

Importantly, the storage capacity is` 6Gi` and the access mode is `ReadWriteOnce`.

**c) Create a Persistent Volume Claim (PVC)**
A PersistentVolumeClaim (PVC) is a Kubernetes resource that represents a request for storage by a pod. 
It can specify requirements for storage, such as the size, access mode, and storage class. Kubernetes uses the PVC to find an available PV that satisfies the PVC’s requirements.

A PVC is created by a pod to request storage from a PV. Once a PVC is created, it can be mounted as a volume in a pod. The pod can then use the mounted volume to store and retrieve data.
- Storage claims in Kubernetes are just storage requests.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: hostpath-vol0-claim
  namespace: default
spec:
  storageClassName: xclass
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi

```

By specifying a storageClassName of `xclass`, we link this `PVC` to the `PV` of the same class. If all other specifics match and there is enough space, 
they should connect.

Notably, **claims don’t directly specify a PV**. Instead, a PVC is like a filter with criteria for any existing PV that suits the needs.

```yaml
#PVC without storageClass name
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pod0-claim
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi

```
- Although we didn't create a volume to satisfy this claim beforehand, it should get Bound.

**d) Check PV nad PVC**

```shell
kubectl get pv
kubectl get pvc
```