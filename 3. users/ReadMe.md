## Adding users to EKS cluster
- EKS does not support IAM groups.
- This means that we have to update eks configmap each time.
- You can create a role and have users assume to the role, just like a group. More flexible way to manage users and only update the configmap only once.
- Create a role and bind users to that role.
- You can add users and give them admin access or read only access.

**A. Developer user:**
- Need the user who created the cluster to modify the configMap.

**Step-01. Create a clusterRole and ClusterRoleBinding**.
```yaml
# role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: reader
rules:
- apiGroups: ["*"]
  resources: ["deployments", "pods"]
  verbs: ["get", "list", "watch"]
```
```yaml
#binding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: reader
subjects:
- kind: Group
  name: reader
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: reader
  apiGroup: rbac.authorization.k8s.io
  ```

- Create the ClusterRole and ClusterRoleBinding by running;
```
  kubectl apply -f role.yaml binding.yaml
```
**Step-02: Create a policy in aws that will be attached to a user**
- Create a DeveloperPolicy
 ```hcl
actions = [
  "eks:DescribeNodegroup",
  "eks:ListNodegroups",
  "eks:DescribeCluster",
  "eks:ListClusters",
  "eks:AccessKubernetesApi",
  "ssm:GetParameter",
  "eks:ListUpdates",
  "eks:ListFargateProfiles"
]
  ```
**Step-03: Create a group and attach the policy** 

- Create the developer group.

**Step-04: Create a user called developer**

- Create a user called Developer and add them to the group. Give the user programmatic access. Download the keys to set up a profile.

**Step-05: Configure Developer profile**

- Go to terminal and run : **aws configure --profile developer** and add the access key and secret key

**Step-06: Modify the configMap in kube-system namespace.**

- Run the following command to edit the configMap
```
 kubectl edit -n kube-system configmap/aws-auth
 ```
**Step-07: Modify the configMap by adding a key to map users.**

- Add a key in the configMap
```yaml
      mapUsers: |
        - userarn: arn:aws:iam::<acc id>:user/developer
          username: developer
          groups:
          - system:masters ---to make admin
          - reader
```
**Step-08: Save and update the kube config with the developer profile.**

- Run the following command to update the kubeconfig file
```
aws eks --region us-east-1 update-kubeconfig --name demo --profile developer
```
**Step-09: Verify that it will use the developer profile**
```
  kubectl config view --minify
  ```
**Step-10: Verify the permissions the user has**
```
kubectl auth can-i get pods
kubectl run nginx --image=nginx
```

**B. Admin user:** 
- Need to create an admin role to be assumed by all users

**Step-01: Create a role and add the role to the configmap**
- Create an admin policy with `Iam:PassRole`
```hcl
data "aws_iam_policy_document" "masters" {
  statement {
    sid       = "AllowAdmin"
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
  statement {
    sid    = "AllowPassRole"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["eks.amazonaws.com"]
    }
  }
}
```
- Create the admin role and attach the policy
- Create a trust relationship between the users and the role. Create an `sts:AssumeRole`, with principal as the role created above. 

**Step-02. Create a user who can assume that role hence perform any action in eks.**
- Create user called `manager` and attach the assume role policy to the user or group.
- Download the credentials for the manager and configure in aws.
```yaml
aws configure --profile manager 
# add access and secret key.
```
- Configure the source profile in the .aws/config file
```json
[profile admin]
role_arn = arn:aws:iam::411854276167:role/Masters-eks-Role
source_profile = admin
region = us-east-1
output = json
```
- Confirm if you can assume the role by running the command below.
```
aws sts assume-role --role-arn arn:aws:iam::<acc id>:role/admin --role-session manager-session --profile manager
```
**Step-03: Update the configMap**
```
kubectl edit -n kube-system configmap/aws-auth
 ```
- Add role under mapRole.
```yaml
mapRoles: |
  - rolearn: arn:aws:iam::<acc id>:role/admin
    username: admin
    groups:
    - system:masters
 ```
**Step-04: Create a profile in ~/.aws/config**
```yaml
[profile admin]
 role_arn = arn:aws:iam::<acc id>:role/admin
 source_profile = manager
```
**Step-05: Update the eks config with the admin profile.**
```
aws eks region us-east-1 update-kubeconfig --name demo --profile admin
```
**Step-06: verify that the admin profile is being used**
```
kubectl config view --minify
```
Step-07: Verify authorization by running the command below.
```
kubectl auth can-i "*" "*"
```
