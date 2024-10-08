resource "aws_eks_access_entry" "devops" {
  for_each          = { for idx, entry in local.eks_access_entries_devops : idx => entry }
  cluster_name      = each.value.cluster_name
  principal_arn     = each.value.principal_arn
  kubernetes_groups = ["admins"]
}

resource "aws_eks_access_entry" "backend" {
  for_each          = { for cluser, user in local.eks_access_entries_backend : cluser => user }
  cluster_name      = each.value.cluster_name
  principal_arn     = each.value.principal_arn
  kubernetes_groups = ["reader"]
}

resource "aws_eks_access_entry" "qa" {
  for_each          = { for cluser, user in local.eks_access_entries_qa : cluser => user }
  cluster_name      = each.value.cluster_name
  principal_arn     = each.value.principal_arn
  kubernetes_groups = ["testers"]
}

# DEVOPS CLUSTER ADMIN
resource "aws_eks_access_policy_association" "devops" {
  for_each = { for cluser, user in local.eks_access_entries_devops : cluser => user }

  cluster_name  = each.value.cluster_name
  principal_arn = each.value.principal_arn
  policy_arn    = var.eks_access_policies.cluster_admin

  access_scope {
    type = "cluster"
  }
}

# BACKEND EDIT
resource "aws_eks_access_policy_association" "backend_edit" {
  for_each = { for cluser, user in local.eks_access_entries_backend : cluser => user }

  cluster_name  = each.value.cluster_name
  principal_arn = each.value.principal_arn
  policy_arn    = var.eks_access_policies.namespace_edit

  access_scope {
    type       = "namespace"
    namespaces = var.eks_access_scope["backend"].namespaces_edit
  }
}

# BACKEND READ ONLY
resource "aws_eks_access_policy_association" "backend_read_only" {
  for_each = { for cluser, user in local.eks_access_entries_backend : cluser => user }

  cluster_name  = each.value.cluster_name
  principal_arn = each.value.principal_arn
  policy_arn    = var.eks_access_policies.namespace_read_only

  access_scope {
    type       = "namespace"
    namespaces = var.eks_access_scope["backend"].namespaces_read_only
  }
}

# QA EDIT
resource "aws_eks_access_policy_association" "qa_edit" {
  for_each = { for cluser, user in local.eks_access_entries_qa : cluser => user }

  cluster_name  = each.value.cluster_name
  principal_arn = each.value.principal_arn
  policy_arn    = var.eks_access_policies.namespace_edit

  access_scope {
    type       = "namespace"
    namespaces = var.eks_access_scope["qa"].namespaces_edit
  }
}

# QA READ ONLY
resource "aws_eks_access_policy_association" "qa_read_only" {
  for_each = { for cluser, user in local.eks_access_entries_qa : cluser => user }

  cluster_name  = each.value.cluster_name
  principal_arn = each.value.principal_arn
  policy_arn    = var.eks_access_policies.namespace_read_only

  access_scope {
    type       = "namespace"
    namespaces = var.eks_access_scope["qa"].namespaces_read_only
  }
}

# Create an IAM Role to be assumed by Yet Another CloudWatch Exporter
resource "aws_iam_role" "yace_exporter_access" {
  name = "monitoring-yace-exporter-role"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name = "monitoring-yace-exporter-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "cloudwatch:ListMetrics",
            "cloudwatch:GetMetricStatistics",
            "cloudwatch:GetMetricData",
            "tag:GetResources",
            "apigateway:GET"
          ]
          Effect = "Allow"
          Resource = ["*"]
        },
      ]
    })
  }

  tags = {
    Name = "monitoring-yace-exporter-role"
  }
}

resource "aws_eks_pod_identity_association" "yace" {
    for_each = var.eks_clusters

    cluster_name    = each.key
    namespace       = var.eks_pod_identities.monitoring.namespace
    service_account = var.eks_pod_identities.monitoring.projects["yace"].serviceaccount_name
    role_arn        = aws_iam_role.yace_exporter_access.arn
  }