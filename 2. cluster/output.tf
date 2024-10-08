output "cluster_id" {
  value = aws_eks_cluster.demo.id
}

output "eks" {
  value = data.aws_iam_role.eks.arn
}

output "nodes" {
  value = data.aws_iam_role.nodes.arn
}
