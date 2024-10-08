data "aws_eks_cluster" "cluster" {
  name = "demo"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "demo"
}

data "aws_caller_identity" "test" {}

# Trust Policy to be used by all IAM Roles
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}