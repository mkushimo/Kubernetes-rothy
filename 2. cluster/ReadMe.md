# User management in K8S - RBAC
-  When starting with K8s, we tend to use full administrator
   credentials. But in a real production environment, you may want to have different users, groups and privileges.  
- Kubernetes provides no API object for users, and hence user management must be configured by the cluster administrator.
- Authentication can be; **Certificate-based, Token-based, Basic Authentication or OAuth2**.

**Certificate-based Authentication**

- Kubernetes is configured with a Certificate Authority (CA)
```yaml
/etc/kubernetes/pki/ca.crt     public certificate
/etc/kubernetes/pki/ca.key     private key
```
Every SSL certificate signed with this CA will be accepted by the Kubernetes API.

- Two important fields in the SSL certificate:
```yaml
Common Name (CN): Kubernetes will interpret this as the user
Organization (O): Kubernetes will interpret this value as the group.
```

**How to create user certificates.**

**Step-01: Create a private key**
```yaml
openssl genrsa -out wema.key 2048
```

**Step-02: Create certificate signing request (CSR)**
```yaml
openssl req -new -key wema.key -out wema.csr -subj "/CN=wema/O=devs"
```

**Step-03: Create certificate from CSR using the cluster authority**
```yaml
openssl x509 -req -in wema.csr -CA CA_LOCATION/ca.crt -CAkey CA_LOCATION/ca.key -CAcreateserial -out wema.crt -days 500
```

**Step-04: Create kubectl configuration**

If you do not have a cluster yet in your local machine, you can add a new cluster by running;
```yaml
kubectl config set-cluster sandbox --certificate-authority=ca.pem --embed-certs=true --server=https://<PUBLIC_ADDR_OF_CLUSTER>:6443
```

**Step-05: Add the new credentials to kubectl**
```yaml
kubectl config set-credentials wema --client-certificate=wema.crt --client-key=wema.key --embed-certs=true
```
**Step-06: Add the new context to kubectl**

```yaml
kubectl config set-context sandbox-wema --cluster=sandbox --user=wema
```
**Step-07: Test the configuration by changing to the newly created context**
```yaml
kubectl config use-context sandbox-wema
```
**Step-08: Execute command**
```yaml
kubectl get pods
```

# Role Based Access Control (RBAC)

There are three important groups when dealing with RBAC;

  - Subjects
  - API Resources
  - Operations (Verbs))

**Roles**

- Roles establish a set of allowed operations (rules) over a set of resources in a namespace
- You can create a role either imperatively or declaratively.

**Step-01: Create a role**
```yaml
kubectl create role pod-reader --verb=get --verb=list --verb=watch --resource=pods
```
or
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  creationTimestamp: null
  name: pod-reader
  namespace: test
rules:
- apiGroups:
  - ""    # when it is core, we use an empty string
  resources:
  - pods
  verbs:
  - get
  - list
  - watch
```
You can create an admin role using wildcard characters.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
   namespace: test
   name: ns-admin
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
```

**Step-02: Create a RoleBinding**

You can create a roleBinding imperatively or declaratively.
```yaml
kubectl create rolebinding dev --role=pod-reader --user=wema
```
or 
```yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
   name: devs-read-pods
   namespace: test
subjects:
- kind: Group
  name: devs
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-access
  apiGroup: rbac.authorization.k8s.io
```
or 
```yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
   name: devs-read-pods
   namespace: test
subjects:
- kind: User
  name: wema # name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-access
  apiGroup: rbac.authorization.k8s.io
```

**Cluster role**

- The difference between a role and a clusterRole is that a role is namespaced while a cluster role isn't.
- You can create a clusterRole imperatively or declaratively.

**Step-01: Create a clusterRole**
```yaml
 kubectl create clusterrole pod-reader --verb=get,list,watch --resource=pods
```
or
```yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: all-pod-access
    # no namespace specified
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

**Step-02: create a clusterRoleBinding**
```yaml
 kubectl create clusterrolebinding cluster-admin --clusterrole=pod-reader --user=wema --user=user2 --group=devs
```
or
```yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: reads-all-pods
subjects:
- kind: User
  name: wema # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: all-pod-access
  apiGroup: rbac.authorization.k8s.io
```

**Default ClusterRoleBindings**

Kubernetes includes some ClusterRoleBindings by default;

- **system:basic-user:** - For unauthenticated users (group **system:unauthenticated**). No operations are allowed.
- **cluster-admin:** - For members of the **system:masters** group. Can do any operation on the cluster using the cluster-admin ClusterRole.
- ClusterRoleBinding for the **different components** of the cluster (kube-controller-manager, kube-scheduler, kube-proxy ...)