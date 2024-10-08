# OIDC Provider

- To manage permissions for your applications that you deploy in Kubernetes. You can either attach policies to Kubernetes nodes directly.
- In that case, every pod will get the same access to AWS resources. Or you can create OpenID connect provider, which will allow granting
- IAM permissions based on the service account used by the pod.

```hcl
data "tls_certificate" "eks" {
  url = aws_eks_cluster.demo.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.demo.identity[0].oidc[0].issuer
}
```

You can test the OIDC  using the code below.
```hcl
data "aws_iam_policy_document" "test_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:aws-test"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "test_oidc" {
  assume_role_policy = data.aws_iam_policy_document.test_oidc_assume_role_policy.json
  name               = "test-oidc"
}

resource "aws_iam_policy" "test-policy" {
  name = "test-policy"

  policy = jsonencode({
    Statement = [{
      Action = [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation"
      ]
      Effect   = "Allow"
      Resource = "arn:aws:s3:::*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "test_attach" {
  role       = aws_iam_role.test_oidc.name
  policy_arn = aws_iam_policy.test-policy.arn
}

output "test_policy_arn" {
  value = aws_iam_role.test_oidc.arn
}
```
- Create OIDC provider.

- Next is to create a pod to test IAM roles for service accounts. 
- First, we are going to omit annotations to bind the service account with the role. 
- The way it works, you create a service account and use it in your pod spec. 
- It can be anything, deployment, statefulset, or some jobs. 
```
kubectl exec aws-cli -- aws s3api list-buckets
```
---
```
annotations:
   eks.amazonaws.com/role-arn: arn:aws:iam::424432388155:role/test-oidc
```

To expose the application to the internet, you can create a Kubernetes service of a type load balancer and use annotations to configure load balancer properties.
By default, Kubernetes will create a load balancer in public subnets, so you don't need to provide any additional configurations. 
Also, if you want a new network load balancer instead of the old classic load balancer, you can add aws-load-balancer-type equal to nlb. 

Sometimes if you have a large infrastructure with many different services, you have a requirement to expose the application only within your VPC. 
For that, you can create a private load balancer. To make it private, you need additional annotation: 
      aws-load-balancer-internal and then provide the CIDR range. Usually, you use 0.0.0.0/0 to allow any services within your VPC to access it. 