resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.my-cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "test_oidc" {
  assume_role_policy = data.aws_iam_policy_document.test_oidc_assume_role_policy.json
  name               = "test-oidc"
}

resource "aws_iam_policy" "test-policy" {
  name = "test-policy1"

  policy = jsonencode({
    Statement = [{
      Action = [
        "s3:*",
        "ec2:*"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "test_attach" {
  role       = aws_iam_role.test_oidc.name
  policy_arn = aws_iam_policy.test-policy.arn
}






















/*
data "aws_eks_cluster_auth" "cluster_auth" {
  name       = "demo"
  depends_on = [aws_eks_cluster.demo]
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "my_data" {
  name       = "demo"                 #--EKS Cluster Name
  depends_on = [aws_eks_cluster.demo] #--Dependancy, don't attempt lookup until cluster is provisioned
}

/*
provider "kubernetes" {
  host                   = data.aws_eks_cluster.my_data.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.my_data.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}

# Creating a config map using terraform. You can also create it as a kubernetes object.
resource "kubernetes_config_map" "aws_auth_configmap" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = <<YAML
- rolearn: "arn:aws:iam::${data.aws_caller_identity.current.id}:role/test-eks"
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- rolearn: "arn:aws:iam::${data.aws_caller_identity.current.id}:user/Mac-user"
  username: Mac-user
  groups:
    - system:masters
YAML
  }
}


/*#==========================
data "http" "wait_for_cluster" {

  url            = format("%s/healthz", aws_eks_cluster.demo.endpoint)
  ca_certificate = base64decode(aws_eks_cluster.demo.certificate_authority[0].data)
  timeout        = var.wait_for_cluster_timeout

  depends_on = [
    aws_eks_cluster.demo
  ]
}

variable "wait_for_cluster_timeout" {
  description = "A timeout (in seconds) to wait for cluster to be available."
  type        = number
  default     = 300
}
*/

