# Create EKS Cluster
resource "aws_eks_cluster" "demo" {
  name     = var.name
  role_arn = data.aws_iam_role.eks.arn


  vpc_config {
    endpoint_private_access = true
    subnet_ids              = data.aws_subnets.private.ids
  }

  /*access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }*/
}
























