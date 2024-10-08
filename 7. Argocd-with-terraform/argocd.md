# Install ArgoCD in k8s
https://argo-cd.readthedocs.io/en/stable/getting_started/

**Step-01: Create argocd namespace and install argocd**
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
**Step-02: Access ArgoCD UI**
```
kubectl get svc -n argocd
kubectl port-forward svc/argocd-server 8080:443 -n argocd
```
**Step-03: Login with admin user and below token (as in documentation):**
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode && echo
or 
kubectl -n argocd get secret argocd-initial-admin-secret -oyaml        #copy the base64 encoded password
echo <password> | base64 --decode    #ignore the % at the end
```
 - You can change and delete init password

**Step-05: Deploy the application to the cluster**
- Switch to `argodc` namespace
- Modify the `application.yaml` with your git repository and apply to the cluster.
```
kubectl apply -f application.yaml
```
```yaml
#application.yaml

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp-argo-application
  namespace: argocd
spec:
  project: default
  source:
     repoURL: https://github.com/yourrepo.git
     targetRevision: HEAD
     path: prod
  destination:
    server: https://kubernetes.default.svc
    namespace: myapp

  syncPolicy:
    syncOptions:
      - CreateNamespace=true
    automated:
      selfHeal: true
      prune: true
```
**Step-06: Apply the secret in your cluster.** 

- In place of password, use token
```
kubectl apply -f secrets.yaml
```

```yaml
#secret.yaml

apiVersion: v1
kind: Secret
metadata:
   name: argocd-repo
   namespace: argocd
   labels:
      argocd.argoproj.io/secret-type: repository
stringData:
   type: git
   url: https://github.com/yourrepo.git
   password: <your-token>
   username: <your-username>
 ```
**Step-07: Push your manifest files to your repo**

```yaml
#deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  selector:
    matchLabels:
     app: myapp
  replicas: 2
  template:
    metadata:
      labels:
        app: myapp
    spec:
       containers:
       - name: myapp
         image: wemadevops/kube-frontend-nginx:1.0.0
         ports:
         - containerPort: 8080
```
```yaml
#service.yaml

apiVersion: v1
kind: Service
metadata:
   name: myapp-service
spec:
  selector:
    app: myapp
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 8080
```


