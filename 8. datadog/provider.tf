terraform {
  required_providers {
    datadog = {
      source  = "datadog/datadog"
      version = "~> 3.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = "~> 1.0"
}

# Configure the Datadog provider
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = var.datadog_api_url
}

provider "helm" {
  kubernetes {
    host                   = local.host
    cluster_ca_certificate = local.certificate
    token                  = local.token
  }
}

locals {
  host        = data.aws_eks_cluster.cluster.endpoint
  certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token       = data.aws_eks_cluster_auth.cluster.token
}

provider "aws" {
  region = "ca-central-1"
}