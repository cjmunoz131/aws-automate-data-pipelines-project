output "vpc_workloads_id" {
  value = aws_vpc.vpc_workloads.id
}

output "database_route_table_id" {
  value = aws_route_table.database_rt.id
}

output "private_route_table_id" {
  value = aws_route_table.private_rt.id
}

output "subnet_private_ids" {
  value = aws_subnet.private_subnets.*.id
}

output "subnet_database_ids" {
  value = aws_subnet.database_subnets.*.id
}

output "subnet_public_ids" {
  value = aws_subnet.public_subnets.*.id
}