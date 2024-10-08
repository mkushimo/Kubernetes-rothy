
data "aws_iam_role" "eks" {
  name = "eks-cluster-demo"
}

data "aws_iam_role" "nodes" {
  name = "eks-node-group-nodes"
}

data "aws_vpc" "dev" {
  tags = {
    Name = "eks-vpc"
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dev.id]
  }
}

data "aws_subnets" "nodes" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dev.id]
  }

  tags = {
    Name = var.subnet_tags
  }
}
