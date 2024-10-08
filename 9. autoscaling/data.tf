data "aws_eks_cluster" "my-cluster" {
  name = "demo"
}

data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.my-cluster.identity[0].oidc[0].issuer
}

data "aws_eks_cluster_auth" "cluster" {
  name = "demo"
}

data "kubectl_file_documents" "autoscaler" {
  content = file("${path.module}/manifests/autoscaler.yaml")
}

data "kubectl_file_documents" "cluster_role" {
  content = file("${path.module}/manifests/clusterrole.yaml")
}

data "kubectl_file_documents" "cluster_role_binding" {
  content = file("${path.module}/manifests/clusterrolebinding.yaml")
}

data "kubectl_file_documents" "role" {
  content = file("${path.module}/manifests/role.yaml")
}

data "kubectl_file_documents" "role_binding" {
  content = file("${path.module}/manifests/rolebinding.yaml")
}

data "kubectl_file_documents" "svc" {
  content = file("${path.module}/manifests/svc.yaml")
}

