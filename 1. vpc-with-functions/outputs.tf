output "private" {
  value = aws_subnet.private.*.id
}

output "public" {
  value = aws_subnet.public.*.id
}

output "node_role" {
  value = aws_iam_role.demo.arn
}

output "demo_role" {
  value = aws_iam_role.nodes.arn
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "cluster_sg" {
  value = aws_security_group.cluster.id
}

output "efs_sg" {
  value = aws_security_group.allow_nfs.id
}