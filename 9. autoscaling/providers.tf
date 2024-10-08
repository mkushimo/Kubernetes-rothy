terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.13.11"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Project   = "eks-autoscaling"
      ManagedBy = "terraform"
    }
  }
}

provider "kubernetes" {
  host = local.host
  cluster_ca_certificate = local.certificate
  token = local.token
}

provider "kubectl" {
  host = local.host
  cluster_ca_certificate = local.certificate
  token = local.token
  load_config_file = false
}

locals {
    host                   = data.aws_eks_cluster.my-cluster.endpoint
    certificate = base64decode(data.aws_eks_cluster.my-cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
}