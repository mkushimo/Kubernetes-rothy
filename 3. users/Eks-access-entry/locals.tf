locals {
   eks_access_entries_devops = flatten([
    for cluster in var.eks_clusters : [
      for user_arn in var.eks_users.devops : {
        cluster_name  = cluster
        principal_arn = user_arn
      }
    ]
  ])
  eks_access_entries_backend = flatten([
    for cluster in var.eks_clusters : [
      for user_arn in var.eks_users.backend : {
        cluster_name  = cluster
        principal_arn = user_arn
      }
    ]
  ])
  eks_access_entries_qa = flatten([
    for cluster in var.eks_clusters : [
      for user_arn in var.eks_users.qa : {
        cluster_name  = cluster
        principal_arn = user_arn
      }
    ]
  ])
}