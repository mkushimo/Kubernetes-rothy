################################################################################
# Cluster Security Group
# Defaults follow https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
################################################################################

locals {
  #cluster_name = aws_eks_cluster.demo.name
  vpc_id   = aws_vpc.main.id
  vpc_cidr = var.vpc_cidr
  cluster_security_group_rules = {
    ingress_nodes_all = {
      description = "Node groups to cluster API"
      protocol    = "-1"
      from_port   = 1
      to_port     = 65535
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
      #source_node_security_group = true
    }
    egress_node_all = {
      description = "Cluster API to node groups"
      protocol    = "-1"
      from_port   = 1
      to_port     = 65535
      type        = "egress"
      self        = true
      #cidr_blocks = ["0.0.0.0/0"]
      #source_node_security_group = true
    }
  }
  tags = {
    "kubernetes.io/cluster/demo" = "owned"
    Name                         = "eks-cluster-sg-demo"
  }
}

resource "aws_security_group" "cluster" {
  name        = "eks-cluster-sg"
  description = "EKS cluster security group"
  vpc_id      = local.vpc_id

  #tags = local.tags
}

resource "aws_security_group_rule" "cluster" {
  for_each = { for k, v in local.cluster_security_group_rules : k => v }

  # Required
  #security_group_id = aws_eks_cluster.demo.vpc_config[0].cluster_security_group_id
  security_group_id = aws_security_group.cluster.id
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  type              = each.value.type
  #cidr_blocks = each.value.cidr_blocks

  # Optional
  description = try(each.value.description, null)
  cidr_blocks = try(each.value.cidr_blocks, null)
  # prefix_list_ids = try(each.value.prefix_list_ids, [])
  self = try(each.value.self, null)
  ## each.value.source_security_group_id,
  # try(each.value.source_node_security_group, false) ? aws_security_group.node.id : null
  # )
}
################################################################################
# Node Security Group
# Defaults follow https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
# Plus NTP/HTTPS (otherwise nodes fail to launch)
################################################################################
/*
locals {
  node_security_group_rules = {
    egress_nodes_to_cluster = {
      description = "Node groups to cluster API"
      protocol    = "-1"
      from_port   = 1
      to_port     = 65535
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
      #source_cluster_security_group = true
    }
    ingress_cluster_to_nodes = {
      description = "Cluster API to node groups"
      protocol    = "-1"
      from_port   = 1
      to_port     = 65535
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
      #source_cluster_security_group = true
      #security_group_id = [aws_eks_cluster.demo.vpc_config[0].cluster_security_group_id]
    }
    ingress_node_to_node = {
      description = "Node to Node comms for ClusterIP and NodePort services"
      protocol    = "-1"
      from_port   = 1
      to_port     = 65535
      type        = "ingress"
      self        = true
    }
    egress_all_tcp = {
      description = "Egress all to internet"
      protocol    = "tcp"
      from_port   = 1
      to_port     = 65535
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress_all_udp = {
      description = "Egress all to internet"
      protocol    = "udp"
      from_port   = 1
      to_port     = 65535
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

resource "aws_security_group" "node" {
  name        = "eks-nodes-sg"
  description = "EKS Worker Node Security Group"
  vpc_id      = local.vpc_id

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_security_group_rule" "node" {
  for_each = { for k, v in local.node_security_group_rules : k => v }

  # Required
  security_group_id = aws_security_group.node.id
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  type              = each.value.type
  #cidr_blocks = each.value.cidr_blocks

  # Optional
  description = try(each.value.description, null)
  cidr_blocks = try(each.value.cidr_blocks, null)
  self        = try(each.value.self, null)
  #source_security_group_id = try(
  # each.value.source_security_group_id,
  # try(each.value.source_cluster_security_group, false) ? aws_security_group.cluster.id : null
  #)
}
*/
resource "aws_security_group" "allow_nfs" {
  name        = "allow nfs for efs"
  description = "Allow NFS inbound traffic"
  vpc_id      = local.vpc_id

  ingress {
    description = "NFS from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.cluster.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow nfs for efs"
  }
}

/*
# EKS Cluster security group
resource "aws_security_group" "eks_cluster" {
  name   = "ControlPlaneSecurityGroup"
  vpc_id = local.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ControlPlaneSecurityGroup"
  }
}
*/
# EKS security group rule
resource "aws_security_group_rule" "cluster_inbound" {
  description              = "Allow unmanaged nodes to communicate with control plane (all ports)"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.allow_nfs.id
  type                     = "ingress"
}