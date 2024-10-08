variable "eks_clusters" {
  description = "List of EKS clusters to create records"
  type        = set(string)
  default = [
    "demo"
  ]
}

variable "eks_users" {
  description = "IAM Users to be added to EKS with aws_eks_access_entry, one item in the set() per each IAM User"
  type        = map(list(string))
  default = {
    devops  = ["arn:aws:iam:::user/Kennedy"],
    backend = ["arn:aws:iam:::user/Simon"],
    qa      = ["arn:aws:iam:::user/Mark"],
  }
}

variable "eks_access_scope" {
  description = "EKS Namespaces for teams to grant access with aws_eks_access_policy_association"
  type = map(object({
    namespaces_admin     = optional(set(string)),
    namespaces_edit      = optional(set(string)),
    namespaces_read_only = optional(set(string))
  }))
  default = {
    backend = {
      namespaces_edit      = ["*backend*", "*dev*"],
      namespaces_read_only = ["*ops*"]
    },
    qa = {
      namespaces_edit      = ["*qa*"],
      namespaces_read_only = ["*backend*"]
    }
  }
}

variable "eks_access_policies" {
  description = "List of EKS clusters to create records"
  type        = map(string)
  default = {
    cluster_admin       = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy",
    namespace_admin     = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy",
    namespace_edit      = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy",
    namespace_read_only = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy",
  }
}

# Pod identity
variable "eks_pod_identities" {
  description = "EKS ServiceAccounts for Pods to grant access with eks-pod-identity"
  type = map(object({
    namespace = string,
    projects = map(object({
      serviceaccount_name = string
    }))
  }))
  default = {
    monitoring = {
      namespace = "ops-monitoring-ns"
      projects = {
        loki = {
          serviceaccount_name = "loki-sa"
        },
        yace = {
          serviceaccount_name = "yace-sa"
        }
      }
    }
  }
}

